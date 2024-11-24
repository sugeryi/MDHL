function [X,dag,nodeNames] = spdGeneration2(name,nSamples,verbose)
%Generating non-Euclidean Data SPD<2>
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

save('./Data/spd2size.mat','nSamples');
if verbose
    fprintf('Generating non-Euclidean Data SPD<2>\n');
end

% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);

% Generate Samples
dim = 3;
eigenvalue = zeros(nSamples,n);
X = cell(n,1);
for i=1:n
    X{i} = zeros(dim,dim,nSamples);
end
flag = 0;
for j = 1:n
    for k = 1:n
        if dag(k,j) == 1
            eigenvalue(:,j) = eigenvalue(:,j) + (0.2+0.8*rand(1))*eigenvalue(:,k);
            flag=1;
        end
    end
     if flag==0
         source = rand(nSamples,1);
         save('./Data/source.mat','source');
         eigenvalue(:,j) = source;
         !R CMD BATCH ./Data/spdEigen.R
         load('SPDdata2.mat');
         X{j} = spddata;
    else
         eigenvalue(:,j) = eigenvalue(:,j) + rand(nSamples,1); 
         source = eigenvalue(:,j);
         save('./Data/source.mat','source');
         !R CMD BATCH ./Data/spdEigen.R
         load('SPDdata2.mat');
         X{j} = spddata;
    end
    flag=0;
end
end
