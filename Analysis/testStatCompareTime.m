% function testStatCompareTime(whatAnalysis,whatFeatures,leftOrRight)
% if nargin < 1
    whatAnalysis = 'Excitatory_SHAM';
% end
% if nargin < 2
    whatFeatures = 'all';
% end
% if nargin < 3
    leftOrRight = 'right';
% end

doExact = true;
thresholdGood = 0.6;

%-------------------------------------------------------------------------------
switch whatAnalysis
case 'Excitatory_SHAM'
    T = {'ts2-BL','ts3-BL','ts4-BL'};
case {'PVCre_SHAM','Excitatory_PVCre'}
    T = {'ts2-BL','ts3-BL'};
end
numTimePoints = length(T);
testStat = cell(numTimePoints,1);
for k = 1:numTimePoints
    numPoints = length(T);
    [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
    hctsaData = LoadDataFile(dataTime,whatFeatures); % Since un-normalized, need to throw NaNs into missing data:
    hctsaData.TS_DataMat(hctsaData.TS_Quality > 0) = NaN;
    [~,~,testStat{k}] = FeaturePValues(hctsaData,thresholdGood,doExact);
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


% end
