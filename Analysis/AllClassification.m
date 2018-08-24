% Script for computing all classification results

whatFeatureSet = 'all'; % 'all', 'reduced'

whatClasses = {'Excitatory_SHAM','PVCre_SHAM','Excitatory_PVCre'};
theTimePoint = 'ts2-BL'; % Delta 1
numNulls = 1000;
numClasses = length(whatClasses);

%-------------------------------------------------------------------------------
for k = 1:numClasses
    theClasses = whatClasses{k};
    FirstTimePointClassification(theClasses,whatFeatureSet,'ts2-BL',numNulls)
end
