%-------------------------------------------------------------------------------
% PARAMETERS:
leftOrRight = 'control';
whatNormalization = 'scaledRobustSigmoid';
labelByMouse = false; % do SHAM/DREADDs instead of labeling by mouse
doCluster = true;
useOldResults = true;

if useOldResults
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);
    normDataBL = [rawDataBL(1:end-4),'_N.mat'];
else
    [prePath,rawData,rawDataBL,normDataBL] = Foreplay(leftOrRight,whatNormalization,labelByMouse,doCluster);
end

%-------------------------------------------------------------------------------
% Load data in as a structure:
unnormalizedData = load(rawDataBL);
% Load normalized data in a structure:
normalizedData = load(normDataBL);

%-------------------------------------------------------------------------------
% Plot as a clustered data matrix:
TS_plot_DataMatrix(normalizedData,'colorGroups',true)

%-------------------------------------------------------------------------------
% Classification (grouping all time points):
TS_classify(normalizedData,'svm_linear','numPCs',5,'numNulls',5,...
                    'numFolds',3,'numRepeats',10,'seedReset','none');

%-------------------------------------------------------------------------------
%% Generate a low-dimensional principal components representation of the dataset:
numAnnotate = 3; % number of time series to annotate to the plot
userSelects = true; % whether the user can click on time series to manually annotate
timeSeriesLength = 600; % length of time-series segments to annotate
annotateParams = struct('n',numAnnotate,'textAnnotation','none',...
                        'userInput',userSelects,'maxL',timeSeriesLength);
TS_plot_pca(normalizedData,true,'',annotateParams)

numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
whatStatistic = 'fast_linear'; % fast linear classification rate statistic
TS_TopFeatures(rawDataBL,whatStatistic,'numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'},...
            'numNulls',10);
