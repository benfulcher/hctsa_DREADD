function [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,plusPVCre)

if nargin < 2
    plusPVCre = false;
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
if plusPVCre
    rawData = fullfile(prePath,'HCTSA_all.mat');
    rawDataBL = fullfile(prePath,'HCTSA_all_baselineSub.mat');
else
    rawData = fullfile(prePath,'HCTSA.mat');
    rawDataBL = fullfile(prePath,'HCTSA_baselineSub.mat');
end

end
