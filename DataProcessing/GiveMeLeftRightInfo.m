function [prePath,rawData,rawDataBL,rawDataBLTime,dataBLTimeNorm] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis)
% Get information on filenames of processed files
%-------------------------------------------------------------------------------

if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
end

%-------------------------------------------------------------------------------
% Parent directory
switch leftOrRight
    case 'left'
        prePath = 'HCTSA_LeftCTX';
    case 'right'
        prePath = 'HCTSA_RightCTX';
    case 'control'
        prePath = 'HCTSA_Control';
end

%-------------------------------------------------------------------------------
% File in parent directory:
switch whatAnalysis
case 'Excitatory_SHAM'
    fprintf(1,'Excitatory-SHAM!\n');
    rawData = fullfile(prePath,'HCTSA.mat');
    rawDataBL = fullfile(prePath,'HCTSA_baselineSub.mat');
    rawDataBLTime = fullfile(prePath,'HCTSA_ts2-BL.mat');
    dataBLTimeNorm = fullfile(prePath,'HCTSA_ts2-BL_N.mat');
case 'PVCre_SHAM'
    fprintf(1,'PVCre-SHAM!\n');
    rawData = fullfile(prePath,'HCTSA_PVCre_SHAM.mat');
    rawDataBL = fullfile(prePath,'HCTSA_PVCre_SHAM_baselineSub.mat');
    rawDataBLTime = fullfile(prePath,'HCTSA_PVCre_SHAM_ts2-BL.mat');
    dataBLTimeNorm = fullfile(prePath,'HCTSA_PVCre_SHAM_ts2-BL_N.mat');
case 'Excitatory_PVCre'
    fprintf(1,'Excitatory-PVCre!\n');
    rawData = fullfile(prePath,'HCTSA_Exc_PVCre.mat');
    rawDataBL = fullfile(prePath,'HCTSA_Exc_PVCre_baselineSub.mat');
    rawDataBLTime = fullfile(prePath,'HCTSA_Exc_PVCre_ts2-BL.mat');
    dataBLTimeNorm = fullfile(prePath,'HCTSA_Exc_PVCre_ts2-BL_N.mat');
case 'Excitatory_PVCre_SHAM'
    fprintf(1,'Excitatory-PVCre-SHAM!\n');
    rawData = fullfile(prePath,'HCTSA_Exc_PVCre_SHAM.mat');
    rawDataBL = fullfile(prePath,'HCTSA_Exc_PVCre_SHAM_baselineSub.mat');
    rawDataBLTime = fullfile(prePath,'HCTSA_Exc_PVCre_SHAM_ts2-BL.mat');
    dataBLTimeNorm = fullfile(prePath,'HCTSA_Exc_PVCre_SHAM_ts2-BL_N.mat');
otherwise
    error('Unknown analysis: %s',whatAnalysis);
end

end
