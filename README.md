# hctsa_DREADD

Analysis of DREADDs BOLD time-series data

## Data processing

Splitting of HCTSA data into different subsets can be achieved by running:
```
DoAllProcessing()
```

This script does the following:

### Convert to baseline differences

```matlab
ConvertToBaselineDiffs('right','Excitatory_SHAM')
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

### How different are dynamics at a given time point

This uses 100 nulls (for speed) to compute the difference between excitatory and sham conditions at Delta.1 (`'ts2-BL'`) in each of the three regions of interest:
```matlab
FirstTimePointClassification('Excitatory_SHAM','reduced','ts2-BL',100)
```

### Which features are discriminatory

This characterizes specific excitatory-sham differences in the injected region at Delta.1, using a reduced feature set.
```matlab
DiscriminativeFeatures('Excitatory_SHAM','right','reduced','ts2-BL')
```
