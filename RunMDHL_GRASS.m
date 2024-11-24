%alarm,barley,carpo,chain,factors,water,mildew,insurance,hailfinder;
clc;clear;close all;
discrete = 0;
data = 'water';
nSamples =100;
nEvals =2500;
rand('state',0);
randn('state',0);



fold=10;
miss= zeros(1,fold);
extra= zeros(1,fold);
reverse= zeros(1,fold);
missorient= zeros(1,fold);
total= zeros(1,fold);
total1=zeros(1,1);

precision = zeros(1,fold);
recall = zeros(1,fold);
totalprecision = zeros(1,1);
totalrecall = zeros(1,1);

indices = crossvalind('Kfold',nSamples,fold);



% [X,G,nodeNames] =GrassmannGeneration(data,nSamples,1);
% save('./GrassmannData/Water/GrassmannWater1000Data.mat','X');
% save('./GrassmannData/Water/GrassmannWater1000Graph.mat','G');

n = 32;




f1 = load('./GrassmannData/Water/GrassmannWater100Data_3col.mat');
X = f1.CS;
f2 = load('./GrassmannData/Water/GrassmannWater1000Graph.mat');
G = f2.G;




!R CMD BATCH  ./Tools/bcovTest.R

% [SK]=PCB(X,0.1);

pvalMatrix = load('./GrassmannData/Water/pvalMatrix100_3col.mat');
pvalMatrix = pvalMatrix.pvalMatrix;
k1=0.01;
[SK]=comparePval(pvalMatrix,k1);



%Obtain the skeleton network SK after bcov_Pruned
for k=1:fold
    test12 = (indices == k);
    train = ~test12;          %train set index
    train_data = X(train,:);
    penalty = log(nSamples*0.9)/2;
    DAG_NEHL= DAGsearch(train_data,nEvals,0,penalty,SK);
    [miss(1,k),extra(1,k),reverse(1,k),missorient(1,k),total(1,k)]=CompareDag(DAG_NEHL,G);
    sum_DAG = 0;
    sum_G = 0;
    TP = 0;
    [dim1,dim2] = size(G);
    for num1=1:dim1
        for num2=1:dim2
            if DAG_NEHL(num1,num2)==1
                sum_DAG = sum_DAG+1;
            end
            if G(num1,num2)==1
                sum_G = sum_G+1;
            end
            if DAG_NEHL(num1,num2)==1 && G(num1,num2)==1
                TP = TP+1;
            end
        end
    end
    precision(1,k) = TP/sum_DAG;
    recall(1,k) = TP/sum_G;
end
for k=1:fold
    total1=total(1,k)+total1;
    totalprecision = totalprecision + precision(1,k);
    totalrecall = totalrecall + recall(1,k);
end
z_cuowu= total1/fold;
totalprecision = totalprecision/10;
totalrecall = totalrecall/10;



