function [fIDs,FDR_qvals] = ConsensusFeatures(whatAnalysis,leftOrRight,whatFeatures)
% Search for features that are similarly discriminative across multiple time points
%-------------------------------------------------------------------------------
if nargin < 1
    whatAnalysis = 'Excitatory_SHAM'; % Excitatory_SHAM, PVCre_SHAM, Excitatory_PVCre
end
if nargin < 2
    leftOrRight = 'control';
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
% Now we need to visualize specific features through time:
% myFeatID = 313;
% groupNames = theData{1}.groupNames;
% opInd = [theData{1}.Operations.ID]==myFeatID;
% redBlue = BF_getcmap('set1',3,1,0);
% if numPoints==3
%     isG1_1 = ([theData{1}.TimeSeries.Group]==1);
%     isG2_1 = ([theData{1}.TimeSeries.Group]==2);
%     isG1_2 = ([theData{2}.TimeSeries.Group]==1);
%     isG2_2 = ([theData{2}.TimeSeries.Group]==2);
%     isG1_3 = ([theData{3}.TimeSeries.Group]==1);
%     isG2_3 = ([theData{3}.TimeSeries.Group]==2);
%     f1 = theData{1}.TS_DataMat(isG1_1,opInd);
%     f2 = theData{1}.TS_DataMat(isG2_1,opInd);
%     f3 = theData{2}.TS_DataMat(isG1_2,opInd);
%     f4 = theData{2}.TS_DataMat(isG2_2,opInd);
%     f5 = theData{3}.TS_DataMat(isG1_3,opInd);
%     f6 = theData{3}.TS_DataMat(isG2_3,opInd);
%     extraParams = struct();
%     extraParams.theColors = {redBlue{1};redBlue{2};...
%                             brighten(redBlue{1},0.4);brighten(redBlue{2},0.4);...
%                             brighten(redBlue{1},0.8);brighten(redBlue{2},0.8)};
%     BF_JitteredParallelScatter({f1,f2,f3,f4,f5,f6},1,1,true,extraParams);
%     ax = gca;
%     ax.XTick = 1:6;
%     ax.XTickLabel = {sprintf('Delta1_%s',groupNames{1}),...
%                     sprintf('Delta1_%s',groupNames{2}),...
%                     sprintf('Delta2_%s',groupNames{1}),...
%                     sprintf('Delta2_%s',groupNames{2}),...
%                     sprintf('Delta3_%s',groupNames{1}),...
%                     sprintf('Delta3_%s',groupNames{2})};
% else
%     isG1_1 = ([theData{1}.TimeSeries.Group]==1);
%     isG2_1 = ([theData{1}.TimeSeries.Group]==2);
%     isG1_2 = ([theData{2}.TimeSeries.Group]==1);
%     isG2_2 = ([theData{2}.TimeSeries.Group]==2);
%     f1 = theData{1}.TS_DataMat(isG1_1,opInd);
%     f2 = theData{1}.TS_DataMat(isG2_1,opInd);
%     f3 = theData{2}.TS_DataMat(isG1_2,opInd);
%     f4 = theData{2}.TS_DataMat(isG2_2,opInd);
%     extraParams = struct();
%     extraParams.theColors = {redBlue{1};redBlue{2};brighten(redBlue{1},0.4);brighten(redBlue{2},0.4)};
%     BF_JitteredParallelScatter({f1,f2,f3,f4},1,1,true,extraParams);
%     ax = gca;
%     ax.XTick = 1:4;
%     ax.XTickLabel = {sprintf('Delta1_%s',groupNames{1}),...
%                     sprintf('Delta1_%s',groupNames{2}),...
%                     sprintf('Delta2_%s',groupNames{1}),...
%                     sprintf('Delta2_%s',groupNames{2})};
% end
% plot(ax.XLim,zeros(2,1),'--k')
% ax.TickLabelInterpreter = 'none';
% title(theData{1}.Operations(opInd).Name,'interpreter','none')

end
