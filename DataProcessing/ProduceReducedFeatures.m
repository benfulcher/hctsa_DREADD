function fileNameSave = ProduceReducedFeatures()
% Reduce the number of hctsa features down to a manageable size

leftOrRight = 'right';
distThreshold = 0.2; % threshold for forming clusters
whatAnalysis = 'Excitatory_SHAM';

switch whatAnalysis
case 'Excitatory_SHAM'
    fileNameSave = 'clusterInfo_Spearman_rightCTX_ExcitatorySham_baselineSub_norm_02.mat';
case 'PVCre_SHAM';
    fileNameSave = 'clusterInfo_Spearman_rightCTX_PVCre_SHAM_baselineSub_norm_02.mat';
end

%-------------------------------------------------------------------------------
% Get info:
[prePath,rawData] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
normData = sprintf('%s_baselineSub_N.mat',rawData(1:end-4));

% Compute a set of reduced features:
reducedIDs = TS_ReduceFeatureSet(normData,distThreshold);
save(fullfile('Data',fileNameSave),'reducedIDs');

end
