function [regionKeywords,regionName,whatHemisphere] = GiveMeFMR1Info()

%-------------------------------------------------------------------------------
% Break up by region:
dataCore = fullfile('HCTSA_FMR1','HCTSA.mat');
theKeywords = TS_WhatKeywords(dataCore)';
isRegionRelated = cellfun(@(x)~isempty(x),regexp(theKeywords,'reg'));
regionKeywords = theKeywords(isRegionRelated);

%-------------------------------------------------------------------------------
% Map region IDs to region names:
[~,~,ROI_info] = xlsread('NEW_CORTICAL_FMR1.xlsx','ROI_Names');
regionName = cellfun(@(x)ROI_info{str2num(x(4:end)),1},regionKeywords,'UniformOutput',false);
whatHemisphere = categorical(cellfun(@(x)ROI_info{str2num(x(4:end)),2},regionKeywords,'UniformOutput',false));

end
