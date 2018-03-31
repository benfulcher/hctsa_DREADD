% Compute a set of reduced features:
[prePath,rawData,rawDataBL,normData,normDataBL] = Foreplay('right','scaledRobustSigmoid',false,false);
distThreshold = 0.2;
reducedIDs = TS_ReduceFeatureSet(normData,distThreshold);
save(fullfile('Data','clusterInfo_rightCTX_02.mat'),'reducedIDs');
