
% 偏秩相关系数
function [CC]=IPCB(X,k)
CC=corrcoef(X);
[n,p]=size(X);
C=inv(CC);
R=zeros(p,p);
for i=1:p
   for   j=1:p
     R(i,j)=-C(i,j)/sqrt(C(i,i)*C(j,j));
  end
end
CC=zeros(p,p);

for i=1:p
  for j=i+1:p
    Sb=sqrt((1-R(i,j)^2)/(n-p))  ;
      df=n-p;
      T=R(i,j)/Sb;
      p_value=(1-tcdf(abs(T),df))*2;
      if abs(p_value)<k 
         CC(i,j)=1;
         CC(j,i)=1;
      else
         CC(i,j)=0;
      end  
  end
end
% for i=1:p
%     CC(i,i)=0;
% end