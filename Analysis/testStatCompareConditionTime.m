function testStatCompareConditionTime(leftOrRight,whatFeatures)
% Do features that distinguish Excitatory from SHAM match those that distinguish
% PVCre from SHAM?
%-------------------------------------------------------------------------------
if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    whatFeatures = 'all';
end

doExact = false;
thresholdGood = 0.6;

%-------------------------------------------------------------------------------
conditions = {'Excitatory_SHAM','PVCre_SHAM'};
numConditions = length(conditions);
T = {'ts2-BL','ts3-BL'};
numTimePoints = length(T);
testStat = cell(numConditions,numTimePoints);
for j = 1:numConditions
    whatAnalysis = conditions{j};
    for k = 1:numTimePoints
        [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
        hctsaData = LoadDataFile(dataTime,whatFeatures); % Since un-normalized, need to throw NaNs into missing data:
        hctsaData.TS_DataMat(hctsaData.TS_Quality > 0) = NaN;
        [~,~,testStat{j,k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
    end
end

%-------------------------------------------------------------------------------
% Plot:
testStatMat = horzcat([testStat{:}]);
labels = {{'ExcitatorySHAMDelta1'},{'ExcitatorySHAMDelta2'};{'PVCreSHAMDelta1'},{'PVCreSHAMDelta2'}};
labels = [labels{:}];
numLabels = length(labels);

f = figure('color','w');
[S,AX,BigAx,H,HAx] = plotmatrix(testStatMat);
for i = 1:numLabels
    AX(i,1).YLabel.String = labels{i};
    AX(numLabels,i).XLabel.String = labels{i};
    for j = 1:numLabels
        if j<i
            S(i,j).Color = 'k';
            [r,p] = corr(testStatMat(:,[i,j]),'rows','pairwise','type','Spearman');
            text(AX(i,j),0.1,0.8,sprintf('r = %.2g',r(1,2)));
            text(AX(i,j),0.1,0.9,sprintf('p = %.2g',p(1,2)));
        else
            delete(AX(i,j));
        end
    end
end
for i = 1:numLabels
    H(i).FaceColor = 'w';
    H(i).EdgeColor = 'k';
    HAx(i).XLim = [0,1];
    if i==numLabels
        HAx(i).XTick = [0,0.5,1];
        HAx(i).XTickLabel = [0,0.5,1];
        HAx(i).XLabel.String = labels{i};
    end
    for j = 1:numLabels
        if j<i
            AX(i,j).XLim = [0,1];
            Ax(i,j).XTick = [0,0.5,1];
            AX(i,j).YLim = [0,1];
            Ax(i,j).YTick = [0,0.5,1];
        end
    end
end
f.Position(3:4) = [750,680];

end
