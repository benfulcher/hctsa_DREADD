leftOrRight = 'left';
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);
%-------------------------------------------------------------------------------

% Keep just excitable:
keepWhat = 'excitatory'; % 'SHAM', 'excitatory'
IDs_sub = TS_getIDs(keepWhat,rawData,'ts');
filteredFileName = sprintf('%s_%s.mat',rawData(1:end-4),keepWhat);
TS_FilterData(rawData,IDs_sub,[],filteredFileName);
TS_LabelGroups(filteredFileName,{'ts1','ts2','ts3','ts4'});
filteredFileNameN = TS_normalize(whatNormalization,[0.5,1],filteredFileName,true);
% TS_LabelGroups({'SHAM','DREDD','rsfMRI'},'raw');

%-------------------------------------------------------------------------------
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
whatStatistic = 'fast_linear'; % fast linear classification rate statistic

TS_TopFeatures(filteredFileName,'fast_linear','numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'});

TS_classify(filteredFileNameN)

%-------------------------------------------------------------------------------
% Do a regression for ts number:
files = cell(2,1);
files{1} = fullfile(prePath,'HCTSA_excitatory.mat');
files{2} = fullfile(prePath,'HCTSA_SHAM.mat');

corrs = zeros(numFeatures,2);
for i = 1:2
    load(files{i},'TS_DataMat','TimeSeries','Operations');
    % Get the ts number out of each time series:
    keywordSplit = regexp({TimeSeries.Keywords},',','split');
    switch leftOrRight
    case 'left'
        timePoint = cellfun(@(x)x{2},keywordSplit,'UniformOutput',false);
    case 'right'
        timePoint = cellfun(@(x)x{3},keywordSplit,'UniformOutput',false);
    end
    theTime = cellfun(@(x)str2num(x(3)),timePoint)';
    % Now regress each feature onto theTime
    numFeatures = length(Operations);
    for j = 1:numFeatures
        corrs(j,i) = corr(TS_DataMat(:,j),theTime,'type','Spearman','rows','pairwise');
    end
end

%-------------------------------------------------------------------------------
% PLOT IT:
f = figure('color','w'); hold on
h_e = histogram(corrs(:,1),'normalization','pdf');
h_s = histogram(corrs(:,2),'normalization','pdf');
legend([h_e,h_s],'Excitatory','SHAM')
xlabel('Spearman correlation with time')

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
