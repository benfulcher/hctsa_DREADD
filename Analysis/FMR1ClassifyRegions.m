% Aim is to individually classify each region of FMR1 data (wildtype versus
% knockout)

numFolds = 10;
numRepeats = 10;
nullsPerRegion = 5;

%-------------------------------------------------------------------------------
% Break up by region:
dataCore = fullfile('HCTSA_FMR1','HCTSA.mat');
theKeywords = TS_WhatKeywords(dataCore)';
isRegionRelated = cellfun(@(x)~isempty(x),regexp(theKeywords,'reg'));
regionKeywords = theKeywords(isRegionRelated);
numRegions = length(regionKeywords);

%-------------------------------------------------------------------------------
% Map region IDs to region names:
[~,~,ROI_info] = xlsread('NEW_CORTICAL_FMR1.xlsx','ROI_Names');
regionName = cellfun(@(x)ROI_info{str2num(x(4:end)),1},regionKeywords,'UniformOutput',false);
whatHemisphere = categorical(cellfun(@(x)ROI_info{str2num(x(4:end)),2},regionKeywords,'UniformOutput',false));

%-------------------------------------------------------------------------------
% Classify each region based on labels:
foldLosses = cell(numRegions,1);
nullStat = cell(numRegions,1);
for i = 1:numRegions
    thisReg = regionKeywords{i};
    thisRegID = str2num(thisReg(4:end));
    fprintf(1,'-----Region %u/%u---%s (%u): %s (%s)-----\n',i,numRegions,...
                thisReg,thisRegID,ROI_info{thisRegID,1},ROI_info{thisRegID,2});
    normalizedData = fullfile('HCTSA_FMR1',sprintf('HCTSA_%s_N.mat',thisReg));
    [foldLosses{i},nullStat{i}] = TS_classify(normalizedData,'svm_linear',...
                                    'numNulls',nullsPerRegion,...
                                    'numFolds',numFolds,'numRepeats',numRepeats,...
                                    'seedReset','none','doPlot',false);
end

nullStatPooled = vertcat(nullStat{:});

%-------------------------------------------------------------------------------
% Plot them:
foldLossesRight = foldLosses(whatHemisphere=='right');
foldLossesLeft = foldLosses(whatHemisphere=='left');
regionNamesRight = regionName(whatHemisphere=='right');
regionNamesLeft = regionName(whatHemisphere=='left');
% Map both to specified region ordering:
uniqueRegions = unique(regionName);
[~,~,ib] = intersect(uniqueRegions,regionNamesRight,'stable');
foldLossesRightSorted = foldLossesRight(ib);
[~,~,ib] = intersect(uniqueRegions,regionNamesLeft,'stable');
foldLossesLeftSorted = foldLossesLeft(ib);

meanBalAccRight = cellfun(@mean,foldLossesRightSorted);
stdBalAccRight = cellfun(@std,foldLossesRightSorted);
meanBalAccLeft = cellfun(@mean,foldLossesLeftSorted);
stdBalAccLeft = cellfun(@std,foldLossesLeftSorted);
meanBalAccBoth = (meanBalAccRight+meanBalAccLeft)/2;

[~,ix] = sort(meanBalAccBoth,'ascend');


f = figure('color','w');
colors = BF_getcmap('set2',3,0,0);
hold('on');
hr = errorbar(meanBalAccRight(ix),stdBalAccRight(ix),'color',colors(2,:),'LineWidth',2);
hl = errorbar(meanBalAccLeft(ix),stdBalAccLeft(ix),'color',colors(3,:),'LineWidth',2);
plot([1,numRegions/2],ones(2,1)*mean(nullStatPooled),'--k')
plot([1,numRegions/2],ones(2,1)*(mean(nullStatPooled)+std(nullStatPooled)),':k')
plot([1,numRegions/2],ones(2,1)*(mean(nullStatPooled)-std(nullStatPooled)),':k')
ax = gca();
ax.XTick = 1:numRegions/2;
ax.XTickLabel = uniqueRegions(ix);
ax.XTickLabelRotation = 45;
legend([hl,hr],{'left','right'},'Location','northwest')
ylabel('Balanced Accuracy (%)')


f = figure('color','w');
plot(meanBalAccLeft,meanBalAccRight,'xk');
