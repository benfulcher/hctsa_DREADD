function c = GiveMeColor(whatThing)

switch whatThing
case 'control';
    c = [100,60,150]/255;
case 'injected'
    c = [15,100,60]/255;
case 'excitatory'
    redBlue = BF_getcmap('set1',3,1,0);
    c = redBlue(1,:);
case 'SHAM'
    redBlue = BF_getcmap('set1',3,1,0);
    c = redBlue(3,:);
case 'PVCre'
    redBlue = BF_getcmap('set1',3,1,0);
    c = redBlue(2,:);
end

end
