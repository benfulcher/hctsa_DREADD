%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
leftOrRight = 'control';
% Keep just excitable, or just keep SHAM?:
whatFeatures = 'reduced'; % 'reduced', 'all'
whatNormalization = 'scaledSigmoid';
filterSetting = [0.5,1]; % for filtering data/features
whatCorr = 'Pearson';

%-------------------------------------------------------------------------------
% Processing:
%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);
keepWhat = {'excitatory','SHAM'};
for k = 1:2
    keepWhat_k = keepWhat{k};
    IDs_sub = TS_getIDs(keepWhat_k,rawData,'ts');
    filteredFileName = sprintf('%s_%s_%s.mat',rawData(1:end-4),whatFeatures,keepWhat_k);
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Reduced feature set!!\n');
        IDs_features = load(fullfile('Data','clusterInfo_rightCTX_02.mat'),'reducedIDs');
        IDs_features = IDs_features.reducedIDs;
    else
        IDs_features = [];
    end
    TS_FilterData(rawData,IDs_sub,IDs_features,filteredFileName);
    TS_LabelGroups(filteredFileName,{'ts1','ts2','ts3','ts4'});
end

%-------------------------------------------------------------------------------
% Do a regression through time:
%-------------------------------------------------------------------------------
files = cell(2,1);
for k = 1:2
    files{k} = sprintf('%s_%s_%s.mat',rawData(1:end-4),whatFeatures,keepWhat{k});
end

corrs = zeros(numFeatures,2);
for k = 1:2
    load(files{k},'TS_DataMat','TimeSeries','Operations');
    % Get the ts number out of each time series:
    keywordSplit = regexp({TimeSeries.Keywords},',','split');
    switch leftOrRight
    case 'left'
        timePoint = cellfun(@(x)x{2},keywordSplit,'UniformOutput',false);
    case {'right','control'}
        timePoint = cellfun(@(x)x{3},keywordSplit,'UniformOutput',false);
    end
    theTime = cellfun(@(x)str2num(x(3)),timePoint)';
    % Now regress each feature onto theTime
    numFeatures = length(Operations);
    for j = 1:numFeatures
        corrs(j,k) = corr(theTime,TS_DataMat(:,j),'type',whatCorr,'rows','pairwise');
        % if corrs(j,k)==0
        %     keyboard
        % end
    end
end

%-------------------------------------------------------------------------------
% PLOT IT:
f = figure('color','w'); hold on
h_e = histogram(corrs(:,1),'normalization','pdf');
h_s = histogram(corrs(:,2),'normalization','pdf');
legend([h_e,h_s],'Excitatory','SHAM')
xlabel(sprintf('%s correlation with time',whatCorr))
title(leftOrRight)

%===============================================================================
return
%===============================================================================

%===============================================================================
%===============================================================================
filteredFileNameN = TS_normalize(whatNormalization,filterSetting,filteredFileName,true);
%-------------------------------------------------------------------------------
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
whatStatistic = 'fast_linear'; % fast linear classification rate statistic
TS_TopFeatures(filteredFileName,whatStatistic,...
            'numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'});

% Classify
TS_classify(filteredFileNameN)

%-------------------------------------------------------------------------------
% List top ones:
topN = min(100,length(Operations));
[testStat_sort, ifeat] = sort(abs(corrs(:,1)-corrs(:,2)),'descend'); % bigger is better
doRemove = isnan(testStat_sort) | abs(corrs(:,2))>abs(corrs(:,1));
testStat_sort = testStat_sort(~doRemove);
ifeat = ifeat(~doRemove);
for i = 1:topN
    fprintf(1,'[%u] %s (%s) -- %4.2f\n',Operations(ifeat(i)).ID, ...
            Operations(ifeat(i)).Name,Operations(ifeat(i)).Keywords,testStat_sort(i));
end

%-------------------------------------------------------------------------------
%
annotateParams = struct('maxL',900);
featureID = 3709;
TS_FeatureSummary(featureID,'HCTSA_SHAM.mat',true,annotateParams)
