%偏相关系数，数值式，
function [CC]=PCB(X,k)
% Input X: data set, each row means a data case, each column means a variable.
% k : threshold based on large amount of experiments. When the value equals 0.1, the algorithm has the best performance.
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
CC=R

for i=1:p
  for j=1:p
    if(abs(CC(i,j))>=k) %阈值可修改
            CC(i,j)=1;
    else
            CC(i,j)=0;
  
    end
  end
end

for i=1:p
 for j=1:i
     CC(i,j)=0;
   end
end