% Compute a set of reduced features:
[prePath,rawData,rawDataBL,normData,normDataBL] = Foreplay('right','none',false,false);
distThreshold = 0.2;
reducedIDs = TS_ReduceFeatureSet(normData,distThreshold);
save(fullfile('Data','clusterInfo_Spearman_rightCTX_02.mat'),'reducedIDs');
