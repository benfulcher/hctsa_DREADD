%-------------------------------------------------------------------------------
% FOREPLAY:
whatNormalization = 'scaledRobustSigmoid'; % 'zscore', 'scaledRobustSigmoid'
% Label all time series:
% TS_LabelGroups({'SHAM','DREDD','rsfMRI'},'raw');
TS_LabelGroups({'SHAM','excitatory'},'raw');
% Normalize the data, filtering out features with any special values:
TS_normalize(whatNormalization,[0.5,1],'HCTSA_baselineSub.mat',true);
% Load data in as a structure:
% unnormalizedData = load('HCTSA.mat');
unnormalizedData = load('HCTSA_baselineSub.mat');
% Load normalized data in a structure:
normalizedData = load('HCTSA_baselineSub_N.mat');

%-------------------------------------------------------------------------------
% Filter by a given time point
IDs_ts1 = TS_getIDs('ts1','HCTSA.mat','ts');
TS_FilterData('HCTSA.mat',IDs_ts1,[],'HCTSA_ts1.mat');
TS_normalize(whatNormalization,[0.5,1],'HCTSA_ts1.mat',true);
TS_classify('HCTSA_ts1_N.mat','svm_linear',false,true)

%-------------------------------------------------------------------------------
% Filter by a given time point
IDs_ts4 = TS_getIDs('ts4','HCTSA_baselineSub.mat','ts');
TS_FilterData('HCTSA_baselineSub.mat',IDs_ts4,[],'HCTSA_baselineSub_ts4.mat');
TS_normalize(whatNormalization,[0.5,1],'HCTSA_baselineSub_ts4.mat',true);
TS_classify('HCTSA_baselineSub_ts4_N.mat')

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

TS_TopFeatures('HCTSA_baselineSub_ts2.mat','fast_linear','numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'});

%-------------------------------------------------------------------------------
%% Investigate particular individual features in some more detail
annotateParams = struct('maxL',1000);
featureID = 411;
TS_FeatureSummary(featureID,unnormalizedData,true,annotateParams)
