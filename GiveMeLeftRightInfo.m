function [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight)

switch leftOrRight
    case 'left'
        prePath = 'HCTSA_LeftCTX';
    case 'right'
        prePath = 'HCTSA_RightCTX';
    case 'control'
        prePath = 'HCTSA_Control';
end

rawData = fullfile(prePath,'HCTSA.mat');
rawDataBL = fullfile(prePath,'HCTSA_baselineSub.mat');

end
