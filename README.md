# hctsa_DREADD

Analysis of DREADDs BOLD time-series data

## Data preparation
You must have the following files downloaded or computed in the directories below:
* `HCTSA_Control/HCTSA.mat`
* `HCTSA_Control/HCTSA_PVCre.mat`
* `HCTSA_LeftCTX/HCTSA.mat`
* `HCTSA_LeftCTX/HCTSA_PVCre.mat`
* `HCTSA_RightCTX/HCTSA.mat`
* `HCTSA_RightCTX/HCTSA_PVCre.mat`

## Data processing
Preparation of raw HCTSA data into different subsets for processing can be achieved by running:
```matlab
DoAllProcessing()
```

This script does the following steps:

### Splitting into files for specific sets of classes
For example, to make new files for classification of excitatory versus SHAM:

```matlab
FilterDataset('Excitatory_SHAM');
```

### Convert to baseline differences
Normalize features of each mouse across time relative to their baseline dynamics:

```matlab
ConvertToBaselineDiffs('right','Excitatory_SHAM','subtract')
```

### Label groups of time series for a given analysis
For right-hemisphere excitatory-sham analysis, corrects raw data, and data following subtraction of baseline features
```matlab
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo('right','Excitatory_SHAM');
LabelDREADDSGroups(false,'right',rawData,'Excitatory_SHAM')
LabelDREADDSGroups(false,'right',rawDataBL,'Excitatory_SHAM')
```

### Split by time point
For excitatory-sham differences:
```matlab
SplitByTimePoint('Excitatory_SHAM',false)
```

For excitatory-sham differences (relative to baseline):
```matlab
SplitByTimePoint('Excitatory_SHAM',true)
```

### A reduced feature set
Can generate a reduced feature set using a custom similarity threshold here:

```matlab
ProduceReducedFeatures()
```

## Data analysis

A range of different analysis types in terms of labeling of classes of data:

* `Excitatory_SHAM`
* `PVCre_SHAM`
* `Wild_SHAM`
* `Excitatory_PVCre`
* `PVCre_Wild`
* `Excitatory_Wild`
* `Excitatory_PVCre_SHAM`
* `Excitatory_PVCre_Wild_SHAM`

### How different are dynamics at a given time point

This uses 100 nulls (for speed) to compute the difference between excitatory and sham conditions at Delta.1 (`'ts2-BL'`) in each of the three regions of interest (using all features):
```matlab
FirstTimePointClassification('Excitatory_SHAM','all','ts2-BL',100)
```

Running at Delta.2:
```matlab
FirstTimePointClassification('Excitatory_SHAM','all','ts3-BL',1000)
```

### Which features are discriminatory

#### Individual time point:

E.g., characterize specific excitatory-sham differences in the injected region at Delta.1, using all features:
```matlab
DiscriminativeFeatures('Excitatory_SHAM','right','all','ts2-BL')
```

And for PVCre versus control:
```matlab
DiscriminativeFeatures('PVCre_SHAM','right','all','ts2-BL')
```

#### Across multiple time points:
This can be analyzed using `ConsensusFeatures`, which assumes that each measured time point is independent and looks for features that show consistent differences to SHAM across time.
This assumption turns out to be very bad, so p-values obtained from this method are overly optimistic:

```matlab
ConsensusFeatures('Excitatory_SHAM','right','all')
```

### Feature score consistency
Are features selected for a given analysis consistent across all time points?
```matlab
testStatCompareTime('Excitatory_SHAM','right','all')
```

Are `Excitatory_SHAM` features similar to `PVCre_SHAM` features (at individual time points)?
```matlab
testStatCompareConditionTime('right','all')
```

Do consensus features selected in `Excitatory_SHAM` differ from those selected in `PVCre_SHAM`?
```matlab
pValCompare
```

Can feature scores be measured relative to those in a control region to look for additional correlations in specific brain regions?
```matlab
testStatRelativeControl('right','all')
testStatBar('all',false)
```

### Plotting differences
Plot low-dimensional projections of the data:
```matlab
LowDimProj('Excitatory_SHAM','right')
```

Plots for feature ID 33, distributions relative to baseline for `Excitatory_SHAM` in the right hemisphere region:
```matlab
PlotConsensus(33,'Excitatory_SHAM','right')
```
