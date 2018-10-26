
PVCre_or_Wild = 'wild';
leftOrRight = {'left','right','control'};

% Get filenames:
switch PVCre_or_Wild
case 'PVCre'
    theMatFile = 'HCTSA_PVCre.mat';
    theINPFileBase = 'INP_PVCre';
case 'wild'
    theMatFile = 'HCTSA_wildInhib.mat';
    theINPFileBase = 'INP_wildInhib';
end

% Do the matching and replacement
for i = 1:length(leftOrRight)
    prePath = GiveMeLeftRightInfo(leftOrRight{i});
    dataFile = fullfile(prePath,theMatFile);
    hctsaData = load(dataFile);
    numTS = height(hctsaData.TimeSeries);

    % Try to match each filename to the keywords in the new INP file:
    fid = fopen(sprintf('%s_%s.txt',theINPFileBase,leftOrRight{i}));
    S = textscan(fid,'%s%s');
    fclose(fid);

    % Match and reassign keywords
    for k = 1:numTS
        ind = strcmp(hctsaData.TimeSeries.Name,S{1}{k});
        fprintf(1,'Replacing %s with %s\n',hctsaData.TimeSeries.Keywords{k},S{2}{k});
        hctsaData.TimeSeries.Keywords{k} = S{2}{k};
    end

    % Save back:
    TimeSeries = hctsaData.TimeSeries;
    save(dataFile,'TimeSeries','-append');
end
