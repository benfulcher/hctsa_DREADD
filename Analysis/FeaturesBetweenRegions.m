%===============================================================================
%===============================================================================
% Do discriminative features relate to those between brain areas?:
%===============================================================================
%===============================================================================
% Lazy coding:
clear all
%===============================================================================
% Set parameters:
whatAnalysis = 'PVCre_SHAM';
numFeatures = 80; % number of features to include in the pairwise correlation plot
numFeaturesDistr = 16*3; % number of features to show class distributions for
numNulls = 0;
whatFeatures = 'reduced'; %'all','reduced'
whatStatistic = 'ustat'; % fast linear classification rate statistic
%===============================================================================
rightOrLeft = {'right','left','control'};
ifeat = cell(3,1);
testStat = cell(3,1);
testStat_rand = cell(3,1);
theTS = 'ts2-BL'; % first time point (subtracting baseline)
for k = 1:3
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(rightOrLeft{k},whatAnalysis);
    loadedData = load(sprintf('%s_%s.mat',rawData(1:end-4),theTS));
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Using a reduced feature set!!!!\n');
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
% Is the discriminative ability of features correlated between right and left
% hemispheres?:
f = figure('color','w');
plot(testStat{1},testStat{2},'.k');
[r,p] = corr(testStat{1},testStat{2},'rows','pairwise');
xlabel('Right hemisphere')
ylabel('Left hemisphere')
title(sprintf('%s: r = %.2f, p = %.2g',whatAnalysis,r,p))

%===============================================================================
% What about for PVCre_SHAM and Excitatory_SHAM?:
%===============================================================================
rightOrLeft = 'control';
whatAnalysis = {'Excitatory_SHAM','PVCre_SHAM'};
ifeat = cell(2,1);
testStat = cell(2,1);
for k = 1:2
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(rightOrLeft,whatAnalysis{k});
    loadedData = load(sprintf('%s_%s.mat',rawData(1:end-4),theTS));
    if strcmp(whatFeatures,'reduced')
        fprintf(1,'Using a reduced feature set!!!!\n');
        filteredData = FilterReducedSet(loadedData);
    else
        filteredData = loadedData;
    end
    [ifeat{k},testStat{k}] = TS_TopFeatures(filteredData,whatStatistic,...
                'numTopFeatures',numFeatures,...
                'numFeaturesDistr',numFeaturesDistr,...
                'whatPlots',{},...
                'numNulls',0);
end

%-------------------------------------------------------------------------------
f = figure('color','w');
plot(testStat{1},testStat{2},'.k');
[r,p] = corr(testStat{1},testStat{2},'rows','pairwise');
xlabel(whatAnalysis{1},'interpreter','none')
ylabel(whatAnalysis{2},'interpreter','none')
title(sprintf('%s: r = %.2f, p = %.2g',rightOrLeft,r,p))


%-------------------------------------------------------------------------------
% Save out:
% fileName = sprintf('whatFeaturesDiscriminate_%s_%s_%unulls.mat',whatAnalysis,...
%                             whatStatistic,numNulls)
% save(fileName);
% fprintf(1,'Saved results to %s\n',fileName);

%-------------------------------------------------------------------------------

% %-------------------------------------------------------------------------------
% % Investigate particular individual features in some more detail
% annotateParams = struct('maxL',900);
% % RIGHT HEMISPHERE:
% % featureID = 2198; % 19,3722,1132,1137,2198,1253,923,1827 % RIGHT HEMISPHERE
% featureID = filteredData.Operations(ifeat{1}(3)).ID;
% % featureID = 9; % LEFT HEMISPHERE
% TS_FeatureSummary(featureID,filteredData,true,annotateParams);
