function [expTypeMouseID,timePoint] = ConvertToMouseExpID(TimeSeries,leftOrRight)
% Given TimeSeries, returns mouse IDs that combine mouse and experiment

tsKeywords = {TimeSeries.Keywords}';
numTS = length(tsKeywords);
keywordSplit = regexp(tsKeywords,',','split');

switch leftOrRight
case 'left'
    expTypeMouseID = cell(length(TimeSeries),1);
    for i = 1:length(TimeSeries)
        theName = TimeSeries(i).Name;
        % 20170905_SHAM
        if strcmp(theName(10:13),'SHAM')
            expTypeMouseID{i} = theName(1:20);
        else
            expTypeMouseID{i} = theName(1:26);
        end
    end
    timePoint = cellfun(@(x)x{2},keywordSplit,'UniformOutput',false);
case {'right','control'}
    numKWs = cellfun(@length,keywordSplit);
    isPVCre = cellfun(@(x)strcmp(x{3},'PVCre'),keywordSplit);
    if any(isPVCre)
        expType = cell(length(tsKeywords),1);
        mouseID = cell(length(tsKeywords),1);
        timePoint = cell(length(tsKeywords),1);
        for k = 1:numTS
            if isPVCre(k)
                expTypeMouseID{k} = horzcat(keywordSplit{k}{3},keywordSplit{k}{1});
                timePoint{k} = keywordSplit{k}{2};
            else
                expTypeMouseID{k} = horzcat(keywordSplit{k}{1},keywordSplit{k}{2});
                timePoint{k} = keywordSplit{k}{3};
            end
        end
    else
        expType = cellfun(@(x)x{1},keywordSplit,'UniformOutput',false);
        mouseID = cellfun(@(x)x{2},keywordSplit,'UniformOutput',false);
        timePoint = cellfun(@(x)x{3},keywordSplit,'UniformOutput',false);
        expTypeMouseID = cellfun(@(x)horzcat(x{1:2}),keywordSplit,'UniformOutput',false);
    end
end


end
