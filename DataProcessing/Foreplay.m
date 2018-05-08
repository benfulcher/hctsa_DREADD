function [prePath,rawData,rawDataBL,normData,normDataBL] = Foreplay(leftOrRight,plusPVCre,whatNormalization,labelByMouse,doCluster)
% Do the pre-processing ready to go

if nargin < 1
    leftOrRight = 'control';
end
if nargin < 2
    plusPVCre = false;
end
if nargin < 3
    whatNormalization = 'scaledRobustSigmoid'; % 'zscore', 'scaledRobustSigmoid'
end
if nargin < 4
    labelByMouse = false;
end
if nargin < 5
    doCluster = true;
end
classVarFilter = true;
filterOpt = [0.5,1];

%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);

%-------------------------------------------------------------------------------
% Label all time series:
LabelDREADDSGroups(labelByMouse,leftOrRight,rawDataBL);

%-------------------------------------------------------------------------------
% Normalize the full data & baseline-subtracted data, filtering out features with any special values:
normData = TS_normalize(whatNormalization,filterOpt,rawData,classVarFilter);
normDataBL = TS_normalize(whatNormalization,filterOpt,rawDataBL,classVarFilter);

%-------------------------------------------------------------------------------
% Cluster:
if doCluster
    TS_cluster('euclidean','average','corr_fast','average',[true,true],normDataBL);
end

end
