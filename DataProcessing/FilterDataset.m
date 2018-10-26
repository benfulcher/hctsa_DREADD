function FilterDataset(whatAnalysis)
% Idea is to filter all datasets based on a given analysis
% -> HCTSA_filt.mat
%-------------------------------------------------------------------------------

if nargin < 1
    whatAnalysis = 'Excitatory_SHAM';
end

leftOrRight = {'right','left','control'};
numRegions = length(leftOrRight);

for k = 1:numRegions
    [prePath,rawData] = GiveMeLeftRightInfo(leftOrRight{k});

    switch whatAnalysis
    case 'Excitatory_SHAM'
        % Already in HCTSA.mat
    case 'Wild_SHAM'
        % Need to isolate SHAM data from HCTSA.mat
        ts_keepIDs = TS_getIDs('SHAM',rawData,'ts');
        SHAMFile = fullfile(prePath,'HCTSA_SHAM.mat');
        TS_FilterData(rawData,ts_keepIDs,[],SHAMFile);
        % Now add the wildInhib data:
        TS_combine(SHAMFile,fullfile(prePath,'HCTSA_wildInhib.mat'),false,false,fullfile(prePath,'HCTSA_wildInhib_SHAM.mat'),true);
    case 'PVCre_SHAM'
        % Need to remove Excitatory data, and add PVCre data
        SHAM_IDs = TS_getIDs('SHAM',rawData,'ts');
        [~,TS13] = TS_getIDs('ts4',rawData,'ts'); % exclude ts4
        ts_keepIDs = intersect(SHAM_IDs,TS13);
        SHAMFile = fullfile(prePath,'HCTSA_SHAM.mat');
        TS_FilterData(rawData,ts_keepIDs,[],SHAMFile);
        % Now add the PVCre data:
        TS_combine(SHAMFile,fullfile(prePath,'HCTSA_PVCre.mat'),false,false,fullfile(prePath,'HCTSA_PVCre_SHAM.mat'),true);
    case 'PVCre_Wild'
        % Exclude ts4 from wildInhib data:
        wildInhibData = fullfile(prePath,'HCTSA_wildInhib.mat');
        [~,ts_keepIDs] = TS_getIDs('ts4',wildInhibData,'ts');
        wildInhib_ts13 = fullfile(prePath,'HCTSA_wildInhib_ts13.mat');
        TS_FilterData(wildInhibData,ts_keepIDs,[],wildInhib_ts13);
        PVCreFile = fullfile(prePath,'HCTSA_PVCre.mat');
        TS_combine(PVCreFile,wildInhib_ts13,false,false,fullfile(prePath,'HCTSA_PVCre_wildInhib.mat'),true);
    case 'Excitatory_Wild'
        % Need to remove SHAM data, and add inhibWild data
        Excitatory_IDs = TS_getIDs('excitatory',rawData,'ts');
        ExcFile = fullfile(prePath,'HCTSA_Excitatory.mat');
        TS_FilterData(rawData,Excitatory_IDs,[],ExcFile);
        % Now add the PVCre data:
        TS_combine(ExcFile,fullfile(prePath,'HCTSA_wildInhib.mat'),false,false,fullfile(prePath,'HCTSA_Exc_wildInhib.mat'),true);
    case 'Excitatory_PVCre'
        % Need to remove SHAM data, and add PVCre data
        Excitatory_IDs = TS_getIDs('excitatory',rawData,'ts');
        [~,TS13] = TS_getIDs('ts4',rawData,'ts'); % exclude ts4
        ts_keepIDs = intersect(Excitatory_IDs,TS13);
        ExcFile = fullfile(prePath,'HCTSA_Excitatory.mat');
        TS_FilterData(rawData,ts_keepIDs,[],ExcFile);
        % Now add the PVCre data:
        PVCreFile = fullfile(prePath,'HCTSA_PVCre.mat');
        TS_combine(ExcFile,PVCreFile,false,false,fullfile(prePath,'HCTSA_Exc_PVCre.mat'),true);
    case 'Excitatory_PVCre_SHAM'
        [~,ts_keepIDs] = TS_getIDs('ts4',rawData,'ts'); % exclude ts4
        T13File = fullfile(prePath,'HCTSA_T13.mat');
        TS_FilterData(rawData,ts_keepIDs,[],T13File);
        % Combine all three experimental data together:
        TS_combine(T13File,fullfile(prePath,'HCTSA_PVCre.mat'),false,false,fullfile(prePath,'HCTSA_Exc_PVCre_SHAM.mat'),true);
    end
end

end
