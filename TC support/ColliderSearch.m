function [Sxy,Tri_ij,flag]=ColliderSearch(X,DAG_Beg, i, j,k)
 Sxy=[]
 Bd_i=[]
 Bd_j=[]
 Tri_ij=[]
 
 [nSamples,numOfVar]=size(X)
 for l=1:numOfVar
    if DAG_Beg(l,i)~=0
          Bd_i=[Bd_i,l];
     end
  end
  for l=1:numOfVar
    if DAG_Beg(l,j)~=0
          Bd_j=[Bd_j,l];
     end
  end
Tri_ij=intersect(Bd_i,Bd_j) 

temp1=setdiff(setdiff(Bd_i,Tri_ij),j);
temp2=setdiff(setdiff(Bd_j,Tri_ij),i);
size1=size(temp1,2);
size2=size(temp2,2);
if size1<=size2
   B=temp1;
else
   B=temp2;
end

size_Tri=size(Tri_ij,2);
if size_Tri==0
   Result=[0];
   R_len=1
 else
  [Result,R_len]=miji(Tri_ij,size_Tri);
 end

  for l=1:R_len
    S= Result(l,[1:end])
    S(S==0) = []
    Z=union(B,S)
    
     Y1=X(:,i);
     
     %方法1，通过在i变量回归，测试j 变量的回归系数的显著性
     col=size(Z,2)+1  %Z中肯定不包含i，j
     tempData=X(:,[j,Z])
     beta12=inv(tempData'*tempData)*tempData'*Y1 %回归系数，此处为列向量
          %回归系数的显著性检验，采用t检验，见“多元线形回归与多项式回归”文档的p168-169
      df=nSamples-col-1 %自由度为n-m-1=nSamples-(i-1)-1  m是回归变量数
      Se=sqrt((Y1'*Y1-beta12'*tempData'*Y1)/df) %离回归标准误差
      C=inv(tempData'*tempData) 
      Sb=Se*sqrt(C(1,1))  %回归系数的标准差的估计量
      T=beta12(1)/Sb   %仅仅对j变量进行显著性检验，j放在第1位
      p_value=(1-tcdf(abs(T),df))*2
      
      %方法2，直接利用定义求偏相关系数,但求出的偏相关系数多大才算显著，没有明确定论
     % Y2=X(:,j);      
     %tempData=X(:,Z)
     %tempData=X
     %tempData(:,[i])=[];
     %tempData(:,[j])=[];

      %beta11=regress(Y1,tempData);
      %e1=Y1-tempData*beta11;
      %beta21=regress(Y2,tempData);
      %e2=Y2-tempData*beta21;   
      %par=corr(e1,e2);    

       if p_value>k 
          Sxy=Z;
          flag=1;
          clear Bd_i Bd_j nSamples numOfVar l temp1 temp2 size1 size2 B size_Tri Result R_len S Z Y1 col tempData beta12 df Se C Sb T p_value;
          return;
       end  

     W=setdiff(Tri_ij,S)
     Des=[]
     if (~isempty(W))
        size_W=size(W,2);
       for m=1:size_W
           v=W(m)
           for n=1:numOfVar
              if DAG_Beg(n,v)~=0
                Des=[Des,n]
              end
            end
        end
     end
  D=intersect(B,Des)
  B1=setdiff(B,D)
  
  size_D=size(D,2);
  if size_D==0
     Result1=[0];
     R_len1=1
  else
  [Result1,R_len1]=miji(D,size_D);
  end


  for m=1:R_len1
      S1= Result1(m,[1:end])
      S1(S1==0) = []
      Z=union(union(B1,S1),S)
    
      col=size(Z,2)+1  %Z中肯定不包含i，j
      tempData=X(:,[j,Z])
      beta12=inv(tempData'*tempData)*tempData'*Y1 %回归系数，此处为列向量
          %回归系数的显著性检验，采用t检验，见“多元线形回归与多项式回归”文档的p168-169
     df=nSamples-col-1 %自由度为n-m-1=nSamples-(i-1)-1  m是回归变量数
     Se=sqrt((Y1'*Y1-beta12'*tempData'*Y1)/df) %离回归标准误差
     C=inv(tempData'*tempData) 
     Sb=Se*sqrt(C(1,1))  %回归系数的标准差的估计量
      T=beta12(1)/Sb   %仅仅对j变量进行显著性检验，j放在第1位
      p_value=(1-tcdf(abs(T),df))*2
       if p_value>k 
          Sxy=Z;
          flag=1;
          clear Bd_i Bd_j nSamples numOfVar l temp1 temp2 size1 size2 B size_Tri Result R_len S Z Y1 col tempData beta12 df Se C Sb T p_value;;
          return;
       end  
    end

 end 

 Sxy=[];
 flag=0;
clear Bd_i Bd_j nSamples numOfVar l temp1 temp2 size1 size2 B size_Tri Result R_len S Z Y1 col tempData beta12 df Se C Sb T p_value;
 return;

end




