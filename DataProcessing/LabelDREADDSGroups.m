function groupNames = LabelDREADDSGroups(byMouse,leftOrRight,whatData,whatAnalysis)

if nargin < 4
    whatAnalysis = 'Excitatory_SHAM';
end
%-------------------------------------------------------------------------------

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
else
    switch whatAnalysis
    case 'Excitatory_SHAM'
        TS_LabelGroups(whatData,{'excitatory','SHAM'});
    case 'PVCre_SHAM'
        TS_LabelGroups(whatData,{'PVCre','SHAM'});
    case 'Wild_SHAM'
        TS_LabelGroups(whatData,{'wildInhib','SHAM'});
    case 'Excitatory_PVCre'
        TS_LabelGroups(whatData,{'excitatory','PVCre'});
    case 'Excitatory_Wild'
        TS_LabelGroups(whatData,{'excitatory','wildInhib'});
    case 'PVCre_Wild'
        TS_LabelGroups(whatData,{'PVCre','wildInhib'});
    case 'Excitatory_PVCre_SHAM'
        TS_LabelGroups(whatData,{'excitatory','PVCre','SHAM'});
    case 'Excitatory_PVCre_Wild_SHAM'
        TS_LabelGroups(whatData,{'excitatory','PVCre','wildInhib','SHAM'});
    otherwise
        error('Unknown analysis: %s',whatAnalysis);
    end
end

end
