function [Z,dag,nodeNames] = spdGeneration4(name,nSamples,verbose)
%Generating non-Euclidean Data SPD<1>
% Inputs:
% name(selected benchmark network name):
%   'alarm'
%   'carpo'
%   'insurance'
%   etc.
% nSamples:
%  number of samples to generate from network
%
% Outputs:
% X: generated data set
% dag: causal structure of the selected benchmark network

%z Y=f(X,N)



save('./ChainData/GenData1000/spd1size.mat','nSamples');
if verbose
    fprintf('Generating non-Euclidean Data SPD<4>\n');
end

% Get DAG
dagFunc = str2func(strcat('getDAG',name));
% [dag,nodeNames,P] = dagFunc();
[dag,nodeNames] = dagFunc();
n = length(dag);

% Generate Samples
dim = 2;
% 元胞 z
X = cell(n,1);
Y = cell(n,1);
Z = cell(n,1);

dimz=3;

% 每个节点是一个dim x dim x nSamples的三维矩阵 z  
for i=1:n
    X{i} = zeros(dim,dim,nSamples);
    Y{i} = zeros(dim,dim,nSamples);
    Z{i} = zeros(nSamples,dimz); % n(n+1)/2
end
% 有无父节点 z
flag=0;
for j = 1:n
    for k = 1:n
        if dag(k,j) == 1
            
            X{j} = X{j} +(0.4+0.6*rand(1))*X{k};
            Z{j} = Z{j} +(0.4+0.6*rand(1))*Z{k};
            flag=1;
        end
    end
    
     if flag==0
         !R CMD BATCH ./DcRfunction/spdElements3.R
         load('./ChainData/GenData1000/SPDdata1.mat');
         X{j} = spddata;
         Y{j} = prodLogm3D(spddata,dim,nSamples);
         Z{j} = Sym2vec(Y{j},nSamples,dimz,dim);
     else
         for q=1:nSamples
             b = rand(1,dim);
             c = b'*b;
             X{j}(:,:,q) = X{j}(:,:,q) + c;
             
             a = rand(1,dimz);
%              Z = a'*a;
%              Y{j}(:,:,q) = Y{j}(:,:,q) + Z;
             Z{j}(q,:) = Z{j}(q,:)+a;
         end
         
     end
     flag=0;
end

save('./ChainData/GenData1000/SpdChain1000DataOrign.mat','X');


end

            
        