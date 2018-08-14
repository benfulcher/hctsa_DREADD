function DoAllProcessing()

%-------------------------------------------------------------------------------
% Settings controlling data processing
%-------------------------------------------------------------------------------

whichSetting = 1;

switch whichSetting
case 1
    % SETTING 1:
    differenceHow = 'relativeProp'; % (how to quantify differences)
    whatNormalizationBaseline = 'zscore'; % (how to normalize features)
case 2
    % SETTING 2:
    differenceHow = 'subtract';
    whatNormalizationBaseline = 'mixedSigmoid';
end

% How to normalize features for a given time point:
whatNormalizationSingle = 'mixedSigmoid'; % (how to normalize features)

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
    SplitByTimePoint(theAnalysis,false,whatNormalizationSingle)
    SplitByTimePoint(theAnalysis,true,whatNormalizationBaseline)
end

end
