% Aim is to remove this bad, bad mouse, mouse105 from the PVCre files

theAreas = {'left','right','control'};
numAreas = length(theAreas);

for i = 1:numAreas
    prePath = GiveMeLeftRightInfo(theAreas{i});
    theFileToFix = fullfile(prePath,'HCTSA_PVCre.mat');
    IDs_mouse105 = TS_getIDs('mouse105',theFileToFix,'ts');
    TS_local_clear_remove(theFileToFix,'ts',IDs_mouse105,true);
end
