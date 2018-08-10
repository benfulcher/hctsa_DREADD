# hctsa_DREADD

Analysis of DREADDs time-series data

## Data processing

Splitting of HCTSA data into different subsets can be achieved here:
```
DoAllProcessing
```

Does the following:

*Convert to baseline differences:*
`ConvertToBaselineDiffs('right','Excitatory_SHAM')`

*Label groups of time series for a given analysis:*
For right-hemisphere excitatory-sham analysis, corrects raw data, and data following subtraction of baseline features
```matlab
[prePath,rawData,rawDataBL] = GiveMeLeftRightInfo('right','Excitatory_SHAM');
LabelDREADDSGroups(false,'right',rawData,'Excitatory_SHAM')
LabelDREADDSGroups(false,'right',rawDataBL,'Excitatory_SHAM')
```

*Split by time point:*
1. For excitatory-sham differences `SplitByTimePoint('Excitatory_SHAM',false)`
2. For excitatory-sham differences (relative to baseline) `SplitByTimePoint('Excitatory_SHAM',true)`

## Data analysis
