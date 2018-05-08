leftOrRight = {'left','right','control'};

for i = 1:3
    prePath = GiveMeLeftRightInfo(leftOrRight{i});
    dataFile = fullfile(prePath,'HCTSA_PVCre.mat');
    hctsaData = load(dataFile);
    numTS = length(hctsaData.TimeSeries);

    % Try to match each filename to the keywords in the new INP file:
    fid = fopen(sprintf('INP_PVCre_%s.txt',leftOrRight{i}));
    S = textscan(fid,'%s%s');
    fclose(fid);

    % Match and reassign keywords
    for k = 1:numTS
        ind = strcmp({hctsaData.TimeSeries.Name},S{1}{k});
        fprintf(1,'Replacing %s with %s\n',hctsaData.TimeSeries(k).Keywords,S{2}{k});
        hctsaData.TimeSeries(k).Keywords = S{2}{k};
    end

    % Save back:
    TimeSeries = hctsaData.TimeSeries;
    save(dataFile,'TimeSeries','-append');
end
