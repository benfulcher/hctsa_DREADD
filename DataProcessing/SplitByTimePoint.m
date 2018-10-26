function SplitByTimePoint(whatAnalysis,doBL,whatNormalization)
% Splits the required HCTSA files by individual time point
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check inputs:
if nargin < 1
    whatAnalysis = 'Excitatory_SHAM';
end
if nargin < 2
    doBL = true;
end
if nargin < 3
    whatNormalization = 'scaledRobustSigmoid';
end
labelByMouse = false;
%-------------------------------------------------------------------------------

if doBL
    tsCell = {'ts2-BL','ts3-BL','ts4-BL'};
else
    tsCell = {'ts1','ts2','ts3','ts4'};
end
if ismember(whatAnalysis,{'PVCre_SHAM','Excitatory_PVCre','Excitatory_PVCre_SHAM','PVCre_Wild'})
    tsCell = tsCell(1:end-1); % (for this data we only have three time points)
end
numTimePoints = length(tsCell);

leftOrRight = {'right','left','control'};
numRegions = length(leftOrRight);

for j = 1:numRegions
    [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(leftOrRight{j},whatAnalysis);
    for t = 1:numTimePoints
        theTimePoint = tsCell{t};

        % Make new HCTSA files by filtering:
        if doBL
            theFile = rawDataBL; % baseline-subtracted data
        else
            theFile = rawData; % raw data
        end
        IDs_tsX = TS_getIDs(theTimePoint(1:3),theFile,'ts');

        if isempty(IDs_tsX)
            warning('No matches found for %s',theTimePoint)
            continue
        end
        filteredFileName = sprintf('%s_%s.mat',rawData(1:end-4),theTimePoint);
        filteredFileName = TS_FilterData(theFile,IDs_tsX,[],filteredFileName);

        % Normalize:
        normalizedData = TS_normalize(whatNormalization,[0.5,1],filteredFileName,true);
    end
end

end
