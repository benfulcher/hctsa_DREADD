
numNullsPerRegion = 10;

%-------------------------------------------------------------------------------
% Get trained model from PVCre-SHAM
[~,~,~,~,dataTimeNorm] = GiveMeLeftRightInfo('right','PVCre_SHAM','ts2-BL');
PVCreSham_norm = LoadDataFile(dataTimeNorm,'all');
% Train the model on the data:
whatClassifier = 'svm_linear';
XTrain = PVCreSham_norm.TS_DataMat;
yTrain = PVCreSham_norm.TimeSeries.Group;
whatLoss = 'balancedAcc';
reWeight = true;
PVCreFeatureNames = PVCreSham_norm.Operations.Name; % [PVCre,SHAM]

%-------------------------------------------------------------------------------
% Go through and evaluate model on FMR1 data:
[regionKeywords,regionName,whatHemisphere] = GiveMeFMR1Info();
numRegions = length(regionKeywords);

balAcc = zeros(numRegions,1);
nullAcc = cell(numRegions,1);
pValZ = zeros(numRegions,1);
pValPermTest = zeros(numRegions,1);
for i = 1:numRegions
    thisReg = regionKeywords{i};
    normalizedData = fullfile('HCTSA_FMR1',sprintf('HCTSA_%s_N.mat',thisReg));
    normalizedData = load(normalizedData);
    FMR1FeatureNames = normalizedData.Operations.Name;

    % Match features:
    [~,ia,ib] = intersect(PVCreFeatureNames,FMR1FeatureNames);
    [~,Mdl,whatLoss] = GiveMeCfn(whatClassifier,XTrain(:,ia),yTrain,[],[],2,true,whatLoss,reWeight);

    XTest = normalizedData.TS_DataMat(:,ib);
    yPredict = 3 - predict(Mdl,XTest); % PVCre,SHAM -- swap for predicted direction
    yReal = normalizedData.TimeSeries.Group; % WT,KO
    balAcc(i) = BF_lossFunction(yReal,yPredict,whatLoss,2);

    nullAccHere = zeros(numNullsPerRegion,1);
    parfor j = 1:numNullsPerRegion
        yRealPerm = yReal(randperm(length(yReal)));
        nullAccHere(j) = BF_lossFunction(yRealPerm,yPredict,whatLoss,2);
    end
    pValPermTest(i) = mean(nullAccHere >= balAcc(i));
    pValZ(i) = 1 - normcdf(balAcc(i),mean(nullAccHere),std(nullAccHere));
    nullAcc{i} = nullAccHere;

    fprintf(1,'Region %s-%s (%u/%u), balanced Acc = %.1f%%, p_perm = %.1g, p_z ~= %.1g\n',...
        regionName{i},whatHemisphere(i),i,numRegions,balAcc(i),pValPermTest(i),pValZ(i));
end

%-------------------------------------------------------------------------------
% Structure:
balAccRight = balAcc(whatHemisphere=='right');
balAccLeft = balAcc(whatHemisphere=='left');
pValZRight = pValZ(whatHemisphere=='right');
pValZLeft = pValZ(whatHemisphere=='left');
pValPermRight = pValPermTest(whatHemisphere=='right');
pValPermLeft = pValPermTest(whatHemisphere=='left');
regionNamesRight = regionName(whatHemisphere=='right');
regionNamesLeft = regionName(whatHemisphere=='left');
% Map both to specified region ordering:
uniqueRegions = unique(regionName);
[~,~,ib] = intersect(uniqueRegions,regionNamesRight,'stable');
balAccRightSorted = balAccRight(ib);
pValZRightSorted = pValZRight(ib);
pValPermRightSorted = pValPermRight(ib);
[~,~,ib] = intersect(uniqueRegions,regionNamesLeft,'stable');
balAccLeftSorted = balAccLeft(ib);
pValZLeftSorted = pValZLeft(ib);
pValPermLeftSorted = pValPermLeft(ib);
% Mean left/right:
balAccBoth = (balAccRightSorted+balAccLeftSorted)/2;
[~,ix] = sort(balAccBoth,'ascend');

