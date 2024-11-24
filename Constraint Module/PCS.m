
%偏相关系数，假设检验式,上三角式
function [CC]=PCS(X,k)
% Input X: data set, each row means a data case, each column means a variable.
% k : threshold based on significance level
% CC: obtained the network structure skeleton

CC=corrcoef(X)
[n,p]=size(X)
C=inv(CC)
R=zeros(p,p)
for i=1:p
   for   j=1:p
     R(i,j)=-C(i,j)/sqrt(C(i,i)*C(j,j));
  end
end
CC=zeros(p,p)

for i=1:p
  for j=i+1:p
    Sb=sqrt((1-R(i,j)^2)/(n-p))  
      df=n-p
      T=R(i,j)/Sb  
      p_value=(1-tcdf(abs(T),df))*2
      if p_value<k 
         CC(i,j)=1
      else
         CC(i,j)=0
      end  
  end
end

