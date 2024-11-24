function [DAG_TC]=TC(X,k)
% Input X: data set, each row means a data case, each column means a variable.
% threshold :significance threshold 
% DAG_TC: obtaned the final network structure


[nSamples,numOfVar]=size(X)
% step 1 Skeleton construction
DAG_TC=zeros(numOfVar);
DAG_Beg=zeros(numOfVar);

   for i=1:numOfVar
      
     Y1=X(:,i);
     tempData=X; 
     tempData(:,[i])=[];
          
     beta12=inv(tempData'*tempData)*tempData'*Y1 %回归系数，此处为列向量
          %回归系数的显著性检验，采用t检验，见“多元线形回归与多项式回归”文档的p168-169
     df=nSamples-numOfVar %自由度为n-m-1=nSamples-(numOfVar-1)-1  m是回归变量数
     Se=sqrt((Y1'*Y1-beta12'*tempData'*Y1)/df) %离回归标准误差
     C=inv(tempData'*tempData) 
     
     for j=1:numOfVar-1
      Sb=Se*sqrt(C(j,j))  %回归系数的标准差的估计量
      T=beta12(j)/Sb  
      p_value=(1-tcdf(abs(T),df))*2
      if p_value<k 
         beta12(j)=-1
      else
          beta12(j)=0
      end  
     end 
 
     
     beta12=[beta12(1:i-1);0;beta12(i:end)]

     DAG_Beg([1:end],i)=beta12
     
  end

% step 2 Spurious arc removal & V-structure detection


for i=1:numOfVar 
   for j=1:numOfVar
     if (DAG_Beg(i,j)==-1)
        [Sxy,Tri_ij,flag]=ColliderSearch(X,DAG_Beg, i, j, k)
         if (flag==1)
            DAG_Beg(i,j)=0
            Z=setdiff(Tri_ij,Sxy)
            if(~isempty(Z) )
               Z_len=size(Z,2)
               for k=1:Z_len
                 DAG_Beg(i,Z(k))=1
                 DAG_Beg(j,Z(k))=1
               end
             end
          end
       end
   end
 end

%Step 3: Constraint propagation
pdag=DAG_Beg
old_pdag = zeros(numOfVar);
iter = 0;
while ~isequal(pdag, old_pdag)
  iter = iter + 1;
  old_pdag = pdag;
  % rule 1
  [A,B] = find(pdag==1); % a ->b
  for k=1:length(A)
    a = A(k); b = B(k);
    C = find(pdag(:,b)==-1 & pdag(:,a)==0); % all nodes adj to b but not a
   % C = find(pdag(b,:)==-1 & DAG_Beg(a,:)==0); 
    if ~isempty(C)
      pdag(b,C) = 1; pdag(C,b) = 0;
      %fprintf('rule 1: a=%d->b=%d and b=%d-c=%d implies %d->%d\n', a, b, b, C, b, C);
    end
  end
  % rule 2
  [A,B] = find(pdag==-1); % unoriented a-b edge
  for k=1:length(A)
    a = A(k); b = B(k);
    if any( (pdag(a,:)==1) & (pdag(:,b)==1)' );
      pdag(a,b) = 1; pdag(b,a) = 0;
      %fprintf('rule 2: %d -> %d\n', a, b);
    end
  end
  % rule 3
  [A,B] = find(pdag==-1); % a-b
  for k=1:length(A)
    a = A(k); b = B(k);
    C = find( (pdag(a,:)==-1) & (pdag(:,b)==1)' );
    
   % C contains nodes c s.t. a-c->b
     number=size(C,2);
    if number>=2  % there are 2 different non adjacent elements of C
      pdag(a,b) = 1; pdag(b,a) = 0;
      %fprintf('rule 3: %d -> %d\n', a, b);
    end
  end

end

DAG_TC=pdag
clear nSamples numOfVar DAG_Beg i Y1 tempData beta12 df Se C Sb T p_value j Sxy Tri_ij flag Z k pdag old_pdag iter A B C
