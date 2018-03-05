
%-------------------------------------------------------------------------------
% 1. Classification at each region at POST1 (relative to baseline)
%-------------------------------------------------------------------------------

regionLabels = {'right','left','control'};
numRegions = 3;
preProcessAgain = false;
theTS = 'ts2-BL'; % first time point (subtracting baseline)

numFolds = 10;
numRepeats = 100;
numNulls = 1000;

%-------------------------------------------------------------------------------
meanAcc = zeros(numRegions,2); % real, null
stdAcc = zeros(numRegions,2); % real, null
pVals = zeros(numRegions,1);
for k = 1:numRegions
    if preProcessAgain
        [prePath,rawData,rawDataBL,normDataBL] = Foreplay(leftOrRight,normalizeDataHow,labelByMouse,false);
    else
        [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(regionLabels{k});
    end
    normalizedData = fullfile(prePath,sprintf('HCTSA_%s_N.mat',theTS));
    fprintf(1,'\n\n %s -- TIME POINT %s \n\n\n',regionLabels{k},theTS);
    [foldLosses,nullStat] = TS_classify(normalizedData,'svm_linear','numPCs',0,'numNulls',numNulls,...
                        'numFolds',numFolds,'numRepeats',numRepeats,'seedReset','none');
    meanAcc(k,1) = mean(foldLosses);
    stdAcc(k,1) = std(foldLosses);
    meanAcc(k,2) = mean(nullStat);
    stdAcc(k,2) = std(nullStat);
    % Not exactly comparing like with like: mean across numRepeats of the true value
    % But I think this is justified -- i.e., in the limit of large numNulls, you
    % will get similar results as if you did the same for each null sample...
    pVals(k) = mean(mean(foldLosses) < nullStat);
end

for k = 1:numRegions
    fprintf(1,'%s (%.2f%%)-- %.3g\n',regionLabels{k},meanAcc(k,1),pVals(k));
end

%-------------------------------------------------------------------------------
% Plot:
f = figure('color','w'); ax = gca; hold on
errorbar(meanAcc(:,1),stdAcc(:,1),'ok','LineWidth',2)
errorbar(meanAcc(:,2),stdAcc(:,2),'o--','color',ones(1,3)*0.5)
ax.XTick = 1:numRegions;
ax.XTickLabel = regionLabels;
ylabel('Balanced classification accuracy (%)');
xlabel('Brain region');
xlim([0.9,3.1])
title(sprintf('%u-fold, %u repeats, %u nulls',numFolds,numRepeats,numNulls))

%===============================================================================
%===============================================================================
% What features are most discriminative:
%===============================================================================
%===============================================================================
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo('right');
theTS = 'ts2-BL'; % first time point (subtracting baseline)
useThisData = fullfile(prePath,sprintf('HCTSA_%s.mat',theTS));
numFeatures = 40; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 32; % number of features to show class distributions for
numNulls = 10;
whatStatistic = 'linear'; % fast linear classification rate statistic
TS_TopFeatures(useThisData,whatStatistic,'numFeatures',numFeatures,...
            'numFeaturesDistr',numFeaturesDistr,...
            'whatPlots',{'histogram','distributions','cluster'},...
            'numNulls',numNulls);
