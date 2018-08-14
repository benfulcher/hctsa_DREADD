function dataStruct = LoadDataFile(whatFile,whatFeatures)
% Loads a file (with possible filtering of features)

fprintf(1,'Loading data from %s\n',whatFile);
loadedData = load(whatFile);

switch whatFeatures
case 'reduced'
    dataStruct = FilterReducedSet(loadedData);
case 'all'
    dataStruct = loadedData;
end

end
