function ConvertToBaselineDiffs(leftOrRight,plusPVCre,threeOrFour)

if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    plusPVCre = false;
    fprintf(1,'Not including PVCre data\n');
end
if nargin < 3
    if plusPVCre
        threeOrFour = 3;
        % PVCre data don't have the fourth time point in them...
    else
        threeOrFour = 4;
    end
end

%-------------------------------------------------------------------------------
% Set file path
[prePath,rawData] = GiveMeLeftRightInfo(leftOrRight,plusPVCre);
dataRaw = load(rawData);

%-------------------------------------------------------------------------------
% 1) Get unique by mouse ID
expTypeMouseID = ConvertToMouseExpID(dataRaw.TimeSeries,leftOrRight);
uniqueMiceExp = unique(expTypeMouseID);
numMice = length(uniqueMiceExp);
fprintf(1,'%u mice\n',numMice);

%-------------------------------------------------------------------------------
% 2) For each mouse ID, get the {ts1,ts2,ts3,ts4} or {ts1,ts2,ts3}
% 3) Do the subtraction from the raw feature matrix
dataMatSubtracted = zeros(numMice*(threeOrFour-1),size(dataRaw.TS_DataMat,2));
for i = 1:numMice
    index = strcmp(expTypeMouseID,uniqueMiceExp{i});
    if sum(index)~=4
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
if plusPVCre
    newFileName = fullfile(prePath,'HCTSA_all_baselineSub.mat');
else
    newFileName = fullfile(prePath,'HCTSA_baselineSub.mat');
end
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
