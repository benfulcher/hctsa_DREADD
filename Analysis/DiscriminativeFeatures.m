function [fIDs,pVals,pValCorr] = DiscriminativeFeatures(whatAnalysis,leftOrRight,whatFeatures,theTimePoint)
% What features are most discriminative between conditions in a given area
% at a given time point
%-------------------------------------------------------------------------------

if nargin < 1
    whatAnalysis = 'Excitatory_SHAM'; % 'Excitatory_PVCre_SHAM', 'PVCre_SHAM'
end
if nargin < 2
    leftOrRight = 'right';
end
if nargin < 3
    whatFeatures = 'all';
end
if nargin < 4
    theTimePoint = 'ts2-BL'; % 'ts2-BL' (POST1) 'all-BL' (all POST time points combined)
end

thresholdGood = 0.6;
doExact = true;

%-------------------------------------------------------------------------------
% Prepare data:
% Use baseline-removed, normalized data at the default time point:
[~,~,dataAll,dataTime,dataTimeN] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,theTimePoint);
if strcmp(theTimePoint,'all-BL')
    % normalize?
    theData = dataAll;
    % theData = sprintf('%s_N.mat',dataAll(1:end-4));
else
    theData = dataTime;
end
filteredData = LoadDataFile(theData,whatFeatures);

%-------------------------------------------------------------------------------
% Compute all ranksum p-values for hctsa results in filteredData:
%-------------------------------------------------------------------------------
% numFeatures = 200;
% numFeaturesDistr = 25;
% numNulls = 0;
% whatStatistic = 'ustatExact';
% [ifeat,testStat,testStat_rand] = TS_TopFeatures(filteredData,whatStatistic,...
%             'numTopFeatures',numFeatures,...
%             'numFeaturesDistr',numFeaturesDistr,...
%             'whatPlots',{'histogram','distributions','cluster'},...
%             'numNulls',numNulls);

correctHow = 'FDR';
[pVals,pValCorr,testStat] = FeaturePValues(filteredData,thresholdGood,doExact,correctHow);
fIDs = filteredData.Operations.ID;

% Mark significant features:
isSig = (pValCorr < 0.05);
numFeatures = sum(isSig);
[~,ix] = sort(pValCorr,'ascend');
sigInd = ix(1:numFeatures);

% Plot them:
f = figure('color','w');
histogram(pValCorr)

%-------------------------------------------------------------------------------
% Plot some top ones:
sigFeatures = filteredData.Operations.ID(sigInd);
isG1 = (filteredData.TimeSeries.Group==1);
isG2 = (filteredData.TimeSeries.Group==2);
means = zeros(numFeatures,2);
stds = zeros(numFeatures,2);
f = figure('color','w');
for i = 1:min(15,numFeatures)
    opInd = filteredData.Operations.ID==sigFeatures(i);
    f1 = filteredData.TS_DataMat(isG1,opInd);
    f2 = filteredData.TS_DataMat(isG2,opInd);
    means(i,1) = mean(f1);
    stds(i,1) = std(f1);
    means(i,2) = mean(f2);
    stds(i,2) = std(f2);
    ax = subplot(3,5,i); hold on
    ax.YLabel.Interpreter = 'none';
    plot(means(i,:),'ok','LineWidth',2);
    plot(means(i,:)+stds(i,:),'sk');
    plot(means(i,:)-stds(i,:),'sk');
    plot(ones(2,1)*1,means(i,1)+[-stds(i,1),stds(i,1)],'-k');
    plot(ones(2,1)*2,means(i,2)+[-stds(i,2),stds(i,2)],'-k');
    xlabel('Groups')
    ylabel(sprintf('[%u]%s',filteredData.Operations.ID(opInd),filteredData.Operations.Name{opInd}))
    ax.XTick = 1:2;
    ax.XTickLabel = filteredData.groupNames;
    ax.XLim = [0.5,2.5];
    title(sprintf('p = %.3g, p-corr = %.3g',pVals(opInd),pValCorr(opInd)),'interpreter','none')
end

%-------------------------------------------------------------------------------
% Produce a proper table output to file:
fid = fopen('sigFeatures.txt','w');
fprintf(fid,'featureID | featureName | featureKeywords | pValue | pValueCorr\n');
sigInd = ix(1:numFeatures);
for i = 1:numFeatures
    ind = sigInd(i);
    fprintf(fid,'%u | %s | %s | %.3g | %.3g\n',filteredData.Operations.ID(ind),...
            filteredData.Operations.Name{ind},filteredData.Operations.Keywords{ind},...
            pVals(ind),pValCorr(ind));
end
fclose(fid);

end
