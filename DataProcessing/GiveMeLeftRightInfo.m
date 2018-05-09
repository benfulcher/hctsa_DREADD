function [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis)

if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
end

% Parent directory
switch leftOrRight
    case 'left'
        prePath = 'HCTSA_LeftCTX';
    case 'right'
        prePath = 'HCTSA_RightCTX';
    case 'control'
        prePath = 'HCTSA_Control';
end

% File in parent directory:
switch whatAnalysis
case 'Excitatory_SHAM'
    fprintf(1,'Excitatory-SHAM!\n');
    rawData = fullfile(prePath,'HCTSA.mat');
    rawDataBL = fullfile(prePath,'HCTSA_baselineSub.mat');
case 'PVCre_SHAM'
    fprintf(1,'PVCre-SHAM!\n');
    rawData = fullfile(prePath,'HCTSA_PVCre_SHAM.mat');
    rawDataBL = fullfile(prePath,'HCTSA_PVCre_SHAM_baselineSub.mat');
end

end
