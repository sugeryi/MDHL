
flo = load('./DataGen4_mildew_250/mildewSPD4_250.mat');
data=flo.Z;
p=length(data);
samples=(size(data{1},1));
CS = zeros(samples,samples,p);
for i = 1:p
    temp = data{i}; % 二维矩阵 
    for j = 1:samples-1
        for k = j+1:samples
            CS(j,k,i) = norm((temp(j,:)-temp(k,:)),'fro');
            CS(k,j,i) = CS(j,k,i);
        end
    end
    
end
save('./DataGen4_mildew_250/SPDXdistMetri4_mildew_250.mat','CS');



