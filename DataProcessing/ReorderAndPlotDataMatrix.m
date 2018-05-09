% Idea is to look at the data matrix

% e.g., for ts1 (baseline subtracted and normalized):

theFile = fullfile('HCTSA_RightCTX','HCTSA_baselineSub_ts1_N.mat');

% Cluster columns:
TS_cluster('none','none','','',[true,true],theFile)

% Reorder rows:
load(theFile,'TimeSeries','ts_clust','TS_DataMat');
[~,ix] = sort([TimeSeries.Group]);
dataMatReOrd = TS_DataMat(ix,:);
ordering_1 = BF_ClusterReorder([],pdist(dataMatReOrd([TimeSeries(ix).Group]==1,:)),'average');
ordering_2 = BF_ClusterReorder([],pdist(dataMatReOrd([TimeSeries(ix).Group]==2,:)),'average');
is1 = ix([TimeSeries(ix).Group]==1);
ix([TimeSeries(ix).Group]==1) = is1(ordering_1);
is2 = ix([TimeSeries(ix).Group]==2);
ix([TimeSeries(ix).Group]==2) = is2(ordering_2);
ts_clust.ord = ix;
save(theFile,'ts_clust','-append')
fprintf(1,'Rows ordered by class label\n');

% Plot:
TS_plot_DataMatrix(theFile,'colorGroups',true)
