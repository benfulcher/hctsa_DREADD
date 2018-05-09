leftOrRight = 'right';
whatAnalysis = 'PVCre_SHAM'; % 'Excitatory_SHAM', 'PVCre_SHAM'

%===============================================================================
%-------------------------------------------------------------------------------
% Right hemisphere analysis:
%-------------------------------------------------------------------------------
%===============================================================================
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
loadedData = load(sprintf('%s_%s.mat',rawData(1:end-4),theTS));
if strcmp(whatFeatures,'reduced')
    fprintf(1,'Reduced feature set!!\n');
    filteredData = FilterReducedSet(loadedData);
else
    filteredData = loadedData;
end

%-------------------------------------------------------------------------------
% Compute all ranksum p-values for hctsa results in filteredData:
%-------------------------------------------------------------------------------
[pVals,FDR_qvals] = FeaturePValues(filteredData);
isSig = (FDR_qvals < 0.05);
sigInd = find(isSig);
[~,ix] = sort(FDR_qvals,'ascend');
sigInd = ix(1:sum(isSig));

%-------------------------------------------------------------------------------
% features = [16,2198,3718];
% features = [26,2705,3750];
features = [filteredData.Operations(sigInd).ID];
numFeatures = sum(isSig);
isG1 = ([filteredData.TimeSeries.Group]==1);
isG2 = ([filteredData.TimeSeries.Group]==2);
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
    ax = subplot(3,5,i); hold on
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
