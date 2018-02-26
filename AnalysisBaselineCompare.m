%-------------------------------------------------------------------------------
% PARAMETERS:
leftOrRight = 'left';
whatNormalization = 'scaledRobustSigmoid'; % 'zscore', 'scaledRobustSigmoid'

%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);

%-------------------------------------------------------------------------------
% FOREPLAY:
% Label all time series:
% TS_LabelGroups({'SHAM','DREDD','rsfMRI'},'raw');
TS_LabelGroups(rawDataBL,{'SHAM','excitatory'});
% Normalize the data, filtering out features with any special values:
normDataBL = TS_normalize(whatNormalization,[0.5,1],rawDataBL,false);
% Cluster:
TS_cluster('euclidean','average','corr_fast','average',[true,true],normDataBL);

%-------------------------------------------------------------------------------
% Load data in as a structure:
unnormalizedData = load(rawDataBL);
% Load normalized data in a structure:
normalizedData = load(normDataBL);

TS_plot_DataMatrix(normalizedData,'colorGroups',true)

%-------------------------------------------------------------------------------
% Classification across all time points:
TS_classify(normalizedData,'svm_linear','doPCs',true,'numNulls',10,...
                    'numFolds',10,'numRepeats',10,'seedReset','none');

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


%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% Filter by a given time point
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
tsCell = {'ts1','ts2','ts3','ts4'};
doFiltering = false; % only need to do this once:
for i = 1:length(tsCell)
    theTS = tsCell{i};
    if doFiltering
        % Make new HCTSA files by filtering
        IDs_tsX = TS_getIDs(theTS,rawData,'ts');
        filteredFileName = sprintf('HCTSA_%s.mat',theTS);
        TS_FilterData(rawData,IDs_tsX,[],filteredFileName);
        normalizedData = TS_normalize(whatNormalization,[0.5,1],filteredFileName,true);
    end
    fprintf(1,'\n\n TIME POINT %s \n\n\n',theTS);
    TS_classify(normalizedData,'svm_linear',false,true)
end

%-------------------------------------------------------------------------------
% Filter by a given time point
tsCell_BL = {'ts2','ts3','ts4'};
doFiltering = false; % (only needs to be done once)
for i = 1:length(tsCell_BL)
    theTS_BL = tsCell_BL{i};
    if doFiltering
        IDs_tsX = TS_getIDs(theTS_BL,'HCTSA_baselineSub.mat','ts');
        filteredFileName = sprintf('HCTSA_baselineSub_%s.mat',theTS_BL);
        TS_FilterData('HCTSA_baselineSub.mat',IDs_tsX,[],filteredFileName);
        normalizedFileName = TS_normalize(whatNormalization,[0.5,1],filteredFileName,true);
    else
        normalizedFileName = sprintf('HCTSA_baselineSub_%s_N.mat',theTS_BL);
    end
    TS_classify(normalizedFileName,'svm_linear',false,true)
end

%-------------------------------------------------------------------------------
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
whatStatistic = 'fast_linear'; % fast linear classification rate statistic

TS_TopFeatures('HCTSA_baselineSub_ts2.mat',whatStatistic,'numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'});

%-------------------------------------------------------------------------------
%% Investigate particular individual features in some more detail
annotateParams = struct('maxL',1000);
featureID = 1078; % 411
TS_FeatureSummary(featureID,unnormalizedData,true,annotateParams)
