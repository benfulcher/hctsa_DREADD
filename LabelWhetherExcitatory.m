function LabelWhetherExcitatory(whatFileName)
%-------------------------------------------------------------------------------
if nargin < 1
    whatFileName = 'HCTSA.mat';
end
%-------------------------------------------------------------------------------

% Import ground-truth data:
DREADDgroups = ImportLabels();

% Load in the data
load(whatFileName,'TimeSeries');
numTimeSeries = length(TimeSeries);

isExcitatory = false(numTimeSeries,1);
for i = 1:numTimeSeries
    matchInd = strcmp(TimeSeries(i).Name,DREADDgroups.Timeseries_name);
    theLabel = DREADDgroups.DREADDGroup(matchInd);
    if theLabel=='sham_control'
        TimeSeries(i).Keywords = [TimeSeries(i).Keywords,',SHAM'];
        isExcitatory(i) = false;
    elseif theLabel=='excitatory'
        TimeSeries(i).Keywords = [TimeSeries(i).Keywords,',excitatory'];
        isExcitatory(i) = true;
    end
end

% Add new field to the TimeSeries structure array
% Make a cell version of group indices (to use cell2struct)
isExcitatoryCell = cell(size(isExcitatory))';
% Cannot find an in-built function for this... :-/
for i = 1:length(isExcitatory), isExcitatoryCell{i} = isExcitatory(i); end

newFieldNames = fieldnames(TimeSeries);
newFieldNames{length(newFieldNames)+1} = 'isExcitatory';

% Then append the new group information:
TimeSeries = cell2struct([squeeze(struct2cell(TimeSeries));isExcitatoryCell],newFieldNames);

%-------------------------------------------------------------------------------
% Save to file:
%-------------------------------------------------------------------------------
save(whatFileName,'TimeSeries','-append')

end
