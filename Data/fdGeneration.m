function [X,dag,nodeNames] = fdGeneration(name,nSamples,verbose)
%Generating non-Euclidean Data FD<1> or <2>
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

if verbose
    fprintf('Generating non-Euclidean Data FD<1><2>\n');
end


% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);

% Generate Samples
coef = zeros(3*nSamples,n);
X = cell(n,1);
for i=1:n
    X{i} = zeros(nSamples,17);
end
flag = 0;
for j = 1:n
    for k = 1:n
        if dag(k,j) == 1
            X{j} = X{j} + (0.2+0.8*rand(1))*X{k}; 
%	X{j} = X{j} + (0.2+0.8*rand(1))*sin(X{k}); 
            flag=1;
        end
    end
     if flag==0
         sourcecoef = randn(3*nSamples,1);
         save('./Data/sourcecoef.mat','sourcecoef');
         coef(:,j) = sourcecoef;
         !R CMD BATCH  ./Data/fdData.R
         load('FDdata.mat');
         X{j} = fdadata;
     else
         X{j} = X{j} + randn(nSamples,17);

        end
        flag=0;
end
end