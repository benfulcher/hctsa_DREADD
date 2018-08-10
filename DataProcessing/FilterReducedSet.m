function filteredData = FilterReducedSet(loadedData)

fprintf(1,'Restricting to a reduced feature set!!\n');

% load(fullfile('Data','clusterInfo_HCTSA_rightCTX_4000_0.20.mat'),'autoChosenIDs');
load(fullfile('Data','clusterInfo_Spearman_rightCTX_02.mat'),'reducedIDs');

filteredData = loadedData;
keepMe = ismember([loadedData.Operations.ID],reducedIDs);

filteredData.Operations = loadedData.Operations(keepMe);
filteredData.TS_DataMat = loadedData.TS_DataMat(:,keepMe);
filteredData.TS_Quality = loadedData.TS_Quality(:,keepMe);

end
