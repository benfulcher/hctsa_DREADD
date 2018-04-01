function groupNames = LabelDREADDSGroups(byMouse,leftOrRight,whatData)

if byMouse
    % Label by unique mouse/ID pairs:
    load(whatData,'TimeSeries');
    mouseExpID = ConvertToMouseExpID(TimeSeries,leftOrRight);
    % Make group labels:
    [groupNames,~,groupLabels] = unique(mouseExpID);
    groupLabels = groupLabels';
    theGroupsCell = cell(size(groupLabels));
    for i = 1:length(groupLabels)
        theGroupsCell{i} = groupLabels(i);
    end
    if isfield(TimeSeries,'Group')
        TimeSeries = rmfield(TimeSeries,'Group');
    end
    newFieldNames = fieldnames(TimeSeries);
    newFieldNames{length(newFieldNames)+1} = 'Group';
    TimeSeries = cell2struct([squeeze(struct2cell(TimeSeries));theGroupsCell],newFieldNames);
    save(whatData,'TimeSeries','groupNames','-append')
    fprintf(1,'Saved mouse/experiment ID back to %s\n',whatData);
    % mouseLabels = {'mouse70','mouse72','mouse73','mouse75','mouse124','mouse125','mouse90',''};
    % TS_LabelGroups(whatData,{'SHAM','excitatory'});
else
    TS_LabelGroups(whatData,{'SHAM','excitatory'});
end
% Three groups:
% TS_LabelGroups({'SHAM','DREDD','rsfMRI'},'raw');

end
