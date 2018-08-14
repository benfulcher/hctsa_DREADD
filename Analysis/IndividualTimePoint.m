function IndividualTimePoint(leftOrRight,whatAnalysis,subtractBaseline,whatFeatures)
% Compare classifiability across time points for a given brain area
% ^^^Requires running SplitByTimePoint first^^^
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check inputs, set defaults:
%-------------------------------------------------------------------------------
if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    whatAnalysis = 'Excitatory_SHAM'; % 'PVCre_SHAM','Excitatory_PVCre_SHAM'
end
if nargin < 3
    subtractBaseline = true; % (subtract features at baseline)
end
if nargin < 4
    whatFeatures = 'all';
end

labelByMouse = false;

% Classification settings:
theClassifier = 'svm_linear';
numNulls = 50;
numRepeats = 50;
numFolds = 10;

%-------------------------------------------------------------------------------
% Names of time points:
if subtractBaseline
    tsCell = {'ts2-BL','ts3-BL','ts4-BL'};
else
    tsCell = {'ts1','ts2','ts3','ts4'};
end
if strcmp(whatAnalysis,'PVCre_SHAM')
    tsCell = tsCell(1:end-1);
end
numTimePoints = length(tsCell);

%-------------------------------------------------------------------------------
% Filter by time point for a given brain location
%-------------------------------------------------------------------------------
meanAcc = zeros(numTimePoints,2);
for i = 1:numTimePoints
    theTimePoint = tsCell{i};
    fprintf(1,'\n\n TIME POINT %s \n\n\n',theTimePoint);

    [~,~,~,~,normalizedData] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,theTimePoint);
    dataStruct = LoadDataFile(normalizedData,whatFeatures);

    [foldLosses,nullStat] = TS_classify(normalizedData,theClassifier,'numPCs',0,...
                    'numNulls',numNulls,'numFolds',numFolds,...
                    'numRepeats',numRepeats,'seedReset','none');
    meanAcc(i,1) = mean(foldLosses);
    meanAcc(i,2) = mean(nullStat);
end

% Plot trends across time:
f = figure('color','w'); ax = gca; hold('on')
plot(meanAcc(:,1),'o-k');
plot(meanAcc(:,2),'x:b');
ax.XTick = 1:numTimePoints;
ax.XTickLabel = tsCell;
title(sprintf('%s-%s',whatAnalysis,leftOrRight),'interpreter','none')

%===============================================================================
return
return
return
return
%===============================================================================

%-------------------------------------------------------------------------------
% Across multiple hemispheres:
regionLabels = {'left','right','control'};
meanAcc = zeros(3,numTimePoints,2);
stdAcc = zeros(3,numTimePoints,2);
for k = 1:3
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(regionLabels{k});
    for i = 1:length(tsCell)
        theTimePoint = tsCell{i};
        normalizedData = fullfile(prePath,sprintf('HCTSA_%s_N.mat',theTimePoint));
        fprintf(1,'\n\n %s -- TIME POINT %s \n\n\n',regionLabels{k},theTimePoint);
        [foldLosses,nullStat] = TS_classify(normalizedData,'svm_linear','numPCs',0,'numNulls',numNulls,...
                            'numFolds',numFolds,'numRepeats',numRepeats,'seedReset','none');
        meanAcc(k,i,1) = mean(foldLosses);
        stdAcc(k,i,1) = std(foldLosses);
        meanAcc(k,i,2) = mean(nullStat);
        stdAcc(k,i,2) = std(nullStat);
    end
end
% Plot across time:
colors = BF_getcmap('dark2',3,1,true)
f = figure('color','w'); ax = gca; hold('on')
h = cell(4,1);
for k = 1:3
    h{k} = plot(squeeze(meanAcc(k,:,1)),'o-','color',colors{k},'LineWidth',2);
    plot(squeeze(meanAcc(k,:,1))+squeeze(stdAcc(k,:,1)),'--','color',colors{k},'LineWidth',1);
    plot(squeeze(meanAcc(k,:,1))-squeeze(stdAcc(k,:,1)),'--','color',colors{k},'LineWidth',1);
end
h{4} = plot(mean(squeeze(meanAcc(:,:,2)),1),'x:k');
legend([h{:}],{'left','right','control','null'})
ax.XTick = 1:3;
ax.XTickLabel = tsCell;

%===============================================================================
return
return
return
return
%===============================================================================

%-------------------------------------------------------------------------------
% Filter by a given time point
tsCell_BL = {'ts2','ts3','ts4'};
doFiltering = false; % (only needs to be done once)
for i = 1:length(tsCell_BL)
    theTimePoint_BL = tsCell_BL{i};
    if doFiltering
        IDs_tsX = TS_getIDs(theTimePoint_BL,'HCTSA_baselineSub.mat','ts');
        filteredFileName = sprintf('HCTSA_baselineSub_%s.mat',theTimePoint_BL);
        TS_FilterData('HCTSA_baselineSub.mat',IDs_tsX,[],filteredFileName);
        normalizedFileName = TS_normalize(whatNormalization,[0.5,1],filteredFileName,true);
    else
        normalizedFileName = sprintf('HCTSA_baselineSub_%s_N.mat',theTimePoint_BL);
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
