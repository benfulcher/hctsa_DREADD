function ConvertToBaselineDiffs(leftOrRight,whatAnalysis)

if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
    fprintf(1,'Analyzing excitatory-sham data\n');
end
switch whatAnalysis
case 'Excitatory_SHAM'
    threeOrFour = 4;
case 'PVCre_SHAM'
    % PVCre data don't have the fourth time point in them...
    threeOrFour = 3;
end

%-------------------------------------------------------------------------------
% Set file path
[prePath,rawData] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
dataRaw = load(rawData);

%-------------------------------------------------------------------------------
% 1) Get unique by mouse ID
[expTypeMouseID,timePoint] = ConvertToMouseExpID(dataRaw.TimeSeries,leftOrRight);
uniqueMiceExp = unique(expTypeMouseID);
numMice = length(uniqueMiceExp);
fprintf(1,'%u mice\n',numMice);

%-------------------------------------------------------------------------------
% 2) For each mouse ID, get the {ts1,ts2,ts3,ts4} or {ts1,ts2,ts3}
% 3) Do the subtraction from the raw feature matrix
dataMatSubtracted = zeros(numMice*(threeOrFour-1),size(dataRaw.TS_DataMat,2));
for i = 1:numMice
    index = strcmp(expTypeMouseID,uniqueMiceExp{i});
    if sum(index)~=threeOrFour
        error('Error matching %s',uniqueMiceExp{i});
    end
    isBaseline = index & strcmp(timePoint,'ts1');
    baseLine = dataRaw.TS_DataMat(isBaseline,:);

    indexNew = (i-1)*(threeOrFour-1)+1:i*threeOrFour;
    dataMatSubtracted(indexNew(1),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts2'),:) - baseLine;
    dataMatSubtracted(indexNew(2),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts3'),:) - baseLine;
    if threeOrFour==4
        dataMatSubtracted(indexNew(3),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts4'),:) - baseLine;
    end
end

%-------------------------------------------------------------------------------
% 4) Save back to a new HCTSA file:
% (Copy to a new version)
newFileName = sprintf('%s_baselineSub.mat',rawData(1:end-4));
system(sprintf('cp %s %s',rawData,newFileName));
TS_DataMat = dataMatSubtracted;
save(newFileName,'TS_DataMat','-append');
% Now we remove baseline data:
wasKept = ~ismember(timePoint,'ts1');
TimeSeries = dataRaw.TimeSeries(wasKept);
save(newFileName,'TimeSeries','-append');
TS_Quality = dataRaw.TS_Quality(wasKept,:);
save(newFileName,'TS_Quality','-append');
fprintf(1,'Saved new HCTSA data, with baseline removed to %s\n',newFileName);

end
