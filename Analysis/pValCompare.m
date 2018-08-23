
leftOrRight = 'right';

whatAnalysis = 'Excitatory_SHAM';
[fIDs_1,FDR_qvals_1] = ConsensusFeatures(whatAnalysis,leftOrRight);

whatAnalysis = 'PVCre_SHAM';
[fIDs_2,FDR_qvals_2] = ConsensusFeatures(whatAnalysis,leftOrRight);

% Are p-values correlated between conditions?:
[r,p] = corr(FDR_qvals_1,FDR_qvals_2,'type','Spearman');

f = figure('color','w');
plot(FDR_qvals_1,FDR_qvals_2,'.k')
