function ConvertToBaselineDiffs(leftOrRight,whatAnalysis,differenceHow)
% Convert HCTSA files across different time points to differences relative
% to baseline.
%-------------------------------------------------------------------------------
if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
    fprintf(1,'Analyzing excitatory-sham data\n');
end
if nargin < 3
    differenceHow = 'subtract'; % 'subtract', 'relativeProp'
end
%-------------------------------------------------------------------------------
switch whatAnalysis
case {'Excitatory_SHAM','Wild_SHAM','Excitatory_Wild'}
    threeOrFour = 4; % there are four time points
case {'PVCre_SHAM','Excitatory_PVCre','Excitatory_PVCre_SHAM','PVCre_Wild'}
    % PVCre data doesn't contain information about the fourth time point...
    threeOrFour = 3;
end

%-------------------------------------------------------------------------------
% Set file path
[~,rawData] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
dataRaw = load(rawData);

%-------------------------------------------------------------------------------
% 1) Get unique by mouse ID
[expTypeMouseID,timePoint] = ConvertToMouseExpID(dataRaw.TimeSeries,leftOrRight);
uniqueMiceExp = unique(expTypeMouseID);
numMice = length(uniqueMiceExp);
fprintf(1,'We found %u mice for %s in region %s\n',numMice,whatAnalysis,leftOrRight);

%-------------------------------------------------------------------------------
% 2) For each mouse ID, get the {ts1,ts2,ts3,ts4} or {ts1,ts2,ts3}
% 3) Do the subtraction from the raw feature matrix
dataMatSubtracted = zeros(numMice*(threeOrFour-1),size(dataRaw.TS_DataMat,2));
rowLabelsCheck = cell(numMice*(threeOrFour-1),1);
switch differenceHow
case 'subtract'
    f_transform = @(x1,x2) (x1 - x2);
case 'relativeProp'
    f_transform = @(x1,x2) (x1 - x2)./x2;
end

% Correct for each mouse individually:
for i = 1:numMice
    index = strcmp(expTypeMouseID,uniqueMiceExp{i});
    if sum(index)~=threeOrFour
        error('Error matching %s',uniqueMiceExp{i});
    else
        fprintf(1,'Baseline correction for mouse %s\n',uniqueMiceExp{i});
    end
    if size(index,1)~=size(timePoint,1)
        timePoint = timePoint';
    end

    % Define indexes (old):
    index_ts = zeros(threeOrFour,1);
    index_ts(1) = find(index & strcmp(timePoint,'ts1'));
    index_ts(2) = find(index & strcmp(timePoint,'ts2'));
    index_ts(3) = find(index & strcmp(timePoint,'ts3'));

    % Use indexes to partition original data
    data_baseline = dataRaw.TS_DataMat(index_ts(1),:);
    data_ts2 = dataRaw.TS_DataMat(index_ts(2),:);
    data_ts3 = dataRaw.TS_DataMat(index_ts(3),:);

    % Transform relative to baseline and save to indices of the new data matrix:
    indexNew = (i-1)*(threeOrFour-1)+1:i*(threeOrFour-1);
    dataMatSubtracted(indexNew(1),:) = f_transform(data_ts2,data_baseline);
    dataMatSubtracted(indexNew(2),:) = f_transform(data_ts3,data_baseline);
    rowLabelsCheck{indexNew(1)} = dataRaw.TimeSeries.Name{index_ts(2)};
    rowLabelsCheck{indexNew(2)} = dataRaw.TimeSeries.Name{index_ts(3)};

    if threeOrFour==4
        index_ts(4) = find(index & strcmp(timePoint,'ts4'));
        data_ts4 = dataRaw.TS_DataMat(index_ts(4),:);
        dataMatSubtracted(indexNew(3),:) = f_transform(data_ts4,data_baseline);
        rowLabelsCheck{indexNew(3)} = dataRaw.TimeSeries.Name{index_ts(4)};
    end
end

%-------------------------------------------------------------------------------
% Identify subtracted version with new TS_DataMat:
TS_DataMat = dataMatSubtracted;
% Now match labels baseline data from row labels:
[~,ia,ib] = intersect(rowLabelsCheck,dataRaw.TimeSeries.Name,'stable');
TimeSeries = dataRaw.TimeSeries(ib,:);
TS_Quality = dataRaw.TS_Quality(ib,:);

% Check that the new time series array matches rowLabelsCheck
if ~all(diff(ia)==1)
    warning('Error matching on baseline subtraction')
    keyboard
end

%-------------------------------------------------------------------------------
% 4) Save back to a new HCTSA file (copy to a new version):
newFileName = sprintf('%s_baselineSub.mat',rawData(1:end-4));
system(sprintf('cp %s %s',rawData,newFileName));
% Write over with new data:
save(newFileName,'TS_DataMat','-append');
save(newFileName,'TimeSeries','-append');
save(newFileName,'TS_Quality','-append');
fprintf(1,'Saved new HCTSA data, with baseline removed by %s to %s\n',...
                            differenceHow,newFileName);

end
