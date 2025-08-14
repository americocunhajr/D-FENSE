## Dynamics for Epidemic Surveillance and Evaluation


**D-FENSE: Dynamics for Epidemic Surveillance and Evaluation** is an initiative to deal with Dengue Virus (DENV) epidemics in Brazil. 

This repository stores and shares surveillance and climate data related to DENV epidemics since 2010. It also presents predictive models for DENV outbreaks in the country. This work seeks to address emerging demands for dengue monitoring and forecasting, contributing to detailed analysis and supporting decision-making in public health.
The objectives of this initiative include:

- Storing and organizing relevant data on dengue cases in Brazil;
- Building tools for clear and accessible visualization of dengue-related data;
- Developing mathematical models for reliable short-term dengue progression forecasting;
- Disseminating high-quality information to the interested public, aiding in the understanding and combating of dengue.

## Team
- Americo Cunha Jr (LNCC / UERJ, Brazil)
- Emanuelle Arantes Paixão (LNCC, Brazil)
- Marcello Montillo Provenza (UERJ, Brazil)
- Marcelo Rubens dos Santos do Amaral (UERJ, Brazil)
- Marcio Rentes Borges (LNCC, Brazil)
- Paulo Antonio Andrade Esquef (LNCC, Brazil)
- Sergio Luque (LNCC, Brazil)
- Thiago Malheiros Porcino (LNCC, Brazil)
- Vinicius Layter Xavier (UERJ, Brazil)

## Collaborators
- Christian Soize (Université Gustave Eiffel, France)
- Golnaz Shahtahmassebi (Nottingham Trent University, UK)
- Rebecca E. Morrison (University of Colorado Boulder, USA)

## Repository structure

```
D-FENSE/
│
├── DengueSprint2024_ChallengeRules/           # Official 2024 challenge docs (scope, submission rules, etc)
├── DengueSprint2024_DataAggregated/           # 2024 data after basic aggregation and harmonization
├── DengueSprint2024_DataProcessed/            # 2024 data after spurious values cleaning and noise filtering
├── DengueSprint2024_DataProcessingCode/       # Codes used for data processing in 2024 Sprint
│
├── DengueSprint2025_ChallengeRules/           # Official 2025 challenge docs (scope, submission rules, etc)
├── DengueSprint2025_DataAggregated/           # 2025 data after basic aggregation and harmonization
├── DengueSprint2025_DataProcessed/            # 2025 data after spurious values cleaning and noise filtering
├── DengueSprint2025_DataProcessingCode/       # Codes used for data processing in 2025 Sprint
│
├── DengueSprint2025_DataVisualization/        # Graphs to visualize surveillance and climate variables
│
├── DengueSprint2025_Model1_LNCC-ARp/          # Codes and results obtained with the LNCC-ARp model
├── DengueSprint2025_Model2_UERJ-SARIMAX/      # Codes and results obtained with the UERJ-SARIMAX model
├── DengueSprint2025_Model3_LNCC-CLiDENGO/     # Codes and results obtained with the LNCC-CLiDENGO model
├── DengueSprint2025_Model4_LNCC-SURGE/        # Codes and results obtained with the LNCC-SURGE model
```

## Data Source

