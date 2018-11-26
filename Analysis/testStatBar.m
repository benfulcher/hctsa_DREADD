function testStatBar(whatFeatures,doExact)
% Do features that distinguish Excitatory from SHAM match those that distinguish
% PVCre from SHAM?

if nargin < 1
    whatFeatures = 'all';
end
if nargin < 2
    doExact = false;
end

thresholdGood = 0.6;
T = 'ts2-BL';

%-------------------------------------------------------------------------------
regions = {'right','left','control'};
numRegions = length(regions);
conditions = {'Excitatory_SHAM','PVCre_SHAM'};
numConditions = length(conditions);

testStat = cell(numConditions,numRegions);
for j = 1:numConditions
    for k = 1:numRegions
        [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(regions{k},conditions{j},T);
        hctsaData = LoadDataFile(dataTime,whatFeatures);
        % Since un-normalized, need to throw NaNs into missing data:
        hctsaData.TS_DataMat(hctsaData.TS_Quality > 0) = NaN;
        [~,~,testStat{j,k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
    end
end

labels = {{'ExcitatorySHAMRight'},{'ExcitatorySHAMLeft'},{'ExcitatorySHAMControl'}; ...
                    {'PVCreSHAMRight'},{'PVCreSHAMLeft'},{'PVCreSHAMControl'}};
labels = [labels{:}];
testStatMat = horzcat([testStat{:}]);

%-------------------------------------------------------------------------------
% Correlations between different test statistics:
[rRight,pRight] = corr(testStatMat(:,1),testStatMat(:,2),'rows','pairwise','type','Spearman');
[rLeft,pLeft] = corr(testStatMat(:,3),testStatMat(:,4),'rows','pairwise','type','Spearman');
[rControl,pControl] = corr(testStatMat(:,5),testStatMat(:,6),'rows','pairwise','type','Spearman');

% Plot as bar:
f = figure('color','w');
ax = gca();
b = bar([1,2,3],[rRight,rLeft,rControl]);
b.EdgeColor = 'k';
b.FaceColor = 'w';
ax.XTick = 1:3;
ax.XTickLabel = {'right SSctx','left SSctx','VIS ctx'};
ylabel('rho: (wt-hM3Dq, PVCre-hM4Di)');
xlim([0.3,3.7])
f.Position = [784   843   325   217];
% b.FaceColor = 'flat';
% b.CData = [GiveMeColor('injected');GiveMeColor('left');GiveMeColor('control')];
