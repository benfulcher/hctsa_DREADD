function ConvertToBaselineDiffs()

dataRaw = load('HCTSA.mat');

% 1) Get unique by mouse ID
tsKeywords = {dataRaw.TimeSeries.Keywords}';
keywordSplit = regexp(tsKeywords,',','split');
expType = cellfun(@(x)x{1},keywordSplit,'UniformOutput',false);
mouseID = cellfun(@(x)x{2},keywordSplit,'UniformOutput',false);
timePoint = cellfun(@(x)x{3},keywordSplit,'UniformOutput',false);
expTypeMouseID = cellfun(@(x)horzcat(x{1:2}),keywordSplit,'UniformOutput',false);
uniqueMiceExp = unique(expTypeMouseID);
numMice = length(uniqueMiceExp);
fprintf(1,'%u mice\n',numMice);

% 2) For each mouse ID, get the {ts1,ts2,ts3,ts4}
% 3) Do the subtraction from the raw feature matrix
dataMatSubtracted = zeros(numMice*3,size(dataRaw.TS_DataMat,2));
for i = 1:numMice
    index = strcmp(expTypeMouseID,uniqueMiceExp{i});
    if sum(index)~=4
        error('Error matching %s',uniqueMiceExp{i});
    end
    isBaseline = index & strcmp(timePoint,'ts1');
    baseLine = dataRaw.TS_DataMat(isBaseline,:);

    indexNew = (i-1)*3+1:i*3;
    dataMatSubtracted(indexNew(1),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts2'),:) - baseLine;
    dataMatSubtracted(indexNew(2),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts3'),:) - baseLine;
    dataMatSubtracted(indexNew(3),:) = dataRaw.TS_DataMat(index & strcmp(timePoint,'ts4'),:) - baseLine;
end

%-------------------------------------------------------------------------------
% 4) Save back to a new HCTSA file:
% (Copy to a new version)
newFileName = 'HCTSA_baselineSub.mat';
system(sprintf('cp HCTSA.mat %s',newFileName));
TS_DataMat = dataMatSubtracted;
save(newFileName,'TS_DataMat','-append');
% Now we remove baseline data:
wasKept = ~ismember(timePoint,'ts1');
TimeSeries = dataRaw.TimeSeries(wasKept);
save(newFileName,'TimeSeries','-append');
fprintf(1,'Saved new HCTSA data, with baseline removed\n');

end
