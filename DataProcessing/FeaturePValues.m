function [pVals,FDR_qvals] = FeaturePValues(hctsaData,thresholdGood,doExact)
% Compute p-value for each feature for group difference.
%-------------------------------------------------------------------------------

if nargin < 2
    thresholdGood = 0.6;
    % Both groups need at least this many finite values to compute a statistic
end
if nargin < 3
    doExact = true;
end
%-------------------------------------------------------------------------------

% Output:
numOps = length(hctsaData.Operations);
if doExact
    fprintf(1,'Computing exact ranksum p-values across %u features\n',numOps);
else
    fprintf(1,'Computing approximate ranksum p-values across %u features\n',numOps);
end

%-------------------------------------------------------------------------------
% Compute all ranksum p-values:
%-------------------------------------------------------------------------------
isG1 = ([hctsaData.TimeSeries.Group]==1);
isG2 = ([hctsaData.TimeSeries.Group]==2);
pVals = zeros(numOps,1);
parfor i = 1:numOps
    f1 = hctsaData.TS_DataMat(isG1,i);
    f2 = hctsaData.TS_DataMat(isG2,i);
    meanGood = [mean(isfinite(f1)),mean(isfinite(f2))];
    if all(meanGood > thresholdGood)
        if doExact
            pVals(i) = ranksum(f1,f2,'method','exact');
        else
            pVals(i) = ranksum(f1,f2);
        end
    else
        fprintf(1,'Too many bad values for %s\n',hctsaData.Operations(i).Name);
        pVals(i) = NaN;
    end
end
FDR_qvals = mafdr(pVals,'BHFDR','true');

%-------------------------------------------------------------------------------
% List out:
isSig = (FDR_qvals < 0.05);
numSig = sum(isSig);
fprintf(1,'%u significant at 5%% FDR\n',numSig);
[~,ix] = sort(FDR_qvals,'ascend');
N = max(20,numSig); % List at least 20, and if more, all significant (corrected)
for i = 1:N
    ind = ix(i);
    fprintf(1,'[%u]%s(%s): q = %.3g\n',hctsaData.Operations(ind).ID,...
            hctsaData.Operations(ind).Name,hctsaData.Operations(ind).Keywords,...
            FDR_qvals(ind));
end

end
