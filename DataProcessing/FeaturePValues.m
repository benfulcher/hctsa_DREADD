function [pVals,FDR_qvals] = FeaturePValues(hctsaData)

%-------------------------------------------------------------------------------
% Compute all ranksum p-values:
%-------------------------------------------------------------------------------
numOps = length(hctsaData.Operations);
isG1 = ([hctsaData.TimeSeries.Group]==1);
isG2 = ([hctsaData.TimeSeries.Group]==2);
pVals = zeros(numOps,1);
fprintf(1,'Computing exact ranksum p-values across %u features\n',numOps);
parfor i = 1:numOps
    f1 = hctsaData.TS_DataMat(isG1,i);
    f2 = hctsaData.TS_DataMat(isG2,i);
    pVals(i) = ranksum(f1,f2,'method','exact');
end
FDR_qvals = mafdr(pVals,'BHFDR','true');
isSig = (FDR_qvals < 0.05);
sigInd = find(isSig);
fprintf(1,'%u significant at 5%% FDR\n',length(sigInd));
[~,ix] = sort(FDR_qvals,'ascend');
for i = 1:length(sigInd)
    ind = ix(i);
    fprintf(1,'[%u]%s(%s): q = %.3g\n',hctsaData.Operations(ind).ID,...
            hctsaData.Operations(ind).Name,hctsaData.Operations(ind).Keywords,...
            FDR_qvals(ind));
end

end
