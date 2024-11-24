function [YTest,YPred,rmse] = LSTM(data,point)
% Data preprocessing
data = normalized_data(data);
data = data';
[nvar,~] = size(data);

% Split data set
numTimeStepsTrain = floor(0.8*size(data,2));
dataTrain = data(:,1:numTimeStepsTrain+1);
dataTest = data(:,numTimeStepsTrain+1:end);

XTrain = dataTrain(:,1:end-1);
YTrain = dataTrain(point,2:end);

% Create the LSTM regression network ( 200 hidden units )
numFeatures = nvar;
numResponses = 1;
numHiddenUnits = 200;
layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

%  Set options
options = trainingOptions('adam', ...
    'MaxEpochs',50, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

net = trainNetwork(XTrain,YTrain,layers,options);


XTest = dataTest(:,1:end-1);
net = predictAndUpdateState(net,XTrain);

% Predict future time steps
YPred = [];
numTimeStepsTest = size(XTest,2);
for i = 1:numTimeStepsTest
    [net,YPred(:,i)] = predictAndUpdateState(net,XTest(:,i),'ExecutionEnvironment','cpu');
end


YTest = dataTest(point,2:end);

rmse = sqrt(mean((YPred-YTest).^2));

end

