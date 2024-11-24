 function [X,dag,nodeNames] = dataGeneration2(name,nSamples,verbose)
%Generating non-linear Euclidean Data<3> or <4>
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
    fprintf('Generating non-linear Euclidean Data<3><4>\n');
end


% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);
flag=0;
%Generate Samples
X = zeros(nSamples,n);
for j = 1:n 
    for k=1:n
        if dag(k,j)==1
            X(:,j)=sin(X(:,k)+X(:,j));
%             X(:,j)=sin(X(:,k)).*cos(X(:,k))+X(:,j);
        %The above two forms generate Euclidean data <3><4> in the article.
            flag=1;           
        end 
    end
    if flag==0
        X(:,j)= randn(nSamples,1);
     %Generate samples without parent nodes             
    else
        X(:,j)=X(:,j)+ randn(nSamples,1);
     %Add the random noises            
    end
    flag=0;
        
end


% Standardize data
X = standardizeCols(X);
end