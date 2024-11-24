%���ݻع�ϵ�����й��ˣ��������Ļع�ϵ����Ӧ�ı�������
function [CC]=BSEM(X,k)
% Input X: data set, each row means a data case, each column means a variable.
% k : threshold based on significance level
% CC: obtained the network structure skeleton

[nSamples,numOfVar]=size(X)
CC=zeros(numOfVar);
for i=1:numOfVar
      
     Y1=X(:,i);
     tempData=X; 
     tempData(:,[i])=[];
     
     
     beta12=inv(tempData'*tempData)*tempData'*Y1 %�ع�ϵ�����˴�Ϊ������
          %�ع�ϵ���������Լ��飬����t���飬������Ԫ���λع������ʽ�ع顱�ĵ���p168-169
     df=nSamples-numOfVar %���ɶ�Ϊn-m-1=nSamples-(numOfVar-1)-1
     Se=sqrt((Y1'*Y1-beta12'*tempData'*Y1)/df) %��ع��׼���
     C=inv(tempData'*tempData) 
     
     for j=1:i-1 %numOfVar-1
      Sb=Se*sqrt(C(j,j))  %�ع�ϵ���ı�׼��Ĺ�����
      T=beta12(j)/Sb  
      p_value=(1-tcdf(abs(T),df))*2
      if p_value<k 
         beta12(j)=1
      else
          beta12(j)=0
      end  
     end 
 
     %beta12=[beta12(1:i-1);0;beta12(i:end)]
          
     CC([1:i-1],i)=beta12(1:i-1)


  end