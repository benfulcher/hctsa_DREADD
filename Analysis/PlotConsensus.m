function PlotConsensus(myFeatID,whatAnalysis,leftOrRight)
% Now we need to visualize specific feature distributions through time:
if nargin < 1
    myFeatID = 3477;
end
if nargin < 2
    whatAnalysis = 'Excitatory_PVCre_SHAM';
end
if nargin < 3
    leftOrRight = 'right';
end

switch whatAnalysis
case 'Excitatory_SHAM'
    T = {'ts2-BL','ts3-BL','ts4-BL'};
case {'PVCre_SHAM','Excitatory_PVCre','Excitatory_PVCre_SHAM'}
    T = {'ts2-BL','ts3-BL'};
end
numPoints = length(T);
theData = cell(numPoints,1);
for k = 1:numPoints
    [prePath,rawData,rawDataBL,dataTime,dataTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis,T{k});
    theData{k} = LoadDataFile(dataTime);
end
if strcmp(whatAnalysis,'Excitatory_PVCre_SHAM')

%-------------------------------------------------------------------------------
groupNames = theData{1}.groupNames;
numGroups = length(groupNames);
opInd = [theData{1}.Operations.ID]==myFeatID;
redBlue = BF_getcmap('set1',3,1,0);
if numPoints==3
    isG1_1 = ([theData{1}.TimeSeries.Group]==1);
    isG2_1 = ([theData{1}.TimeSeries.Group]==2);
    isG1_2 = ([theData{2}.TimeSeries.Group]==1);
    isG2_2 = ([theData{2}.TimeSeries.Group]==2);
    isG1_3 = ([theData{3}.TimeSeries.Group]==1);
    isG2_3 = ([theData{3}.TimeSeries.Group]==2);
    f1 = theData{1}.TS_DataMat(isG1_1,opInd);
    f2 = theData{1}.TS_DataMat(isG2_1,opInd);
    f3 = theData{2}.TS_DataMat(isG1_2,opInd);
    f4 = theData{2}.TS_DataMat(isG2_2,opInd);
    f5 = theData{3}.TS_DataMat(isG1_3,opInd);
    f6 = theData{3}.TS_DataMat(isG2_3,opInd);
    extraParams = struct();
    extraParams.theColors = {redBlue{1};redBlue{2};...
                            brighten(redBlue{1},0.4);brighten(redBlue{2},0.4);...
                            brighten(redBlue{1},0.8);brighten(redBlue{2},0.8)};
    BF_JitteredParallelScatter({f1,f2,f3,f4,f5,f6},1,1,true,extraParams);
    ax = gca;
    ax.XTick = 1:6;
    ax.XTickLabel = {sprintf('Delta1_%s',groupNames{1}),...
                    sprintf('Delta1_%s',groupNames{2}),...
                    sprintf('Delta2_%s',groupNames{1}),...
                    sprintf('Delta2_%s',groupNames{2}),...
                    sprintf('Delta3_%s',groupNames{1}),...
                    sprintf('Delta3_%s',groupNames{2})};
else
    isG1_1 = ([theData{1}.TimeSeries.Group]==1);
    isG2_1 = ([theData{1}.TimeSeries.Group]==2);
    isG1_2 = ([theData{2}.TimeSeries.Group]==1);
    isG2_2 = ([theData{2}.TimeSeries.Group]==2);
    f1 = theData{1}.TS_DataMat(isG1_1,opInd);
    f2 = theData{1}.TS_DataMat(isG2_1,opInd);
    f3 = theData{2}.TS_DataMat(isG1_2,opInd);
    f4 = theData{2}.TS_DataMat(isG2_2,opInd);

    extraParams = struct();
    extraParams.offsetRange = 0.5;
    if numGroups==2
        extraParams.theColors = {redBlue{1};redBlue{2};brighten(redBlue{1},0.4);brighten(redBlue{2},0.4)};
        BF_JitteredParallelScatter({f1,f2,f3,f4},1,1,true,extraParams);
    else
        isG3_1 = ([theData{1}.TimeSeries.Group]==3);
        isG3_2 = ([theData{2}.TimeSeries.Group]==3);
        f5 = theData{1}.TS_DataMat(isG3_1,opInd);
        f6 = theData{2}.TS_DataMat(isG3_2,opInd);
        extraParams.theColors = {redBlue{1};redBlue{3};redBlue{2};...
            brighten(redBlue{1},0.4);brighten(redBlue{3},0.4);brighten(redBlue{2},0.4)};
        BF_JitteredParallelScatter({f1,f2,f5,f3,f4,f6},1,1,true,extraParams);
    end
    ax = gca;
    if numGroups==2
        ax.XTick = 1:4;
        ax.XTickLabel = {sprintf('Delta1_%s',groupNames{1}),...
                        sprintf('Delta1_%s',groupNames{2}),...
                        sprintf('Delta2_%s',groupNames{1}),...
                        sprintf('Delta2_%s',groupNames{2})};
    else
        ax.XTick = 1:6;
        ax.XTickLabel = {sprintf('Delta1_%s',groupNames{1}),...
                        sprintf('Delta1_%s',groupNames{2}),...
                        sprintf('Delta1_%s',groupNames{3}),...
                        sprintf('Delta2_%s',groupNames{1}),...
                        sprintf('Delta2_%s',groupNames{2}),...
                        sprintf('Delta2_%s',groupNames{3})};
    end
end
plot(ax.XLim,zeros(2,1),'--k')
ax.TickLabelInterpreter = 'none';
title(theData{1}.Operations(opInd).Name,'interpreter','none')
