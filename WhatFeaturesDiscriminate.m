%===============================================================================
%===============================================================================
% What features are most discriminative:
%===============================================================================
%===============================================================================
rightOrLeft = {'right','left'};
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
numNulls = 0;

ifeat = cell(2,1);
testStat = cell(2,1);
testStat_rand = cell(2,1);
for k = 1:2
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(rightOrLeft{k});
    theTS = 'ts2-BL'; % first time point (subtracting baseline)
    useThisData = fullfile(prePath,sprintf('HCTSA_%s.mat',theTS));
    whatStatistic = 'linear'; % fast linear classification rate statistic
    [ifeat{k},testStat{k},testStat_rand{k}] = TS_TopFeatures(useThisData,whatStatistic,'numFeatures',numFeatures,...
                'numFeaturesDistr',numFeaturesDistr,...
                'whatPlots',{'histogram','distributions','cluster'},...
                'numNulls',numNulls);
end

%-------------------------------------------------------------------------------
% Is the discriminative ability of features correlated between right and left
% hemispheres?:
f = figure('color','w');
plot(testStat{1},testStat{2},'.k');
corr(testStat{1},testStat{2})

%-------------------------------------------------------------------------------
%% Investigate particular individual features in some more detail
annotateParams = struct('maxL',900);
% featureID = 19; % 1827, 19 % RIGHT HEMISPHERE
featureID = 9; % LEFT HEMISPHERE
TS_FeatureSummary(featureID,useThisData,true,annotateParams)
