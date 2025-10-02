
## Model 1: LNCC-ARp-2025-1

<div style="display: flex; align-items: center; flex-wrap: wrap;">
  <div style="flex: 0 0 auto; margin-right: 20px;">
    <img src="../logo/logo-AR_p.png" alt="LNCC-AR_p" width="20%">
  </div>
  <div style="flex: 1 1 auto; min-width: 250px;">
    <strong>ARp</strong> is a forecasting model for DENV dynamics through an autoregressive process of order p. 
  </div>
</div>

#### Repository structure:
```
D-FENSE/DengueSprint2025_Model1_LNCC-ARp-2025-1/
│
|── Aggregated_Data: surveillance data aggregated at the state level
│
|── DFense_ARp: codes and results for the 3 validation challenges
  │
  |── validation1: material related to validation 1 challenge
      |── matlab: Matlab scripts needed to run (run_batch_v1_predictor_ARp.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |── planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |── plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
  │
  |_ validation2: material related to validation 2 challenge
      |── matlab: Matlab scripts needed to run (run_batch_v2_predictor_ARp.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |── planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |── plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
  │
  |── validation3: material related to validation 3 challenge
      |── matlab: Matlab scripts needed to run (run_batch_v3_predictor_ARp.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |── planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |── plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
```

#### Author: 
- Prof. Paulo Antonio Andrade Esquef (LNCC, Brazil)

#### Data and Variables: 
Only the time series of the raw number of dengue cases per state along epidemic weeks has been used. Data are available from the 'Aggregated_Data' repository.

#### Model Structure and Training: 
For each state (UF), the log2 mapping of time-series of raw dengue cases, in the defined range for each validation, has been used to estimate an AR(p), p=92 (experimentally chosen), via the function armcov.m. Initial conditions for the AR(p) model at epidemic week (EW) 25 of 2022/23/24 have been obtained by a simple scheme of inverse filtering of the time-series, followed by direct filtering of the modeling error. The modeling error sequence has been organized in a matrix with 52 columns, with each row representing a modeling error sequence for a single year. Assuming a zero-mean Gaussian White noise distribution for the modeling error ensemble, the standard deviation of a typical model excitation has been estimated. Then, a Monte Carlo simulation with 10k runs was carried out to generate predictions for dengue cases: the AR(p) and initial conditions were fixed, only the model excitation was drawn from a Gaussian distribution. Each of these model excitations has 79 samples, covering a forecast from EW 26 of a given year to EW 52 of the subsequent year. Then, the attained results have been mapped back to the original amplitude domain (via the inverse of the log2 function). From the set of these 10k case predictions, the median, lower- and upper-bounds of the 50%, 80%, 0%, 90%, and 95% prediction intervals are calculated. Finally, the resulting curves are smoothed out via an SSA (Singular Spectral Analysis) filter and cropped out to be in the range from EW 41 of a given year to EW 40 of the subsequent year.

#### Forecasting: 
From the trained/estimated model, we run a Monte Carlo simulation with 10k runs to generate the dengue cases predictions: the AR(p) and initial conditions were fixed, only the model excitation has been drawn from a zero-mean Gaussian distribution, whose standard deviation has been estimated from the modeling error. Each of these artificially generated model excitations has 79 samples, covering a forecast range from EW 26 of a given year to EW 52 of the subsequent year. Then, the attained results have been mapped back to the original amplitude domain (via the inverse of the log2 function, 2^(predictions)). From the set of these 10k case predictions, the median, lower- and upper-bounds of the 50%, 80%, 0%, 90%, and 95% prediction intervals have been calculated. Finally, the resulting curves are smoothed out via an SSA (Singular Spectral Analysis) filter and cropped out to be in the range from EW 41 of a given year to EW 40 of the subsequent year.

#### Predictive Uncertainty: 
From the set of 10k case predictions (for each state and each validation), we used the Matlab function prctile.m (percentiles of a sample) to obtain the median, as well as the lower- and upper bounds of 50%, 80%, 90%, and 95% prediction intervals. The median of the case predictions is the 50% percentile. The lower bounds for the 50%, 80%, 90%, and 95% prediction intervals are, respectively, the 25%, 10%, 5%, and 2.5% percentiles. The upper bounds for the 50%, 80%, 90%, and 95% prediction intervals are, respectively, the 75%, 90%, 95%, and 97.5% percentiles.

#### Model Output:
- median prediction: 50% percentile
- 50% prediction interval: from 25% percentile to 75% percentile
- 80% prediction interval: from 10% percentile to 90% percentile
- 90% prediction interval: from 5% percentile to 95% percentile
- 95% prediction interval: from 2.5% percentile to 97.5% percentile

#### Libraries and Dependencies (MATLAB):
- readtable.m (Signal Processing Toolbox)
- buffer.m (Signal Processing Toolbox)
- armcov.m (Signal Processing Toolbox)
- filter.m (Signal Processing Toolbox)
- filter2.m (Signal Processing Toolbox)
- ssa_modPE.m (Singular Spectral Analysis - Smoothing Filter, included in the folder 'matlab').


