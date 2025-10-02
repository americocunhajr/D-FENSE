
## Model 5: UERJ-SARIMAX-2025-2

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
DengueSprint2025_Model2_UERJ-SARIMAX-2025-2/
  │
  |── validation_X_sarimax_ZZ.csv: model output files for validation challenge X in the state ZZ
  │
  |── DengueSprint2025_SARIMAX_ZZ.R: code to run the model for state ZZ
```

#### Author: 
- Prof. Marcelo Rubens dos Santos do Amaral (UERJ, Brazil)

#### Data and Variables: 
- Preparation:
	* Build ln100_casos = log( cases + 100 ).
	* Convert the data frame to a ts object with frequency = 52 and the desired start.
- Order selection:
	* Run auto.arima on the training slice with xreg = cbind(temp_med, rolling_mean_52w(precip_med)) to get a reasonable starting point.
	* Fit the final SARIMAX with TSA::arima, specifying (p, d, q) and (P, D, Q) per validation window, still with the same xreg. Examples in the scripts include:
	     * T3: nonseasonal (1, 0, 1), seasonal (2, 1, 1);
	     * T2: nonseasonal (2, 0, 1), seasonal (0, 0, 0);
	     * T1: nonseasonal (2, 0, 1), seasonal (0, 0, 1).
- Diagnostics: Residuals and outliers can be checked; detectAO results can be added as intervention dummies if a state exhibits strong shocks. However, even in the locations and periods where relevant shocks were detected, they were not subject to intervention with dummy variables.

#### Model Structure and Training:
- State and transform: The target series is weekly dengue incidence per state. To stabilize variance and avoid zeros, the model works on the log-offset scale: y(t) = log( cases(t) + 100 ). Forecasts are back-transformed as exp( ŷ ) − 100 and truncated at zero when needed.
- Seasonality and frequency: Data are cast as a weekly time series with frequency 52. Seasonal patterns around the same weeks each year are handled by seasonal ARIMA components.
- Model class: Each state is fitted with a seasonal ARIMA with exogenous regressors (SARIMAX). The nonseasonal orders (p, d, q) and seasonal orders (P, D, Q) are chosen per validation window. The workflow uses forecast::auto.arima to suggest orders, then a final manual ARIMA specification is fitted with TSA::arima. In this final/manual stage, we did not use the models automatically identified through the auto.arima() function to adjust the forecast model, because they are based on one-step-ahead adjustment. As the models were adjusted with a view to projecting up to 67 weeks ahead, that is, more than a year ahead, we sought to establish a pattern of model orders closest to the parsimonious non-seasonal (1, 0, 1) and seasonal (1, 1, 1) pattern based on the visual analysis of the graphs of the series' evolution.
- Exogenous climate inputs: Two climate regressors enter the model on the right-hand side:
	* weekly temperature median (temp_med);
	* a 52-week rolling mean of precipitation median (precip_med, averaged over the previous 52 weeks) to capture accumulated rainfall effects.
	* These are supplied in xreg during fitting and in newxreg during forecasting.
- Outliers: Additive outliers are probed with forecast::detectAO. The code keeps the IO option commented in the final fit, but it documents the option to include outlier indicators if needed.

#### Forecasting: 
- Horizon: The scripts forecast 67 weeks ahead, which comfortably covers EW 26 to EW 40 of the next season for reporting.
- Exogenous paths: Supply future temp_med and the future rolling mean of precip_med in newxreg over the forecast horizon. These come from the same aggregated dataset. As climate variables are seasonal, for all periods we used a naive forecast of them based on the repetition of values from the same epidemiological week of the previous two years.
- Point forecasts and uncertainty on the log scale. Use predict(…, n.ahead = 67) to obtain the mean forecast and the standard error per step on the log-offset scale.

#### Predictive Uncertainty: 
- Intervals on the log scale: Build symmetric intervals as mean ± z * se with Gaussian quantiles for 95, 90, 80, and 50 percent levels.
- Back-transform: Convert each bound with exp( bound ) − 100. Lower bounds are truncated at zero to respect nonnegativity.
- Reported bands: The repository exports median (prev_med) and the lower/upper bounds for 50%, 80%, 90%, and 95% intervals.


#### Model Output:
- Per-state CSVs like T1_arimax_UF.csv, T2_arimax_UF.csv, T3_arimax_UF.csv, where UF is the two-letter state code.
- Columns prior to standardization (as produced by the R scripts): Data, prev_med, LB_95, UB_95, LB_90, UB_90, LB_80, UB_80, LB_50, UB_50. These are later renamed and reordered to the sprint’s standard: lower_95, lower_90, lower_80, lower_50, pred, upper_50, upper_80, upper_90, upper_95, date.

#### Libraries and Dependencies (R):
- forecast (for auto.arima, forecasting interfaces)
- TSA (for arima with exogenous regressors)
- zoo (for rollsumr to build the 52-week precipitation rolling mean)
- Mcomp (loaded in the script; not essential for the SARIMAX fit itself)
