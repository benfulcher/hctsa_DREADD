function testStatRelativeControl(leftOrRight,whatFeatures,doExact)
% Do features that distinguish Excitatory from SHAM match those that distinguish
% PVCre from SHAM?
if nargin < 1
    leftOrRight = 'left';
end
if nargin < 2
    whatFeatures = 'all';
end
if nargin < 3
    doExact = false;
end

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
ax = subplot(1,2,1);
hold on
plot([0,1],[0,1],':k')
plot([0,1],ones(1,2)*0.5,'--k')
plot(ones(1,2)*0.5,[0,1],'--k')
plot(testStatMat(:,1),testStatMat(:,2),'.','color',GiveMeColor('injected'))
[rRight,pRight] = corr(testStatMat(:,1),testStatMat(:,2),'rows','pairwise','type','Spearman');
plot(testStatMat(:,3),testStatMat(:,4),'.','color',GiveMeColor('control'))
[rControl,pControl] = corr(testStatMat(:,3),testStatMat(:,4),'rows','pairwise','type','Spearman');
axis('square')
ax.XLim = [0,1];
ax.XTick = 0:0.25:1;
ax.YLim = [0,1];
ax.YTick = 0:0.25:1;
fprintf(1,'r = %.2g (%s) and r = %.2g (control)\n',rRight,leftOrRight,rControl);
xlabel('U-Excitatory-SHAM')
ylabel('U-PVCre-SHAM')

ax = subplot(1,2,2);
box('off')
hold on
xNorm = testStatMat(:,1)-testStatMat(:,3);
yNorm = testStatMat(:,2)-testStatMat(:,4);
plot([min(xNorm),max(xNorm)],[min(yNorm),max(yNorm)],'--k')
plot([min(xNorm),max(xNorm)],zeros(1,2),'--k')
plot(zeros(1,2),[min(yNorm),max(yNorm)],'--k')
plot(xNorm,yNorm,'.','color',GiveMeColor('injected'))
[r,p] = corr(xNorm,yNorm,'rows','pairwise','type','Spearman');
title(r)
ax.XLim = [min(xNorm),max(xNorm)];
ax.YLim = [min(yNorm),max(yNorm)];
axis('square')
xlabel('Excitatory: U(injected)-U(control)')
ylabel('PVCre: U(injected)-U(control)')

f.Position(3:4) = [950   400];
keyboard

end
