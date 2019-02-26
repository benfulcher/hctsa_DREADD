function [pVal,pValCorr,testStat] = FeaturePValues(hctsaData,thresholdGood,doExact,correctHow)
% Compute p-value for each feature for group difference.
%-------------------------------------------------------------------------------
if nargin < 2
    thresholdGood = 0.6;
    % Both groups need at least this many finite values to compute a statistic
end
if nargin < 3
    doExact = true;
end
if nargin < 4
    correctHow = 'FDR';
end
%-------------------------------------------------------------------------------

if ischar(hctsaData)
    hctsaData = load(hctsaData);
end

% Output:
numOps = height(hctsaData.Operations);
if doExact
    fprintf(1,'Computing exact ranksum p-values across %u features\n',numOps);
else
    fprintf(1,'Computing approximate ranksum p-values across %u features\n',numOps);
end

%-------------------------------------------------------------------------------
% Compute all ranksum p-values:
%-------------------------------------------------------------------------------
isG1 = (hctsaData.TimeSeries.Group==1);
isG2 = (hctsaData.TimeSeries.Group==2);
pVal = nan(numOps,1);
testStat = nan(numOps,1);
parfor i = 1:numOps
    f1 = hctsaData.TS_DataMat(isG1,i);
    f2 = hctsaData.TS_DataMat(isG2,i);
    meanGood = [mean(isfinite(f1)),mean(isfinite(f2))];
    if all(meanGood > thresholdGood)
        if doExact
            [pVal(i),~,stats] = ranksum(f1,f2,'method','exact');
        else
            [pVal(i),~,stats] = ranksum(f1,f2);
        end
        % Normalized Mann-Whitney U test (given the sample size may change across features)
        n1 = length(f1);
        n2 = length(f2);
        testStat(i) = (stats.ranksum - n1*(n1+1)/2)/n1/n2; % normalized uStat
    else
        fprintf(1,'Too many bad values for %s\n',hctsaData.Operations.Name{i});
    end
end

%-------------------------------------------------------------------------------
% Correct:
switch correctHow
case 'FDR'
    pValCorr = mafdr(pVal,'BHFDR','true');
case 'BonfHolm'
    pValCorr = bonf_holm(pVal);
end

%-------------------------------------------------------------------------------
% List out:
isSig = (pValCorr < 0.05);
numSig = sum(isSig);
fprintf(1,'%u/%u significant at 5%% FDR\n',numSig,sum(~isnan(pVal)));
[~,ix] = sort(pVal,'ascend');
N = max(150,numSig); % List at least 20, and if more, all significant (corrected)
for i = 1:N
    ind = ix(i);
    fprintf(1,'[%u]%s(%s): p = %.3g, pcorr = %.3g\n',hctsaData.Operations.ID(ind),...
            hctsaData.Operations.Name{ind},hctsaData.Operations.Keywords{ind},...
            pVal(ind),pValCorr(ind));
end

end
