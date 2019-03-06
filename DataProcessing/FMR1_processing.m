% Split by region, label by AWT/KO, and normalize/filter features
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Parameters:
normFunction = 'scaledRobustSigmoid';
filterParams = [0.70,1];

%-------------------------------------------------------------------------------
% Break up by region:
dataCore = fullfile('HCTSA_FMR1','HCTSA.mat');
theKeywords = TS_WhatKeywords(dataCore)';
isRegionRelated = cellfun(@(x)~isempty(x),regexp(theKeywords,'reg'));
regionKeywords = theKeywords(isRegionRelated);
numRegions = length(regionKeywords);

for i = 1:numRegions
    thisReg = regionKeywords{i};
    % Filter data to include just this region:
    IDs_here = TS_getIDs(thisReg,dataCore,'ts');
    filteredFilename = fullfile('HCTSA_FMR1',sprintf('HCTSA_%s.mat',thisReg));
    TS_FilterData(dataCore,IDs_here,[],filteredFilename);
    % Label groups:
    TS_LabelGroups(filteredFilename,{'AWT','KO'});
    % Normalize:
    TS_Normalize(normFunction,filterParams,filteredFilename,true);
end
