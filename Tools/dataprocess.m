clear;clc;
% load the real power plant data
load('./Data/2019-01-29#2019-02-05.mat');
data=X;
DAG = load('./Data/DAG_real');
DAG=DAG.DAG;
node=1;

row_node = DAG(node,:);
col_node = DAG(:,node);
par = find(col_node==1);
child = find(row_node==1);

MB = par';
%MB = [par' child];
addd = [1:size(data,1)]';
GetDataMB = [addd data(:,[node MB])];
all=setdiff(1:size(data,2),node);
GetDataAll = [addd data(:,[node all])];

 dlmwrite('.\Data\Mytrain.csv',GetDataMB(1:8000,:));
 dlmwrite('.\Data\Mypredict.csv',GetDataMB(8001:10000,:));
 dlmwrite('.\Data\Mytrainall.csv',GetDataAll(1:8000,:));
 dlmwrite('.\Data\Mypredictall.csv',GetDataAll(8001:10000,:));

plot(data(1:8000,node));