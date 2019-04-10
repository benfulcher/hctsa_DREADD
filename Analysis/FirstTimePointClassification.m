function FirstTimePointClassification(whatAnalysis,whatFeatures,theTimePoint,numNulls)
% Classification at each region at a given time point (Delta 1 by default)
%-------------------------------------------------------------------------------
if nargin < 1
    whatAnalysis = 'Excitatory_SHAM'; % 'Excitatory_SHAM','PVCre_SHAM', 'Excitatory_PVCre'
end
if nargin < 2
    whatFeatures = 'all'; % 'reduced', 'all'
end
if nargin < 3
    theTimePoint = 'ts2-BL'; % First time point (subtracting baseline)
end
if nargin < 4
    numNulls = 50;
end

%-------------------------------------------------------------------------------
regionLabels = {'right','left','control'};
regionLabelsNice = {'right SSctx','left SSctx','VIS ctx'};
numRegions = length(regionLabels);

% Cross-validation machine learning parameters:
theClassifier = 'svm_linear';
numFolds = 10;
numRepeats = 50;

%-------------------------------------------------------------------------------
foldLosses = cell(numRegions,1);
nullStat = cell(numRegions,1);
meanAcc = zeros(numRegions,2); % real, null
stdAcc = zeros(numRegions,2); % real, null
pVals = zeros(numRegions,1);
for k = 1:numRegions
    theRegion = regionLabels{k};
    % Use baseline-removed, normalized data at the default time point:
    [~,~,~,~,dataTimeNorm] = GiveMeLeftRightInfo(theRegion,whatAnalysis,theTimePoint);

    normalizedData = LoadDataFile(dataTimeNorm,whatFeatures);

    fprintf(1,'\n\n %s -- TIME POINT %s \n\n\n',theRegion,theTimePoint);
    [foldLosses{k},nullStat{k}] = TS_classify(normalizedData,theClassifier,...
                        'numPCs',0,'numNulls',numNulls,...
                        'numFolds',numFolds,'numRepeats',numRepeats,...
                        'seedReset','none');
    meanAcc(k,1) = mean(foldLosses{k});
    stdAcc(k,1) = std(foldLosses{k});
    meanAcc(k,2) = mean(nullStat{k});
    stdAcc(k,2) = std(nullStat{k});
    % Not exactly comparing like with like: mean across numRepeats of the true value
    % But I think this is justified -- i.e., in the limit of large numNulls, you
    % will get similar results as if you did the same for each null sample...
    pVals(k) = mean(mean(foldLosses{k}) < nullStat{k});
end

%-------------------------------------------------------------------------------
% Permutation test p-values relative to null:
for k = 1:numRegions
    fprintf(1,'%s (%.2f%%)-- %.3g\n',regionLabels{k},meanAcc(k,1),pVals(k));
end

%-------------------------------------------------------------------------------
% Pairwise p-values:
for k1 = 1:numRegions-1
    for k2 = k1+1:numRegions
        [~,pp] = ttest2(foldLosses{k1},foldLosses{k2},'VarType','Unequal');
        fprintf(1,'(%s,%s): p = %.3g\n',regionLabels{k1},regionLabels{k2},pp);
    end
end

%-------------------------------------------------------------------------------
% Plot:
f = figure('color','w');
ax = gca; hold('on')
% Real:
errorbar(meanAcc(:,1),stdAcc(:,1),'ok','LineWidth',2)
% Null:
plot(1:3,meanAcc(:,2),'--','color',ones(1,3)*0.5)
plot(1:3,meanAcc(:,2)+stdAcc(:,2),':','color',ones(1,3)*0.5)
plot(1:3,meanAcc(:,2)-stdAcc(:,2),':','color',ones(1,3)*0.5)
ax.XTick = 1:numRegions;
ax.XTickLabel = regionLabelsNice;
ylabel('Balanced accuracy (%)');
xlabel('Brain region');
xlim([0.9,3.1])
title(sprintf('%s: %u-fold, %u repeats, %u nulls',whatAnalysis,numFolds,numRepeats,numNulls),...
                                'interpreter','none')
f.Position = [1000,1158,219,180];
ax.YLim = [30,90];
saveas(f,sprintf('ClassificationFigure_%s.svg',whatAnalysis),'svg');

end
