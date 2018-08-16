function filteredData = FilterReducedSet(loadedData)

% fileWithReducedIDs = 'clusterInfo_Spearman_rightCTX_02.mat';
fileWithReducedIDs = 'clusterInfo_Spearman_rightCTX_ExcitatorySham_baselineSub_norm_02.mat';
% fileWithReducedIDs = 'clusterInfo_Spearman_rightCTX_PVCre_SHAM_baselineSub_norm_02.mat';
load(fullfile('Data',fileWithReducedIDs),'reducedIDs');

filteredData = loadedData;
keepMe = ismember([loadedData.Operations.ID],reducedIDs);

filteredData.Operations = loadedData.Operations(keepMe);
filteredData.TS_DataMat = loadedData.TS_DataMat(:,keepMe);
filteredData.TS_Quality = loadedData.TS_Quality(:,keepMe);

fprintf(1,'Restricted to a reduced feature set, %u -> %u!!\n',length(keepMe),sum(keepMe));

end
