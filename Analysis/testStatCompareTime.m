function testStatCompareTime(whatAnalysis,leftOrRight,whatFeatures)
if nargin < 1
    whatAnalysis = 'Excitatory_SHAM';
end
if nargin < 2
    leftOrRight = 'right';
end
if nargin < 3
    whatFeatures = 'all';
end

doExact = false;
thresholdGood = 0.6;

%-------------------------------------------------------------------------------
switch whatAnalysis
case 'Excitatory_SHAM'
    T = {'ts2-BL','ts3-BL','ts4-BL'};
    T_alt = {'Delta1','Delta2','Delta3'};
case {'PVCre_SHAM','Excitatory_PVCre'}
    T = {'ts2-BL','ts3-BL'};
    T_alt = {'Delta1','Delta2'};
end
numTimePoints = length(T);
testStat = cell(numTimePoints,1);
for k = 1:numTimePoints
    numPoints = length(T);
    [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
    hctsaData = LoadDataFile(dataTime,whatFeatures);
    [~,~,testStat{k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
end

testStatMat = horzcat([testStat{:}]);

f = figure('color','w');
[S,AX,BigAx,H,HAx] = plotmatrix(testStatMat);
for i = 1:numTimePoints
    AX(i,1).YLabel.String = T_alt{i};
    AX(numTimePoints,i).XLabel.String = T_alt{i};
    for j = 1:numTimePoints
        if j<i
            S(i,j).Color = 'k';
            [r,p] = corr(testStatMat(:,[i,j]),'rows','pairwise','type','Spearman');
            text(AX(i,j),0.1,0.85,sprintf('r_s = %.2g',r(1,2)));
            % text(AX(i,j),0.1,0.9,sprintf('p = %.2g',p(1,2)));
        else
            delete(AX(i,j));
        end
    end
end
for i = 1:numTimePoints
    H(i).FaceColor = 'w';
    H(i).EdgeColor = 'k';
    HAx(i).XLim = [0,1];
    if i==numTimePoints
        HAx(i).XTick = [0,0.5,1];
        HAx(i).XTickLabel = [0,0.5,1];
        HAx(i).XLabel.String = T_alt{i};
    end
    for j = 1:numTimePoints
        if j<i
            AX(i,j).XLim = [0,1];
            Ax(i,j).XTick = [0,0.5,1];
            AX(i,j).YLim = [0,1];
            Ax(i,j).YTick = [0,0.5,1];
        end
    end
end
f.Position(3:4) = [500,440];

end
