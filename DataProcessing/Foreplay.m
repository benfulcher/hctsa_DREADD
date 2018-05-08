function [prePath,rawData,rawDataBL,normData,normDataBL] = Foreplay(leftOrRight,whatAnalysis,whatNormalization,labelByMouse,doCluster)
% Do the pre-processing ready to go

if nargin < 1
    leftOrRight = 'control';
end
if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
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

% Additional normalization settings:
classVarFilter = true;
filterOpt = [0.5,1];

%-------------------------------------------------------------------------------
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);

%-------------------------------------------------------------------------------
% Label all time series into groups (in raw and baseline-subtracted data):
LabelDREADDSGroups(labelByMouse,leftOrRight,rawData,whatAnalysis);
LabelDREADDSGroups(labelByMouse,leftOrRight,rawDataBL,whatAnalysis);

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
