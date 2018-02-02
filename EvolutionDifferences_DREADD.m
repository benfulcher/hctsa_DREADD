
% Keep just excitable:
keepWhat = 'SHAM'; % 'SHAM', 'excitatory'
IDs_sub = TS_getIDs(keepWhat,'HCTSA.mat','ts');
filteredFileName = sprintf('HCTSA_%s.mat',keepWhat);
TS_FilterData('HCTSA.mat',IDs_sub,[],filteredFileName);
TS_LabelGroups(filteredFileName,{'ts1','ts2','ts3','ts4'})
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
files{1} = 'HCTSA_excitatory.mat';
files{2} = 'HCTSA_SHAM.mat';

corrs = zeros(numFeatures,2);
for i = 1:2
    load(files{i},'TS_DataMat','TimeSeries','Operations');
    % Get the ts number out of each time series:
    keywordSplit = regexp({TimeSeries.Keywords},',','split');
    timePoint = cellfun(@(x)x{3},keywordSplit,'UniformOutput',false);
    theTime = cellfun(@(x)str2num(x(3)),timePoint)';
    % Now regress each feature onto theTime
    numFeatures = length(Operations);
    for j = 1:numFeatures
        corrs(j,i) = corr(TS_DataMat(:,j),theTime,'type','Spearman','rows','pairwise');
    end
end

f = figure('color','w'); hold on
h_e = histogram(corrs(:,1),'normalization','probability');
h_s = histogram(corrs(:,2),'normalization','probability');
legend([h_e,h_s],'Excitatory','SHAM')
xlabel('Spearman correlation with time')
