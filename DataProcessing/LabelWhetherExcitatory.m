function LabelWhetherExcitatory(leftOrRight,whatAnalysis)
%-------------------------------------------------------------------------------
if nargin < 1
    leftOrRight = 'right';
end
if nargin < 2
    whatAnalysis = 'Excitatory_SHAM';
end
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight,whatAnalysis);
%-------------------------------------------------------------------------------

switch whatAnalysis
case 'Excitatory_SHAM'
    % Import ground-truth data:
    DREADDgroups = ImportLabels();

    % Load in the data
    load(rawData,'TimeSeries');
    numTimeSeries = length(TimeSeries);

    isExcitatory = false(numTimeSeries,1);
    for i = 1:numTimeSeries
        if strcmp(leftOrRight,'control')
            first28Names = cellfun(@(x)x(1:28),DREADDgroups.Timeseries_name,'UniformOutput',false);
            matchInd = strcmp(TimeSeries(i).Name(1:28),first28Names);
        else
            matchInd = strcmp(TimeSeries(i).Name,DREADDgroups.Timeseries_name);
        end
        theLabel = DREADDgroups.DREADDGroup(matchInd);
        if theLabel=='sham_control'
            TimeSeries(i).Keywords = [TimeSeries(i).Keywords,',SHAM'];
            isExcitatory(i) = false;
        elseif theLabel=='excitatory'
            TimeSeries(i).Keywords = [TimeSeries(i).Keywords,',excitatory'];
            isExcitatory(i) = true;
        else
            error('Could not match on keywords');
        end
    end

    % Add new field to the TimeSeries structure array
    % Make a cell version of group indices (to use cell2struct)
    isExcitatoryCell = cell(size(isExcitatory))';
    % Cannot find an in-built function for this... :-/
    for i = 1:length(isExcitatory), isExcitatoryCell{i} = isExcitatory(i); end

    newFieldNames = fieldnames(TimeSeries);
    newFieldNames{length(newFieldNames)+1} = 'isExcitatory';
end

% Then append the new group information:
TimeSeries = cell2struct([squeeze(struct2cell(TimeSeries));isExcitatoryCell],newFieldNames);

%-------------------------------------------------------------------------------
% Save to file:
%-------------------------------------------------------------------------------
save(rawData,'TimeSeries','-append')

end
