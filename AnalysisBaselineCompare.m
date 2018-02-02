%-------------------------------------------------------------------------------
% FOREPLAY:
whatNormalization = 'zscore'; % 'zscore', 'scaledRobustSigmoid'
% Label all time series by either 'day' or 'night':
TS_LabelGroups({'SHAM','DREDD','rsfMRI'},'raw');
% Normalize the data, filtering out features with any special values:
TS_normalize(whatNormalization,[0.5,1],[],1);
% Load data in as a structure:
% unnormalizedData = load('HCTSA.mat');
unnormalizedData = load('HCTSA_baselineSub.mat');
% Load normalized data in a structure:
normalizedData = load('HCTSA_N.mat');

%-------------------------------------------------------------------------------
%% Generate a low-dimensional principal components representation of the dataset:
numAnnotate = 6; % number of time series to annotate to the plot
userSelects = false; % whether the user can click on time series to manually annotate
timeSeriesLength = 600; % length of time-series segments to annotate
annotateParams = struct('n',numAnnotate,'textAnnotation','none',...
                        'userInput',userSelects,'maxL',timeSeriesLength);
TS_plot_pca(normalizedData,true,'',annotateParams)

%-------------------------------------------------------------------------------
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
whatStatistic = 'fast_linear'; % fast linear classification rate statistic

TS_TopFeatures(unnormalizedData,'fast_linear','numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'});

%-------------------------------------------------------------------------------
%% Investigate particular individual features in some more detail
annotateParams = struct('maxL',1000);
featureID = 411;
TS_FeatureSummary(featureID,unnormalizedData,true,annotateParams)
