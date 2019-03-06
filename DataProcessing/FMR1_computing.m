% Analysis of FMR1 data

%-------------------------------------------------------------------------------
% Processing text files:
files = dir;
files = files(~[files.isdir]);
fileNames = {files.name}';
numFiles = length(fileNames);

%
numRegions = 46;
numTS = numFiles*numRegions;

% Initialize:
timeSeriesData = cell(numTS,1);
labels = cell(numTS,1);
keywords = cell(numTS,1);

index = 1;
for i = 1:numFiles
    theFile = fileNames{i};
    fileNameSplit = regexp(theFile,'_','split');
    theData = dlmread(theFile);
    for j = 1:numRegions
        timeSeriesData{index} = theData(:,j);
        labels{index} = sprintf('%s_reg%u',theFile(1:end-4),j);
        keywords{index} = sprintf('%s,mouse%s,reg%u',fileNameSplit{1},fileNameSplit{2},j);
        index = index + 1;
    end
end
save('INP_test.mat','timeSeriesData','labels','keywords');