The raw data used here was obtained in the Mosqlimate platform:
[https://sprint.mosqlimate.org/data/](https://sprint.mosqlimate.org/data/)

Reference:
- F. C. Coelho et al., Full dataset for dengue forecasting in Brazil for Infodengue-Mosqlimate sprint 2024, [https://zenodo.org/records/13328231](https://zenodo.org/records/13328231)

## Data Processing

This data processing framework involves a two-step, reproducible MATLAB pipeline that converts the Mosqlimate raw files into UF-level weekly time series ready for visualization and modeling.

Raw data files (download from https://sprint.mosqlimate.org/data):
- dengue.csv
- climate.csv
- map_regional_health.csv

Put these CSVs files into the repository 'DengueSprint2025_DataProcessingCode/DataRaw/'

Step 1 — Aggregate (DFENSE_DataAggregation.m):

- Cleans basic fields (positivity & types) and keeps epiweeks 201001–202452 (YYYYWW, 52 weeks/year)
- Aggregates municipality → UF by epiweek: cases = sum, climate variables = mean (min/mean/max kept), rainy_days = max
- Exports UF CSVs to DataAggregated/ and quick-look “_Raw” plots to Figures/

Step 2 — Filter & Smooth (DFENSE_DataFilteringSmoothing.m):

- Denoises each series with SVD + Savitzky–Golay, light spline smoothing, then resamples weekly
- Rounds integer fields (cases, rainy_days) and clips negatives to zero
- Exports UF CSVs to DataProcessed/ and “_Filtered” plots to Figures/

Output schema (columns in CSV, one row per UF × week):
- epiweek 
- cases
- temp_min
- temp_med
- temp_max
- precip_min
- precip_med
- precip_max
- pressure_min
- pressure_med
- pressure_max
- rel_humid_min
- rel_humid_med
- rel_humid_max
- thermal_range
- rainy_days

## Data Visualization

Authors: 
- Prof. Americo Cunha Jr (LNCC / UERJ, Brazil)
- Prof. Thiago Malheiros Porcino (LNCC, Brazil)

Soon!

## Data Statistics

Authors:
- Prof. Marcello Montillo Provenza (UERJ, Brazil)
- Prof. Marcelo Rubens dos Santos do Amaral (UERJ, Brazil)
- Prof. Vinicius Layter Xavier (UERJ, Brazil)

Soon!

## Model 1: LNCC-ARp

<div style="display: flex; align-items: center; flex-wrap: wrap;">
  <div style="flex: 0 0 auto; margin-right: 20px;">
    <img src="logo/logo-AR_p.png" alt="LNCC-AR_p" width="20%">
  </div>
  <div style="flex: 1 1 auto; min-width: 250px;">
    <strong>ARp</strong> is a forecasting model for DENV dynamics through an autoregressive process of order p. 
  </div>
</div>

#### Repository structure:
```
D-FENSE/DengueSprint2025_Model1_LNCC-ARp/
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


## Model 2: UERJ-SARIMAX

<div style="display: flex; align-items: center; flex-wrap: wrap;">
  <div style="flex: 0 0 auto; margin-right: 20px;">
    <img src="logo/logo-SARIMAX.png" alt="UERJ-SARIMAX" width="20%">
  </div>
  <div style="flex: 1 1 auto; min-width: 250px;">
    <strong>SARIMAX</strong> is a forecasting model for DENV dynamics through a seasonal autoregressive integrated moving average with exogenous inputs. 
  </div>
</div>

#### Repository structure:
```
DengueSprint2025_Model2_UERJ-SARIMAX/
  │
  |── validation_X_sarimax_ZZ.csv: model output files for validation challenge X in the state ZZ
  │
  |── DengueSprint2025_SARIMAX_ZZ.R: code to run the model for state ZZ
```

#### Author: 
- Prof. Marcelo Rubens Amaral (UERJ, Brazil)

#### Data and Variables: 


#### Model Structure and Training:


#### Forecasting: 


#### Predictive Uncertainty: 


#### Model Output:
- median prediction: 50% percentile
- 50% prediction interval: from 25% percentile to 75% percentile
- 80% prediction interval: from 10% percentile to 90% percentile
- 90% prediction interval: from 5% percentile to 95% percentile
- 95% prediction interval: from 2.5% percentile to 97.5% percentile

#### Libraries and Dependencies (MATLAB):
-

## Model 3: LNCC-CLiDENGO

<div style="display: flex; align-items: center; flex-wrap: wrap;">
  <div style="flex: 0 0 auto; margin-right: 20px;">
    <img src="logo/logo-CLiDENGO.png" alt="LNCC-CLiDENGO" width="20%">
  </div>
  <div style="flex: 1 1 auto; min-width: 250px;">
    <strong>CLiDENGO — CLimate Logistic DENGue Outbreak Simulator</strong> is a forecasting model for DENV dynamics through a mechanistic, stochastic climate-modulated β-logistic growth model for weekly dengue cases at the state (UF) level. It couples a flexible epidemic growth core with a climate response so that periods of favorable weather (e.g., warm, humid, rainy) accelerate epidemic growth in a data-driven way.
  </div>
</div>

#### Repository structure:
```
DengueSprint2025_Model3_LNCC-CLiDENGO/
│
|── DengueSprint2025_DataAggregated: surveillance and climate data aggregated at the state level
│
|── DengueSprint2025_DataValidation1: model output files for validation challenge 1
|── DengueSprint2025_DataValidation2: model output files for validation challenge 2
|── DengueSprint2025_DataValidation3: model output files for validation challenge 3
│
|── logo: D-FENSE team logo files
```

#### Authors:
* Prof. Americo Cunha Jr (LNCC/UERJ, Brazil)
* Prof. Emanuelle Arantes Paixão (LNCC, Brazil)
* Prof. Christian Soize (Université Gustave Eiffel, France)

#### Data and Variables: 
We use surveillance (weekly probable cases) together with climate covariates - temperature (min/mean/max), precipitation (min/mean/max), and relative humidity (min/mean/max) - aggregated at the UF level. Data are arranged as seasons of 52 weeks, from EW 41 of year Y to EW 40 of Y+1. Climate series are min–max normalized on the training set and lightly denoised to form a baseline seasonal signal; case series are also denoised for QoI preparation while keeping values non-negative and integer when reported. Training uses multiple past seasons (e.g., 2010–2011 to 2020–2021); the next season (e.g., 2022–2023) is held out for validation. These inputs come from the 'DengueSprint2025_DataAggregated' repository.

#### Model Structure: 
CLiDENGO forecasts weekly dengue incidence by integrating a β-logistic growth ODE whose effective growth rate can be modulated by climate (temperature, precipitation, relative humidity). The model is trained per state (UF) and produces median and 50/80/90/95% prediction intervals.

- State variable: The model tracks the cumulative number of probable cases per week, denoted here as C(t). The incidence (new cases per week) is computed as the model’s rate of change, reported as dC(t).
- Growth law: The epidemic growth belongs to the beta-logistic family. In words:
	*	the growth rate increases with the current epidemic size following an “early growth” exponent q;
	*	growth slows down as the curve approaches a final size K, with asymmetry controlled by alpha and late-time sharpness by p;
	*	a baseline growth scale r0 multiplies the whole response.
- Climate modulation: The baseline growth r0 can be modulated by climate using smooth suitability factors (Brière-type) for temperature, precipitation, and relative humidity. Each factor maps the normalized climate series to a value in [0,1] using biologically plausible lower/upper thresholds (e.g., temperature roughly in the 18–32 °C window). The effective growth is r0 multiplied by one or more of these suitability factors (temperature only, temperature × precipitation, or temperature × precipitation × humidity; the switch is in the code).
- Climate preprocessing: Raw climate series (weekly medians with min/max envelopes) are min-max normalized over the training data range, denoised with a short symmetric filter and/or SVD-based smoothing, and can be time-shifted by integer lags lag_T, lag_P, lag_H (negative values mean climate leads the cases by that many weeks).
- Initial condition: The initial cumulative value C0 for each season is taken from the first week (EW 41) of that season. For stochastic runs, C0 is sampled from the pool of training-season initial values.
-	Stochastic parameters: Around the calibrated means, the model draws random parameters per Monte Carlo realization using simple distributions controlled by coefficients of variation:
	*	r0 ~ Gamma;
	*	p ~ shifted-Gamma (bounded below by 1);
	*	K, q, alpha ~ Uniform on symmetric intervals around their means;
	*	C0 ~ empirical draw from the training seasons.
-	Integration: For each realization, the ODE is integrated weekly across the 52-week window with ode45. The code returns an ensemble of C(t) and dC(t) to compute medians and prediction intervals.

#### Model Training: 
Each season is 52 weeks from EW 41 of year Y to EW 40 of Y+1 (consistent with the Sprint evaluation windows). Validation is one season ahead. For instance, for validation challenge 1, training uses seasons 2010–2011 to 2020–2021, and validation uses the 2022-2023 season. Prior (probabilistic) model parameters are identified by least squares using historical seasons as observations (each season spans EW 41 of year Y to EW 40 of year Y+1). Fitting is performed per UF, yielding a climate-response and logistic growth structure tailored to each state.

#### Forecasting: 
With the identified parameters and lags, we re-run the simulator with a larger ensemble (thousands of realizations) and integrate the ODE 52 weeks into the future (EW 41 → EW 40 of the next year). For each realization, we obtain weekly incidence and cumulative trajectories driven by the climate modulators. Reported weekly cases are kept non-negative and rounded to integers.

#### Predictive Uncertainty:
From the Monte Carlo simulation, done with 1024 realizations by sampling from the learned parameter priors (and perturbing climate inputs), we compute the mean and central prediction intervals at 50%, 80%, 90%, 95% using prctile.m. Lower bounds use the 25%, 10%, 5%, and 2.5% percentiles; upper bounds use the 75%, 90%, 95%, and 97.5% percentiles, respectively. 

#### Model Output:
- median prediction: mean value
- 50% prediction interval: from 25% percentile to 75% percentile
- 80% prediction interval: from 10% percentile to 90% percentile
- 90% prediction interval: from 5% percentile to 95% percentile
- 95% prediction interval: from 2.5% percentile to 97.5% percentile

#### Libraries and Dependencies (MATLAB):
- fmincon.m (Optimization Toolbox)
- gamrnd.m (Statistics and Machine Learning Toolbox)
- prctile.m (Statistics and Machine Learning Toolbox)

## Model 4: LNCC-SURGE

<div style="display: flex; align-items: center; flex-wrap: wrap;">
  <div style="flex: 0 0 auto; margin-right: 20px;">
    <img src="logo/logo-SURGE.png" alt="LNCC-SURGE" width="20%">
  </div>
  <div style="flex: 1 1 auto; min-width: 250px;">
    <strong>SURGE</strong> is a forecasting model for DENV dynamics through an average surge model.
  </div>
</div>

#### Repository structure:
```
D-FENSE/DengueSprint2025_Model4_LNCC-SURGE/
│
|── Aggregated_Data: surveillance data aggregated at the state level
│
|── DFense_SurgeModel: codes and results for the 3 validation challenges
  │
  |_ validation1: material related to validation 1 challenge
      |_ matlab: Matlab scripts needed to run (run_batch_v1_predictor_Surge_Model.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |_ planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |_ plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
  │
  |_ validation2: material related to validation 2 challenge
      |_ matlab: Matlab scripts needed to run (run_batch_v2_predictor_Surge_Model.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |_ planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |_ plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
  │
  |── validation3: material related to validation 3 challenge
      |_ matlab: Matlab scripts needed to run (run_batch_v3_predictor_Surge_Model.m) the simulation and generate the CSV and PDF files, related to dengue case predictions for each state. CSV files are stored in planilhas, and related plots (in PDF) are stored in plots  
      |_ planilhas: stores CSV files, one for each state, with predictions of dengue cases
      |_ plots: stores PDF files, one for each state, with 4 subplots related to predictions of dengue cases: median prediction, 50%, 80%, 90%, and 95% prediction intervals.
```

#### Author: 
- Prof. Paulo Antonio Andrade Esquef (LNCC, Brazil)

#### Data and Variables: 
Only the time series of the raw number of dengue cases per state along epidemic weeks has been used. Data are available from the 'Aggregated_Data' repository.

#### Model Structure and Training:
For each state (UF), a time series of raw dengue cases, in the defined range for each validation, has been organized in blocks of 52 samples (one year), from EW 41 until the EW 40 of the next year. Assuming that the dengue surges happen about the same time (around EW 15) each year, an average or typical surge (outbreak) curve has been obtained. Assuming the surge is symmetrical with respect to its local maximum, a centralized (to its peak) version of the surge is obtained. From the typical centralized surge, we estimate the parameters (L,k,x0) of the derivative of the logistic model, using a nonlinear estimator (lsqcurvefit.m, with algorithm 'trust-region-reflective'). Then, we use a template matching filter scheme to find the local maxima of the cross-correlation coefficient sequence between the model surge (template) and the observed surges over time. After time-synchronizing the model with a given observed surge, we calculate the amplitude gain that, when applied to the model, matches it with each observed surge. We do that for each surge and obtain a set of amplitude gains, which are positive. The dengue cases prediction is simply given by a gain that multiplies the surge model. Assuming that the set of gains follows a log-normal distribution, we use the set of gains to estimate the related mean and sigma of a log-normal distribution. To predict the dengue cases, we generate 10k gains from the previously estimated log-normal distribution and apply it to the model surge, properly placed in time. From the set of these 10k case predictions, the median, lower- and upper-bounds of the 50%, 80%, 0%, 90%, and 95% prediction intervals are calculated. Finally, we cropped out the predictions to be in the range from EW 41 of a given year to EW 40 of the subsequent year.

#### Forecasting: 
From the trained/estimated typical surge model, after time-synchronizing the surge model with a given observed surge, we calculate the amplitude gain that, when applied to the model, matches each observed surge. We do that for each surge and obtain a set of amplitude gains, which are positive. The dengue cases prediction is simply given by a gain that multiplies the surge model. Assuming that the set of gains follows a log-normal distribution, we use the set of gains to estimate the related mean and sigma of a log-normal distribution. To predict the dengue cases, we generate 10k gains from the previously estimated log-normal distribution and apply it to the model surge, properly placed in time. From the set of these 10k case predictions, the median, lower- and upper-bounds of the 50%, 80%, 0%, 90%, and 95% prediction intervals are calculated. Finally, we cropped out the predictions to be in the range from EW 41 of a given year to EW 40 of the subsequent year.

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
- lsqcurvefit.m (Optimization Toolbox)

## How to Cite This Repository

If you wish to cite this repository in a document, please use the following reference:

- D-FENSE: Dynamics for Epidemic Surveillance and Evaluation, GitHub repository, 2024, [https://github.com/americocunhajr/D-FENSE](https://github.com/americocunhajr/D-FENSE)

In BibTeX format:

```bibtex
@misc{D-FENSE-GitHub,
   author       = {A. {Cunha~Jr} et al.},
   title        = { {D-FENSE}: {D}ynamics for {E}pidemic {S}urveillance and {E}valuation},
   year         = {2025},
   publisher    = {GitHub},
   journal      = {GitHub repository},
   howpublished = {https://github.com/americocunhajr/D-FENSE},
}
```

## License

All material available in this repository is licensed under the terms of the CC-BY-NC-ND 4.0 license.

<img src="logo/CC-BY-NC-ND.png" width="20%">

## Institutional support

 <img src="logo/logo_lncc.png" width="25%"> &nbsp; &nbsp; <img src="logo/logo_uerj.png" width="13%"> 

## Funding

<img src="logo/cnpq.png" width="20%"> &nbsp; &nbsp; <img src="logo/capes.png" width="10%">  &nbsp; &nbsp; &nbsp; <img src="logo/faperj.png" width="20%">

## Contact
For any questions or further information, please contact:

Americo Cunha Jr: americo@lncc.br
