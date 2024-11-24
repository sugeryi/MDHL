function [X,dag,nodeNames] = spdGeneration1(name,nSamples,verbose)
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


save('./Data/spd1size.mat','nSamples');
if verbose
    fprintf('Generating non-Euclidean Data SPD<1>\n');
end

% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);

% Generate Samples
dim = 10;
X = cell(n,1);
for i=1:n
    X{i} = zeros(dim,dim,nSamples);
end
flag=0;
for j = 1:n
    for k = 1:n
        if dag(k,j) == 1
            X{j} = X{j} +(0.4+0.6*rand(1))*X{k};
            flag=1;
        end
    end
     if flag==0
         !R CMD BATCH ./Data/spdElements.R
         load('./Data/SPDdata1.mat');
         X{j} = spddata;
     else
         for q=1:nSamples
             a = rand(1,dim);
             Y = a'*a;
             X{j}(:,:,q) = X{j}(:,:,q) + Y;
         end
     end
     flag=0;
end
end

            
        