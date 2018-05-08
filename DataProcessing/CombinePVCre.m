function CombinePVCre()
% Combines original calculations with the PVCre data
%-------------------------------------------------------------------------------

leftOrRight = {'control','left','right'};

for k = 1:3
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight{k},false);
    TS_combine(rawData,fullfile(prePath,'HCTSA_PVCre.mat'),false,false,fullfile(prePath,'HCTSA_all.mat'));
end

end
