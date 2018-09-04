function CrossPredict(analTrain,analTest,theTimePoint,numNulls)
% Train a model on SHAM–Excitatory and predict on SHAM-PVCre
%-------------------------------------------------------------------------------
if nargin < 1
    analTrain = 'Excitatory_SHAM';
end
if nargin < 2
    analTest = 'PVCre_SHAM';
end
if nargin < 3
    theTimePoint = 'ts3-BL'; % First time point (subtracting baseline)
end
if nargin < 4
    numNulls = 10;
end
whatFeatures = 'all';

%-------------------------------------------------------------------------------
regionLabels = {'right','left','control'};
numRegions = length(regionLabels);

% Cross-validation machine learning parameters:
theClassifier = 'svm_linear';
numFolds = 0;
numRepeats = 10;

%-------------------------------------------------------------------------------
accuracy = zeros(numRegions,1);
for k = 1:numRegions
    theRegion = regionLabels{k};

    fprintf(1,'\n\n %s at %s \n\n\n',theRegion,theTimePoint);

    % Use baseline-removed, normalized data at the default time point:
    [~,~,~,~,hctsaData] = GiveMeLeftRightInfo(theRegion,'Excitatory_PVCre_SHAM',theTimePoint);
    normalizedData = LoadDataFile(hctsaData,whatFeatures);

    % Separate into training and test:
    % Train on SHAM-Excitatory and test labels on PVCre data
    isTrain = ismember(normalizedData.TimeSeries.Group,[1,3]); % Excitatory or SHAM
    isTest = normalizedData.TimeSeries.Group==2; % PVCre
    trainingData = normalizedData.TS_DataMat(isTrain,:);
    trainingLabels = normalizedData.TimeSeries.Group(isTrain);
    trainingLabels(trainingLabels==3) = 2; % Convert to binary data labels \in [1,2]

    % Train the linear SVM model:
    Mdl = fitcsvm(trainingData,trainingLabels,'KernelFunction','linear',...
                        'Weights',InverseProbWeight(trainingLabels));
    % Evaluate model on test data:
    testData = normalizedData.TS_DataMat(isTest,:);
    labelPredict = predict(Mdl,testData);
    accuracy(k) = mean(labelPredict==1)*100;
end

%-------------------------------------------------------------------------------
% Plot:
f = figure('color','w'); ax = gca; hold on
plot(accuracy,'ok','LineWidth',2)
ax.XTick = 1:numRegions;
ax.XTickLabel = regionLabels;
ylabel('Cross-prediction accuracy (%)');
xlabel('Brain region');
xlim([0.9,3.1])

end
