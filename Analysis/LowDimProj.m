function LowDimProj(whatAnalysis,leftOrRight)
% Generate a low-dimensional projection of the data:

if nargin < 1
    whatAnalysis = 'Excitatory_PVCre_SHAM'; % Excitatory_SHAM
end
if nargin < 2
    leftOrRight = 'right';
end

%-------------------------------------------------------------------------------
labelByMouse = false; % label by group rather than by mouse

% 1. We want to generate a low-dimensional projection
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
normDataBL = [rawDataBL(1:end-4),'_N.mat'];

% This file has been labeled?
OutputToCSV(normDataBL);

%-------------------------------------------------------------------------------
% Write a custom (joint) labeling:
fileName = 'hctsa_timeseries-customGroup.csv';
fid = fopen(fileName,'w');
nD = load(normDataBL,'TimeSeries');

switch whatAnalysis
case 'Excitatory_SHAM'
    k1 = {'excitatory','SHAM'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3','ts4'},false);
case 'PVCre_SHAM'
    k1 = {'PVCre','SHAM'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3'},false);
case 'Excitatory_PVCre_SHAM'
    k1 = {'excitatory','PVCre','SHAM'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3'},false);
end

for i = 1:length(nD.TimeSeries)
    switch groupLabels2(i)
    case 1
        theGroupName = sprintf('%sDelta1',k1{groupLabels1(i)});
    case 2
        theGroupName = sprintf('%sDelta2',k1{groupLabels1(i)});
    case 3
        theGroupName = sprintf('%sDelta3',k1{groupLabels1(i)});
    end
    fprintf(fid,'%s,%s\n',nD.TimeSeries(i).Name,theGroupName);
end
fclose(fid);

%-------------------------------------------------------------------------------
%% Generate a low-dimensional principal components representation of the dataset:
% numAnnotate = 3; % number of time series to annotate to the plot
% userSelects = true; % whether the user can click on time series to manually annotate
% timeSeriesLength = 600; % length of time-series segments to annotate
% annotateParams = struct('n',numAnnotate,'textAnnotation','none',...
%                         'userInput',userSelects,'maxL',timeSeriesLength);
% TS_plot_pca(normalizedData,true,'',annotateParams)
end
