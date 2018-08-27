% Compare features that show differences in PVCre–SHAM to those who differ in
% Excitatory_SHAM
% Are they similar?
%-------------------------------------------------------------------------------

% Consensus version:
leftOrRight = 'right';
whatFeatures = 'all';

whatAnalysis = 'Excitatory_SHAM';
[fIDs_1,FDR_qvals_1] = ConsensusFeatures(whatAnalysis,leftOrRight,whatFeatures);

f = figure('color','w');
histogram(FDR_qvals_1)

whatAnalysis = 'PVCre_SHAM';
[fIDs_2,FDR_qvals_2] = ConsensusFeatures(whatAnalysis,leftOrRight,whatFeatures);

f = figure('color','w');
histogram(FDR_qvals_2)

% Match IDs:
[fIDs,ia,ib] = intersect(fIDs_1,fIDs_2);
FDR_qvals_a = FDR_qvals_1(ia);
FDR_qvals_b = FDR_qvals_2(ib);

% Are p-values correlated between conditions?:
[r,p] = corr(FDR_qvals_a,FDR_qvals_b,'type','Spearman');

f = figure('color','w');
plot(FDR_qvals_a,FDR_qvals_b,'.k')
