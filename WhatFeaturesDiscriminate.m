%===============================================================================
%===============================================================================
% What features are most discriminative:
%===============================================================================
%===============================================================================
% Lazy coding:
clear all
%===============================================================================
% Set parameters:
rightOrLeft = {'right','left','control'};
numFeatures = 80; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 16*3; % number of features to show class distributions for
numNulls = 0;
whatFeatures = 'reduced'; %'all','reduced'
whatStatistic = 'ustat'; % fast linear classification rate statistic
%===============================================================================

ifeat = cell(3,1);
testStat = cell(3,1);
testStat_rand = cell(3,1);
theTS = 'ts2-BL'; % first time point (subtracting baseline)
for k = 1:3
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(rightOrLeft{k});
    loadedData = load((fullfile(prePath,sprintf('HCTSA_%s.mat',theTS))));
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Reduced feature set!!\n');
        filteredData = FilterReducedSet(loadedData);
    else
        filteredData = loadedData;
    end
    [ifeat{k},testStat{k},testStat_rand{k}] = TS_TopFeatures(filteredData,whatStatistic,...
                'numTopFeatures',numFeatures,...
                'numFeaturesDistr',numFeaturesDistr,...
                'whatPlots',{'histogram','distributions','cluster'},...
                'numNulls',numNulls);
end

%-------------------------------------------------------------------------------
% Save out:
fileName = sprintf('whatFeaturesDiscriminate_%unulls.mat',numNulls)
save(fileName);
fprintf(1,'Saved results to %s\n',fileName);

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
% Is the discriminative ability of features correlated between right and left
% hemispheres?:
f = figure('color','w');
plot(testStat{1},testStat{2},'.k');
[r,p] = corr(testStat{1},testStat{2},'rows','pairwise');
xlabel('Right hemisphere')
ylabel('Left hemisphere')
title(sprintf('r = %.2f',r))

%-------------------------------------------------------------------------------
%% Investigate particular individual features in some more detail
annotateParams = struct('maxL',900);
% RIGHT HEMISPHERE:
featureID = 2198; % 19,3722,1132,1137,2198,1253,923,1827 % RIGHT HEMISPHERE
% featureID = 9; % LEFT HEMISPHERE
TS_FeatureSummary(featureID,filteredData,true,annotateParams)

%===============================================================================
%-------------------------------------------------------------------------------
% Right hemisphere analysis:
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo('right');
loadedData = load((fullfile(prePath,sprintf('HCTSA_%s.mat',theTS))));
if strcmp(whatFeatures,'reduced')
    fprintf(1,'Reduced feature set!!\n');
    filteredData = FilterReducedSet(loadedData);
else
    filteredData = loadedData;
end

%-------------------------------------------------------------------------------
% Compute all p-values **FOR THE DATA CURRENTLY LOADED in filteredData**:
numOps = length(filteredData.Operations);
isG1 = ([filteredData.TimeSeries.Group]==1);
isG2 = ([filteredData.TimeSeries.Group]==2);
pVals = zeros(numOps,1);
parfor i = 1:numOps
    f1 = filteredData.TS_DataMat(isG1,i);
    f2 = filteredData.TS_DataMat(isG2,i);
    pVals(i) = ranksum(f1,f2,'method','exact');
end
% pVals = 10.^(-testStat{k});
FDR_qvals = mafdr(pVals,'BHFDR','true');
isSig = (FDR_qvals < 0.05);
sigInd = find(isSig);
for i = 1:length(sigInd)
    fprintf(1,'[%u]%s: %.3g\n',i,filteredData.Operations(sigInd(i)).Name,FDR_qvals(sigInd(i)));
end

%-------------------------------------------------------------------------------
% (needs filteredData)
features = [16,2198,3718];
numFeatures = length(features);
means = zeros(numFeatures,2);
stds = zeros(numFeatures,2);
f = figure('color','w');
for i = 1:numFeatures
    opInd = [filteredData.Operations.ID]==features(i);
    f1 = filteredData.TS_DataMat(isG1,opInd);
    f2 = filteredData.TS_DataMat(isG2,opInd);
    means(i,1) = mean(f1);
    stds(i,1) = std(f1);
    means(i,2) = mean(f2);
    stds(i,2) = std(f2);
    ax = subplot(1,3,i); hold on
    ax.YLabel.Interpreter = 'none';
    plot(means(i,:),'ok','LineWidth',2);
    plot(means(i,:)+stds(i,:),'sk');
    plot(means(i,:)-stds(i,:),'sk');
    plot(ones(2,1)*1,means(i,1)+[-stds(i,1),stds(i,1)],'-k');
    plot(ones(2,1)*2,means(i,2)+[-stds(i,2),stds(i,2)],'-k');
    xlabel('Groups')
    ylabel(filteredData.Operations(opInd).Name)
    ax.XTick = 1:2;
    ax.XTickLabel = filteredData.groupNames;
    ax.XLim = [0.5,2.5];
    % pVal = ranksum(f1,f2);
    title(sprintf('p = %.3g, p-corr = %.3g',pVals(opInd),FDR_qvals(opInd)),'interpreter','none')
end
