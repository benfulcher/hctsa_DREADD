function LowDimProj(whatAnalysis,leftOrRight)
% Generate a low-dimensional projection of the data

if nargin < 1
    whatAnalysis = 'Excitatory_PVCre_SHAM'; % Excitatory_SHAM
end
if nargin < 2
    leftOrRight = 'right';
end

%-------------------------------------------------------------------------------
labelByMouse = false; % label by mouse rather than by group
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
normDataBL = [rawDataBL(1:end-4),'_N.mat'];

% This file has been labeled?
OutputToCSV(normDataBL);

%-------------------------------------------------------------------------------
% Generate a custom group labeling
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
case 'Excitatory_PVCre'
    k1 = {'excitatory','PVCre'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3'},false);
case 'Excitatory_PVCre_SHAM'
    k1 = {'excitatory','PVCre','SHAM'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3'},false);
case 'Excitatory_PVCre_Wild_SHAM'
    k1 = {'excitatory','PVCre','wildInhib','SHAM'};
    groupLabels1 = TS_LabelGroups(nD,k1,false);
    groupLabels2 = TS_LabelGroups(nD,{'ts2','ts3'},false);
end

%-------------------------------------------------------------------------------
% Write it out to file (for python plots):
fileName = 'hctsa_timeseries-customGroup.csv';
fid = fopen(fileName,'w');
for i = 1:height(nD.TimeSeries)
    switch groupLabels2(i)
    case 1
        theGroupName = sprintf('%sDelta1',k1{groupLabels1(i)});
    case 2
        theGroupName = sprintf('%sDelta2',k1{groupLabels1(i)});
    case 3
        theGroupName = sprintf('%sDelta3',k1{groupLabels1(i)});
    end
    fprintf(fid,'%s,%s\n',nD.TimeSeries.Name{i},theGroupName);
end
fclose(fid);

%-------------------------------------------------------------------------------
%% Generate a low-dimensional principal components representation of the dataset:
numAnnotate = 6; % number of time series to annotate to the plot
userSelects = true; % whether the user can click on time series to manually annotate
timeSeriesLength = 600; % length of time-series segments to annotate
annotateParams = struct('n',numAnnotate,'textAnnotation','Name',...
                        'userInput',userSelects,'maxL',timeSeriesLength);
TS_PlotLowDim(normDataBL,'pca',true,'',annotateParams);

end
