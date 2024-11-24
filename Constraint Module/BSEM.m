%根据回归系数进行过滤，对显著的回归系数对应的变量保留
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
     
     
     beta12=inv(tempData'*tempData)*tempData'*Y1 %回归系数，此处为列向量
          %回归系数的显著性检验，采用t检验，见“多元线形回归与多项式回归”文档的p168-169
     df=nSamples-numOfVar %自由度为n-m-1=nSamples-(numOfVar-1)-1
     Se=sqrt((Y1'*Y1-beta12'*tempData'*Y1)/df) %离回归标准误差
     C=inv(tempData'*tempData) 
     
     for j=1:i-1 %numOfVar-1
      Sb=Se*sqrt(C(j,j))  %回归系数的标准差的估计量
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