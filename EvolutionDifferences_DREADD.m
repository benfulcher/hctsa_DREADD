function EvolutionDifferences_DREADD(leftOrRight,whatFeatures)
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Inputs:
if nargin < 1
    leftOrRight = 'control';
end
if nargin < 2
    whatFeatures = 'reduced'; % 'reduced', 'all'
end
% Other settings:
whatCorr = 'Pearson'; % for computing correlations through time

%-------------------------------------------------------------------------------
% Processing:
%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);
keepWhat = {'excitatory','SHAM'};
for k = 1:2
    keepWhat_k = keepWhat{k};

    % Get reduced time series / feature IDs:
    IDs_sub = TS_getIDs(keepWhat_k,rawData,'ts');
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Reduced feature set!!\n');
        IDs_features = load(fullfile('Data','clusterInfo_Spearman_rightCTX_02.mat'),'reducedIDs');
        IDs_features = IDs_features.reducedIDs;
    else
        IDs_features = [];
    end

    % Do the filtering:
    filteredFileName = sprintf('%s_%s_%s.mat',rawData(1:end-4),whatFeatures,keepWhat_k);
    TS_FilterData(rawData,IDs_sub,IDs_features,filteredFileName);
    LabelDREADDSGroups(true,leftOrRight,filteredFileName);
    % TS_LabelGroups(filteredFileName,{'ts1','ts2','ts3','ts4'});
end

%-------------------------------------------------------------------------------
% Do a regression through time:
%-------------------------------------------------------------------------------
files = cell(2,1);
for k = 1:2
    files{k} = sprintf('%s_%s_%s.mat',rawData(1:end-4),whatFeatures,keepWhat{k});
end
load(files{1},'Operations','groupNames');
numFeatures = length(Operations);
numMiceTot = length(groupNames);
corrs = zeros(numFeatures,2,numMiceTot);
for k = 1:2
    load(files{k},'TS_DataMat','TimeSeries','Operations','groupNames');
    numMice = length(groupNames);
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
    % numFeatures = length(Operations);
    for j = 1:numFeatures
        for l = 1:numMice
            isMouse_l = ([TimeSeries.Group]==l);
            if l==numMice && k==2
                warning('SHAM has one fewer mouse')
                corrs(j,k,l) = NaN;
            else
                corrs(j,k,l) = corr(theTime(isMouse_l),TS_DataMat(isMouse_l,j),...
                                    'type',whatCorr,'rows','pairwise');
            end
        end
    end
end
corrsMean = squeeze(nanmean(corrs,3));

%-------------------------------------------------------------------------------
% PLOT the distributions for sham and excitatory:
f = figure('color','w'); hold on
h_e = histogram(corrsMean(:,1),'normalization','pdf');
reds = BF_getcmap('reds',5,0); h_e.FaceColor = reds(end-1,:);
h_s = histogram(corrsMean(:,2),'normalization','pdf');
blues = BF_getcmap('blues',5,0); h_s.FaceColor = blues(end-1,:);
legend([h_e,h_s],'Excitatory','SHAM')
xlabel(sprintf('%s correlation with time',whatCorr))
ylabel('Probability density')
title(leftOrRight)
f.Position = [1064,528,431,254];
keyboard

%===============================================================================
return
%===============================================================================

%===============================================================================
%===============================================================================
whatNormalization = 'scaledSigmoid';
filterSetting = [0.5,1]; % for filtering data/features
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

end
