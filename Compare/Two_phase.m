function [DAG_TP]=Two_phase(X,threshold)
% Input X: data set, each row means a data case, each column means a variable.
% threshold :significance threshold 
% DAG_TP: obtaned the final network structure
[nSamples,numOfVar]=size(X)
sep = cell(numOfVar,numOfVar);
% step 1 constructs a Markov random field from data
DAG_TP=zeros(numOfVar);

CC=corrcoef(X)
C=inv(CC)
R=zeros(numOfVar,numOfVar)
for i=1:numOfVar
   for   j=1:numOfVar
     R(i,j)=-C(i,j)/sqrt(C(i,i)*C(j,j));
  end
end
CC=R


for i=1:numOfVar
  for j=1:numOfVar
    Sb=sqrt((1-R(i,j)^2)/(nSamples-numOfVar))  
      df=nSamples-numOfVar
      T=R(i,j)/Sb  
      p_value=(1-tcdf(abs(T),df))*2
      if p_value<threshold
         CC(i,j)=-1
      else
         CC(i,j)=0
      end  
  end
end


%step 2 remove redundant edge
%collecting all vertices on simple paths for any two vertices
[simpathnode] = bfs(CC, 1)
 
num=0
for i=1:numOfVar
  for j=1:numOfVar
   
  if(CC(i,j)==-1)
        C_ij=simpathnode{i,j} %Construct a set C
       if(~isempty(C_ij))
          [C,flag] = Separate(i,j,X,C_ij,threshold)
           if(flag==true)
             CC(i,j)=0
             num=num+1
             sep{i,j}=C;
             fprintf('%d %d',i,j)           
           end
       end
    end
   end%for
end%for



%step 3 Orient edges

%V-structures detection

pdag = CC;
[X, Y] = find(CC);
% We want to generate all unique triples x,y,z
% This code generates x,y,z and z,y,x.
for i=1:length(X)
  x = X(i);
  y = Y(i);
  Z = find(CC(y,:));
  Z = setdiff(Z, x);
  for z=Z(:)'
    if CC(x,z)==0 & ~ismember(y, sep{x,z}) & ~ismember(y, sep{z,x})
      %fprintf('%d -> %d <- %d\n', x, y, z);
      pdag(x,y) = 1; pdag(y,x) = 0;
      pdag(z,y) = 1; pdag(y,z) = 0;
    end
  end
end




%Propagate the arrow orientation
old_pdag = zeros(numOfVar);
iter = 0;
while ~isequal(pdag, old_pdag)
  iter = iter + 1;
  old_pdag = pdag;
  % rule 1
  [A,B] = find(pdag==1); % a ->b
   for i=1:length(A)
    a = A(i); b = B(i);
    C = find(pdag(b,:)==-1 & CC(a,:)==0); % all nodes adj to b but not a
    if ~isempty(C)
      pdag(b,C) = 1; pdag(C,b) = 0;
      %fprintf('rule 1: a=%d->b=%d and b=%d-c=%d implies %d->%d\n', a, b, b, C, b, C);
    end
  end
  % rule 2
  [A,B] = find(pdag==-1); % unoriented a-b edge
  for i=1:length(A)
    a = A(i); b = B(i);
    if any( (pdag(a,:)==1) & (pdag(:,b)==1)' );
      pdag(a,b) = 1; pdag(b,a) = 0;
      %fprintf('rule 2: %d -> %d\n', a, b);
    end
  end
  % rule 3
  [A,B] = find(pdag==-1); % a-b
  for i=1:length(A)
    a = A(i); b = B(i);
    C = find( (pdag(a,:)==-1) & (pdag(:,b)==1)' );
    % C contains nodes c s.t. a-c->b
     G2 = setdiag(CC(C, C), 1);
    if any(G2(:)==0) % there are 2 different non adjacent elements of C
      pdag(a,b) = 1; pdag(b,a) = 0;
      %fprintf('rule 3: %d -> %d\n', a, b);
    end
  end
end

for i=1:numOfVar
  for j=1:numOfVar
   if (i==j)
      pdag(i,j)=0
   end
  end
end



DAG_TP=pdag

   














