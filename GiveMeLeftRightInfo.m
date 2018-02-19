function [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight)

switch leftOrRight
    case 'left'
        prePath = 'HCTSA_LeftCTX';
    case 'right'
        prePath = 'HCTSA_RightCTX';
end

rawData = fullfile(prePath,'HCTSA.mat');
rawDataBL = fullfile(prePath,'HCTSA_baselineSub.mat');

end
