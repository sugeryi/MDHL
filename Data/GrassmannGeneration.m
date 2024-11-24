function [Z,dag,nodeNames] = GrassmannGeneration(name,nSamples,verbose)
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


% save('./DcData/spd1size.mat','nSamples');
if verbose
    fprintf('Generating non-Euclidean Data GRASSMANN\n');
end

% Get DAG
dagFunc = str2func(strcat('getDAG',name));
[dag,nodeNames] = dagFunc();
n = length(dag);

% Generate Samples
dimn = 2;
dimp = 1;
% 元胞 z
X = cell(n,1);
Z = cell(n,1);

dimz = 3;
% 每个节点是一个dim x dim x nSamples的三维矩阵 z  
for i=1:n
    X{i} = zeros(dimn,dimn,nSamples);
    Z{i} = zeros(nSamples,dimz);
end
% 有无父节点 z
flag=0;
for j = 1:n
    for k = 1:n
        if dag(k,j) == 1
%             X{j} = X{j} +(0.4+0.6*rand(1))*X{k};
            Z{j} = Z{j} +(0.4+0.6*rand(1))*Z{k};
            flag=1;
        end
    end
     if flag==0
         for q=1:nSamples
             [Q,~] = qr(randn(dimn));
             t = Q(:,1:dimp);
             X{j}(:,:,q) = t*t';
         end
         Z{j} = Sym2vec(X{j},nSamples,dimz,dimn);
        
     else
         for q=1:nSamples
%              Y = rand(dimn,dimn);
%              X{j}(:,:,q) = X{j}(:,:,q) + Y;
             a = rand(1,dimz);
             Z{j}(q,:) = Z{j}(q,:)+a;
         end
     end
     flag=0;
end


% save('./GrassmannData/Alarm/GrassmannAlarm1000.mat','X');

end

            
        