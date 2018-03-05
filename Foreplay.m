function [prePath,rawData,rawDataBL,normDataBL] = Foreplay(leftOrRight,whatNormalization,labelByMouse,doCluster)
% Do the pre-processing ready to go

if nargin < 1
    leftOrRight = 'control';
end
if nargin < 2
    whatNormalization = 'scaledRobustSigmoid'; % 'zscore', 'scaledRobustSigmoid'
end
if nargin < 3
    labelByMouse = false;
end
if nargin < 4
    doCluster = true;
end

%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight);

%-------------------------------------------------------------------------------
% Label all time series:
LabelDREADDSGroups(labelByMouse,leftOrRight,rawDataBL);

%-------------------------------------------------------------------------------
% Normalize the data, filtering out features with any special values:
normDataBL = TS_normalize(whatNormalization,[0.5,1],rawDataBL,false);

%-------------------------------------------------------------------------------
% Cluster:
if doCluster
    TS_cluster('euclidean','average','corr_fast','average',[true,true],normDataBL);
end

end
