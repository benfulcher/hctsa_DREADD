% Script to reduce the number of features down to a manageable size
leftOrRight = 'right';
whatAnalysis = 'Excitatory_SHAM';
distThreshold = 0.2; % threshold for forming clusters

%-------------------------------------------------------------------------------
% Get info:
prePath = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
normData = fullfile(prePath,sprintf('%s_N.mat',rawData(1:end-4));

% Compute a set of reduced features:
reducedIDs = TS_ReduceFeatureSet(normData,distThreshold);
save(fullfile('Data','clusterInfo_Spearman_rightCTX_02.mat'),'reducedIDs');
