function [X,dag,nodeNames,mynet] = dataGeneration1(name,nSamples,verbose)
%Generating linear Euclidean Data<1> or <2>
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
% mynet: CPDs of generated data


if verbose
    fprintf('Generating linear Euclidean Data<1><2>\n');
end

% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);

% Make CPDs
for i = 1:n
    mynet.mu{i} = 0;
    mynet.sigma{i} = 1;
    mynet.weights{i} = dag(:,i).*(sign(rand(n,1)-.5)+randn(n,1)/4);
    %generate random weights in the range of +/- 1+N(0,1)/4 for the
    %Euclidean data<1> in the article
%     mynet.weights{i} = dag(:,i).*(0.2+0.8.*rand(n,1));
    %generate random weights which  obey the uniform distribution of
    %[0.2,1] for the Euclidean data <2> in the article
end

% Generate Samples
X = zeros(nSamples,n);
for j = 1:n
    X(:,j) = mynet.mu{j}+X*mynet.weights{j}+randn(nSamples,1);
%     X(:,j) = mynet.mu{j}+X*mynet.weights{j}+exp( rand(nSamples,1));  
    %The above two forms generate Euclidean data <1><2> in the article.
end


% Standardize data
X = standardizeCols(X);
end