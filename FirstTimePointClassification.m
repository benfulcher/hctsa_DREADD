function FirstTimePointClassification()
%-------------------------------------------------------------------------------
% 1. Classification at each region at POST1 (relative to baseline)
%-------------------------------------------------------------------------------

regionLabels = {'right','left','control'};
numRegions = length(regionLabels);

% Pre-processing:
preProcessAgain = true;
normalizeDataHow = 'scaledRobustSigmoid';

theTS = 'ts2-BL'; % first time point (subtracting baseline)
whatFeatures = 'reduced'; % 'reduced','all'
theClassifier = 'svm_linear';

% Cross-validation machine learning parameters:
numFolds = 10;
numRepeats = 100;
numNulls = 5000;

%-------------------------------------------------------------------------------
foldLosses = cell(numRegions,1);
nullStat = cell(numRegions,1);
meanAcc = zeros(numRegions,2); % real, null
stdAcc = zeros(numRegions,2); % real, null
pVals = zeros(numRegions,1);
for k = 1:numRegions
    if preProcessAgain
        % Make new HCTSA files from scratch, by filtering
        labelByMouse = false;
        [prePath,rawData,rawDataBL,normData,normDataBL] = Foreplay(regionLabels{k},normalizeDataHow,labelByMouse,false);
        IDs_tsX = TS_getIDs(theTS(1:3),rawDataBL,'ts');
        filteredFileName = fullfile(prePath,sprintf('HCTSA_%s.mat',theTS));
        TS_FilterData(rawData,IDs_tsX,[],filteredFileName);
        dataFile = TS_normalize(normalizeDataHow,[0.5,1],filteredFileName,true);
    else
        % Data already processed (e.g., from IndividualTimePoint)
        [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(regionLabels{k});
        dataFile = fullfile(prePath,sprintf('HCTSA_%s_N.mat',theTS));
    end
    fprintf(1,'Loading data from %s\n',dataFile);
    loadedData = load(dataFile);
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Restricting to a reduced feature set!!\n');
        normalizedData = FilterReducedSet(loadedData);
    else
        normalizedData = loadedData;
    end
    fprintf(1,'\n\n %s -- TIME POINT %s \n\n\n',regionLabels{k},theTS);
    [foldLosses{k},nullStat{k}] = TS_classify(normalizedData,theClassifier,'numPCs',0,'numNulls',numNulls,...
                        'numFolds',numFolds,'numRepeats',numRepeats,'seedReset','none');
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
% P-values relative to null:
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
f = figure('color','w'); ax = gca; hold on
errorbar(meanAcc(:,1),stdAcc(:,1),'ok','LineWidth',2)
errorbar(meanAcc(:,2),stdAcc(:,2),'o--','color',ones(1,3)*0.5)
ax.XTick = 1:numRegions;
ax.XTickLabel = regionLabels;
ylabel('Balanced classification accuracy (%)');
xlabel('Brain region');
xlim([0.9,3.1])
title(sprintf('%u-fold, %u repeats, %u nulls',numFolds,numRepeats,numNulls))

end
