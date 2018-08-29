function dataStruct = LoadDataFile(whatFile,whatFeatures)
% Loads hctsa data from file (with possible filtering of features)
%-------------------------------------------------------------------------------
if nargin < 2
    whatFeatures = 'all';
end

fprintf(1,'Loading data from %s\n',whatFile);
loadedData = load(whatFile);

switch whatFeatures
case 'reduced'
    dataStruct = FilterReducedSet(loadedData,'clustered');
case 'all'
    dataStruct = loadedData;
case 'significant'
    dataStruct = FilterReducedSet(loadedData,'significant');
end

% Throw NaNs into missing data:
dataStruct.TS_DataMat(dataStruct.TS_Quality > 0) = NaN;

end
