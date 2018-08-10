# hctsa_DREADD

Analysis of DREADDs time-series data

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

## Data analysis

### How different are dynamics at a given time point

```matlab
FirstTimePointClassification('Excitatory_SHAM','reduced','ts2',100)
```

### Which features are discriminatory

```matlab
DiscriminativeFeatures(whatAnalysis,leftOrRight,whatFeatures,theTimePoint)
```
