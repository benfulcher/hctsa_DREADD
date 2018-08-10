function DoAllProcessing()

%-------------------------------------------------------------------------------
% Settings controlling data processing
%-------------------------------------------------------------------------------

% How to measure differences relative to baseline:
differenceHow = 'relativeProp'; % 'subtract'

% How to normalize features:
whatNormalization = 'scaledRobustSigmoid';

% The areas to analyze:
whatRegions = {'left','right','control'};
numRegs = length(whatRegions);

% The types of data groupings to investigate:
whatAnalysis = {'Excitatory_SHAM','PVCre_SHAM','Excitatory_PVCre','Excitatory_PVCre_SHAM'};
numAnalyses = length(whatAnalysis);

%-------------------------------------------------------------------------------
% Transform to baseline differences and label groups:
for k = 1:numRegs
    theRegion = whatRegions{k};
    for j = 1:numAnalyses
        theAnalysis = whatAnalysis{j};

        %-----------------------------------------------------------------------
        % Convert to baseline differences:
        ConvertToBaselineDiffs(theRegion,theAnalysis,differenceHow);

        %-----------------------------------------------------------------------
        % Label time series into groups (in both raw and baseline-subtracted data):
        [prePath,rawData,rawDataBL] = GiveMeLeftRightInfo(theRegion,theAnalysis);
        LabelDREADDSGroups(false,theRegion,rawData,theAnalysis);
        LabelDREADDSGroups(false,theRegion,rawDataBL,theAnalysis);
    end
end

%-------------------------------------------------------------------------------
% Split by time point:
for j = 1:numAnalyses
    theAnalysis = whatAnalysis{j};
    SplitByTimePoint(theAnalysis,false,whatNormalization)
    SplitByTimePoint(theAnalysis,true,whatNormalization)
end

end
