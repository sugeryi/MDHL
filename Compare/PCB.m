%ƫ���ϵ������ֵʽ��
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
% CC=R
% R=abs(R);
% save('./DataGen4_250_3/pcor_alarm_250_all.mat','R');


for i=1:p
  for j=(i+1):p
    if(abs(CC(i,j))>=k) %��ֵ���޸�
            CC(i,j)=1;
            CC(j,i)=1;
    else
            CC(i,j)=0;
            CC(j,i)=0;
  
    end
  end
end

for i=1:p
    CC(i,i)=0;
end