function [fIDs,FDR_qvals] = ConsensusFeatures(whatAnalysis,leftOrRight,whatFeatures)
% Search for features that are similarly discriminative across multiple time points
%-------------------------------------------------------------------------------
if nargin < 1
    whatAnalysis = 'Excitatory_PVCre'; % Excitatory_SHAM, PVCre_SHAM
end
if nargin < 2
    leftOrRight = 'right';
end
if nargin < 3
    whatFeatures = 'all';
end

thresholdGood = 0.6;
doExact = true;

%-------------------------------------------------------------------------------
% Load data:
%-------------------------------------------------------------------------------
switch whatAnalysis
case 'Excitatory_SHAM'
    T = {'ts2-BL','ts3-BL','ts4-BL'};
case {'PVCre_SHAM','Excitatory_PVCre'}
    T = {'ts2-BL','ts3-BL'};
end
numPoints = length(T);
theData = cell(numPoints,1);
for k = 1:numPoints
    [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
    theData{k} = LoadDataFile(dataTime,whatFeatures);
    % Since un-normalized, need to throw NaNs into missing data:
    theData{k}.TS_DataMat(theData{k}.TS_Quality > 0) = NaN;
end

%-------------------------------------------------------------------------------
% Compute p-values
%-------------------------------------------------------------------------------
pVals = cell(numPoints,1);
for k = 1:numPoints
    [pVals{k},~] = FeaturePValues(theData{k},thresholdGood,doExact);
end

% Match features:
% (already matched)

%-------------------------------------------------------------------------------
% Combine p-values using Fisher:
%-------------------------------------------------------------------------------
numFeatures = length(pVals{1});
pValsComb = zeros(numFeatures,1);
for i = 1:numFeatures
    pHere = cellfun(@(x)x(i),pVals);
    % pHere = [pVals1(i),pVals2(i),pVals3(i)];
    if any(isnan(pHere))
        pValsComb(i) = NaN;
    else
        chi_vals = -2.*log(pHere);
        pValsComb(i) = 1 - chi2cdf(sum(chi_vals),2*length(pHere));
    end
end
notBad = ~isnan(pValsComb);
fprintf(1,'%u features contained bad values\n',sum(~notBad));

pValsComb = pValsComb(notBad);
myOperations = theData{1}.Operations(notBad);

% Correct Fisher-combined p-values:
FDR_qvals = mafdr(pValsComb,'BHFDR','true');
fIDs = [myOperations.ID];
[~,ix] = sort(FDR_qvals,'ascend');

%-------------------------------------------------------------------------------
% List out:
isSig = (FDR_qvals < 0.05);
numSig = sum(isSig);
fprintf(1,'%u significant at 5%% FDR\n',numSig);
[~,ix] = sort(FDR_qvals,'ascend');
N = max(20,numSig); % List at least 20, and if more, all significant (corrected)
N = min(200,N);
for i = 1:N
    ind = ix(i);
    fprintf(1,'[%u]%s(%s): q = %.3g\n',myOperations(ind).ID,...
            myOperations(ind).Name,myOperations(ind).Keywords,...
            FDR_qvals(ind));
end

%-------------------------------------------------------------------------------
% Plot one?:
PlotConsensus(myOperations(ix(1)).ID,whatAnalysis,leftOrRight,whatFeatures)

end
