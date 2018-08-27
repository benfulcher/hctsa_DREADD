% Do features that distinguish Excitatory from SHAM match those that distinguish
% PVCre from SHAM?
% if nargin < 1
    whatFeatures = 'all';
% end
% if nargin < 2
    leftOrRight = 'right';
% end

doExact = true;
thresholdGood = 0.6;

%-------------------------------------------------------------------------------
conditions = {'Excitatory_SHAM','PVCre_SHAM'};
numConditions = length(conditions);
T = {'ts2-BL','ts3-BL'};
numTimePoints = length(T);
testStat = cell(numConditions,numTimePoints);
for j = 1:numConditions
    for k = 1:numTimePoints
        [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
        hctsaData = LoadDataFile(dataTime,whatFeatures); % Since un-normalized, need to throw NaNs into missing data:
        hctsaData.TS_DataMat(hctsaData.TS_Quality > 0) = NaN;
        [~,~,testStat{k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
    end
end

testStatMat = horzcat([testStat{:}]);

f = figure('color','w');
[S,AX,BigAx,H,HAx] = plotmatrix(testStatMat);
for i = 1:numTimePoints
    AX(i,1).YLabel.String = T{i};
    AX(numTimePoints,i).XLabel.String = T{i};
    for j = 1:i
        if j<i
            [r,p] = corr(testStatMat(:,[i,j]),'rows','pairwise','type','Spearman')
            text(AX(i,j),0.1,0.8,sprintf('r = %.2g',r(1,2)));
            text(AX(i,j),0.1,0.9,sprintf('p = %.2g',p(1,2)));
        end
    end
end
for i = 1:numTimePoints
    for j = 1:numTimePoints
        AX(i,j).XLim = [0,1];
        if i~=j
            AX(i,j).YLim = [0,1];
        end
    end
end

% end
