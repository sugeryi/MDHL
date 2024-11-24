%%
% Obtain training samples and prediction samples
clear;clc;
% 10000samples, 40 nodes
fprintf('loading...\n');
load('./Data/2019-01-29#2019-02-05.mat');
% load('./sz1_pre.mat');
data = X;
fprintf('load finish...\n');

% Observed node
node = 1;

% Data without feature selection
[YTest,YPred,rmse] = LSTM(data,node);

% Data after feature selection
DAG = load('./Data/DAG_real');
% DAG = load('./sz1_pre_DAG');
DAG=DAG.DAG;
row_node = DAG(node,:);
col_node = DAG(:,node);
par = find(col_node==1);
child = find(row_node==1);
MB = par';
% MB = [par' child];
dataMB = data(:,[node MB]);
[YTestMB,YPredMB,rmseMB] = LSTM(dataMB,1);


% Plot
fprintf("Ploting...");
x = 1:1:size(YTest,2);
plot(x,YTest,'--r.',x,YPred,'-g.',x,YPredMB,'-k.')

legend(["Observed" "All Features" "TBHL"])
xlabel("Time")
ylabel("Value")
title("Prediction with LSTM")
