function [spddatt] = prodLogm3DMulti(data1,data2,data3,n,nSamples)


spddatt=zeros(n,nSamples);

% num = (0.4+0.6*rand(1));
num1 = (0.4+0.6*rand(1));
num2 = (0.4+0.6*rand(1));
num3 = (0.4+0.6*rand(1));

% num1 = 0.5;
% num2 = 0.5;

for j = 1:nSamples
    spddatt(:,j)=num1*data1(:,j)+num2*data2(:,j)+num3*data3(:,j);
end



end