%-------------------------------------------------------------------------------
% Export data to csv:
dataFileOut = 'crossPredictionAccuracyP.csv';
fid = fopen(dataFileOut,'w');
fprintf(fid,'RegionName,\tregionHemisphere,\tbalancedAccuracy(%%),\tpPerm,\tpZ\n');
for i = 1:numRegions/2
    ind = ix(i);
    fprintf(fid,'%s,\t%s,\t%g,\t%g,\t%g\n',uniqueRegions{ind},'right',balAccRightSorted(ind),pValPermRightSorted(ind),pValZRightSorted(ind));
    fprintf(fid,'%s,\t%s,\t%g,\t%g,\t%g\n',uniqueRegions{ind},'left',balAccLeftSorted(ind),pValPermLeftSorted(ind),pValZLeftSorted(ind));
end
fclose(fid);

%-------------------------------------------------------------------------------
nullStatPooled = vertcat(nullAcc{:});

%-------------------------------------------------------------------------------
% Plot them:
pValZMean = (pValZRightSorted+pValZLeftSorted)/2;

balAccRightSorted_ix = balAccRightSorted(ix);
isSigRight_ix = (pValZRightSorted(ix) < 0.01);
balAccLeftSorted_ix = balAccLeftSorted(ix);
isSigLeft_ix = (pValZLeftSorted(ix) < 0.01);

colors = BF_getcmap('set2',3,0,0);
f = figure('color','w');
hold('on');
hr = plot(find(~isSigRight_ix),balAccRightSorted_ix(~isSigRight_ix),'x','color',colors(2,:),'LineWidth',1);
plot(find(isSigRight_ix),balAccRightSorted_ix(isSigRight_ix),'o','MarkerFaceColor',colors(2,:),'LineWidth',2);
hl = plot(find(~isSigLeft_ix),balAccLeftSorted_ix(~isSigLeft_ix),'x','color',colors(3,:),'LineWidth',1);
plot(find(isSigLeft_ix),balAccLeftSorted_ix(isSigLeft_ix),'o','MarkerFaceColor',colors(3,:),'LineWidth',2);
plot([1,numRegions/2],ones(2,1)*mean(nullStatPooled),'--k')
plot([1,numRegions/2],ones(2,1)*(mean(nullStatPooled)+std(nullStatPooled)),':k')
plot([1,numRegions/2],ones(2,1)*(mean(nullStatPooled)-std(nullStatPooled)),':k')
ax = gca();
ax.XTick = 1:numRegions/2;
ax.XTickLabel = uniqueRegions(ix);
ax.XTickLabelRotation = 45;
legend([hl,hr],{'left','right'},'Location','northwest')
ylabel('Balanced Accuracy (%)')


%-------------------------------------------------------------------------------
% PV CELL DENSITY??
%-------------------------------------------------------------------------------
cellDensities = ImportCellDensities();
% match on region acronym:
[regionsMatch,ia,ib] = intersect(uniqueRegions,cellDensities.acronym,'stable');
accRight = balAccRightSorted(ia);
PVmeanDensity = cellDensities.PV_mean(ib);

%-------------------------------------------------------------------------------
% Export data to csv:
dataFileOut = 'PV_density.csv';
fid = fopen(dataFileOut,'w');
fprintf(fid,'regionName,\tregionHemisphere,\tbalancedAccuracy(%%),\tPV_CellDensity\n');
for i = 1:length(regionsMatch)
    fprintf(fid,'%s,\t%s,\t%g,\t%g\n',regionsMatch{i},'right',accRight(i),PVmeanDensity(i));
end
fclose(fid);

%-------------------------------------------------------------------------------
% Plot

f = figure('color','w'); hold('on')
isSig = (pValZRightSorted < 0.01);
plot(accRight(~isSig),PVmeanDensity(~isSig),'.k');
plot(accRight(isSig),PVmeanDensity(isSig),'ok');
for i = 1:23
    if isSig(i)
        text(accRight(i),PVmeanDensity(i),uniqueRegions{i},'Color','k');
    else
        text(accRight(i),PVmeanDensity(i),uniqueRegions{i},'Color',[0.5,0.5,0.5]);
    end
end
[rho,p] = corr(accRight,PVmeanDensity,'type','Spearman');
xlabel('balAcc (%)')
ylabel('PV cell density')
title(sprintf('rho = %.3f, p = %.1g',rho,p))
