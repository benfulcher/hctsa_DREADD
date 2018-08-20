% ConsensusFeatures
% Search for features that are similarly discriminative across multiple time points
%-------------------------------------------------------------------------------

theData1 = load('HCTSA_RightCTX/HCTSA_ts2-BL.mat');
theData2 = load('HCTSA_RightCTX/HCTSA_ts3-BL.mat');
theData3 = load('HCTSA_RightCTX/HCTSA_ts4-BL.mat');

thresholdGood = 0.6;
doExact = true;
[pVals1,FDR_qvals1] = FeaturePValues(theData1,thresholdGood,doExact);
[pVals2,FDR_qvals2] = FeaturePValues(theData2,thresholdGood,doExact);
[pVals3,FDR_qvals3] = FeaturePValues(theData3,thresholdGood,doExact);

% Match features:
% (already matched)

% Combine p-values using Fisher:
numFeatures = length(pVals1);
pValsComb = zeros(numFeatures,1);
for i = 1:numFeatures
    pHere = [pVals1(i),pVals2(i),pVals3(i)];
    chi_vals = -2.*log(pHere);
    pValsComb(i) = 1 - chi2cdf(sum(chi_vals),2*length(pHere));
end

% Correct Fisher-combined p-values:
FDR_qvals = mafdr(pValsComb,'BHFDR','true');
[~,ix] = sort(FDR_qvals,'ascend');

%-------------------------------------------------------------------------------
% List out:
hctsaData = theData1;
isSig = (FDR_qvals < 0.05);
numSig = sum(isSig);
fprintf(1,'%u significant at 5%% FDR\n',numSig);
[~,ix] = sort(FDR_qvals,'ascend');
N = max(20,numSig); % List at least 20, and if more, all significant (corrected)
N = min(200,numSig);
for i = 100:N
    ind = ix(i);
    fprintf(1,'[%u]%s(%s): q = %.3g\n',hctsaData.Operations(ind).ID,...
            hctsaData.Operations(ind).Name,hctsaData.Operations(ind).Keywords,...
            FDR_qvals(ind));
end

%-------------------------------------------------------------------------------
% Now we need to visualize:
myFeatID = 244;
isG1_1 = ([theData1.TimeSeries.Group]==1);
isG2_1 = ([theData1.TimeSeries.Group]==2);
isG1_2 = ([theData2.TimeSeries.Group]==1);
isG2_2 = ([theData2.TimeSeries.Group]==2);
isG1_3 = ([theData3.TimeSeries.Group]==1);
isG2_3 = ([theData3.TimeSeries.Group]==2);
opInd = [theData1.Operations.ID]==myFeatID;
f1 = theData1.TS_DataMat(isG1_1,opInd);
f2 = theData1.TS_DataMat(isG2_1,opInd);
f3 = theData2.TS_DataMat(isG1_2,opInd);
f4 = theData2.TS_DataMat(isG2_2,opInd);
f5 = theData3.TS_DataMat(isG1_3,opInd);
f6 = theData3.TS_DataMat(isG2_3,opInd);
extraParams = struct();
redBlue = BF_getcmap('set1',3,1,0);
extraParams.theColors = {redBlue{1};redBlue{2};...
                        brighten(redBlue{1},0.4);brighten(redBlue{2},0.4);...
                        brighten(redBlue{1},0.8);brighten(redBlue{2},0.8)};
BF_JitteredParallelScatter({f1,f2,f3,f4,f5,f6},1,1,true,extraParams);
ax = gca;
ax.XTick = 1:6;
plot(ax.XLim,zeros(2,1),'--k')
ax.XTickLabel = {sprintf('Delta1_%s',theData1.groupNames{1}),...
                sprintf('Delta1_%s',theData1.groupNames{2}),...
                sprintf('Delta2_%s',theData1.groupNames{1}),...
                sprintf('Delta2_%s',theData1.groupNames{2}),...
                sprintf('Delta3_%s',theData1.groupNames{1}),...
                sprintf('Delta3_%s',theData1.groupNames{2})};
ax.TickLabelInterpreter = 'none';
title(theData1.Operations(opInd).Name,'interpreter','none')
