% Investigating insula data
%-------------------------------------------------------------------------------

theData = fullfile('HCTSA_Insula','HCTSA.mat');

%-------------------------------------------------------------------------------
% Relabel:
TS_LabelGroups(theData,{'wtFMR','koFMR'},true,true);
% -> HCTSA_FMR.mat
TS_LabelGroups(theData,{'wtCNT','koCNT'},true,true);
% -> HCTSA_CNT.mat

%-------------------------------------------------------------------------------
% Specific analysis:
FMRorCNT = 'FMR';
switch FMRorCNT
case 'FMR'
    filteredData = fullfile('HCTSA_Insula','HCTSA_FMR.mat');
case 'CNT'
    filteredData = fullfile('HCTSA_Insula','HCTSA_CNT.mat');
end

% Normalize:
filteredData = load(filteredData);
normalizedData = TS_normalize('scaledRobustSigmoid',[0.5,1],filteredData,true);

%===============================================================================
%===============================================================================

%-------------------------------------------------------------------------------
% Classify?:
TS_classify(hctsaData,'svm_linear','numPCs',0,'numNulls',200,...
                    'numFolds',2,'numRepeats',10,'seedReset','none');

%-------------------------------------------------------------------------------
%% Generate a low-dimensional projection of the dataset:
numAnnotate = 3; % number of time series to annotate to the plot
userSelects = true; % whether the user can click on time series to manually annotate
timeSeriesLength = 600; % length of time-series segments to annotate
annotateParams = struct('n',numAnnotate,'textAnnotation','none',...
                        'userInput',userSelects,'maxL',timeSeriesLength);
TS_PlotLowDim(hctsaData,'pca',true,'',annotateParams);

%-------------------------------------------------------------------------------
% Compare test statistics:
doExact = true;
correctHow = 'FDR';
thresholdGood = 0.6;

GivePValues = @(x) FeaturePValues(x,thresholdGood,doExact,correctHow);
filteredData.TS_DataMat(filteredData.TS_Quality > 0) = NaN;
[pVal,pValCorr,testStat_Insula] = GivePValues(filteredData);

% For comparison, PVCre–control (right hemisphere):
[prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo('right','Excitatory_SHAM','ts2-BL');
hctsaData_DREADD = LoadDataFile(dataTime);
hctsaData_DREADD.TS_DataMat(hctsaData_DREADD.TS_Quality > 0) = NaN;
[~,~,testStat_DREADD] = GivePValues(hctsaData_DREADD);

f = figure('color','w');
plot(testStat_Insula,testStat_DREADD,'.k')
xlabel('testStatistic--Insula: wtFMR-koFMR')
ylabel('testStatistic--DREADDs, rightSSctx: excitatory-sham')

[r,p] = corr(testStat_Insula,testStat_DREADD,'type','Spearman','rows','pairwise');
