function testStatRelativeControl(leftOrRight,whatFeatures)
% Do features that distinguish Excitatory from SHAM match those that distinguish
% PVCre from SHAM?
if nargin < 1
    leftOrRight = 'left';
end
if nargin < 2
    whatFeatures = 'all';
end

doExact = false;
thresholdGood = 0.6;
T = 'ts2-BL';

%-------------------------------------------------------------------------------
regions = {leftOrRight,'control'};
numRegions = length(regions);
conditions = {'Excitatory_SHAM','PVCre_SHAM'};
numConditions = length(conditions);

testStat = cell(numConditions,numRegions);
for j = 1:numConditions
    for k = 1:numRegions
        [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(regions{k},conditions{j},T);
        hctsaData = LoadDataFile(dataTime,whatFeatures); % Since un-normalized, need to throw NaNs into missing data:
        hctsaData.TS_DataMat(hctsaData.TS_Quality > 0) = NaN;
        [~,~,testStat{j,k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
    end
end

%-------------------------------------------------------------------------------
% Plot:
testStatMat = horzcat([testStat{:}]);
labels = {{'ExcitatorySHAMRight'},{'ExcitatorySHAMControl'};{'PVCreSHAMRight'},{'PVCreSHAMControl'}};
labels = [labels{:}];
numLabels = length(labels);

f = figure('color','w');
hold on
plot(testStatMat(:,3),testStatMat(:,4),'.b')
[rControl,pControl] = corr(testStatMat(:,3),testStatMat(:,4),'rows','pairwise','type','Spearman')
plot(testStatMat(:,1),testStatMat(:,2),'.k')
[rRight,pRight] = corr(testStatMat(:,1),testStatMat(:,2),'rows','pairwise','type','Spearman')
axis('square')
fprintf(1,'r = %.2g (%s) and r = %.2g (control)\n',rRight,leftOrRight,rControl);

f = figure('color','w');
xNorm = testStatMat(:,1)-testStatMat(:,3);
yNorm = testStatMat(:,2)-testStatMat(:,4);
plot(xNorm,yNorm,'xk')
[r,p] = corr(xNorm,yNorm,'rows','pairwise','type','Spearman')
title(r)
axis('square')
xlabel('DeltaU Excitatory')
ylabel('DeltaU PVCre')
