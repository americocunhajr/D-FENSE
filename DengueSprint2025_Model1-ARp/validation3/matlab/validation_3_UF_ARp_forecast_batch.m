% Validation 3: forecast using a high-order AR(p) model
% Tasks of this script (for a given BR state):

% 1) Read the time series of dengue cases for a given BR state and estimate an
% high-order AR(p) model to the log2 mapping of the time-series.

% 2) Analyze the modeling error, obtained via inverse filtering,
% considering a seasonality of 52 epidemic weeks (EW). Error analysis will
% inform the tuning of a statistical distribution for excitation generation, 
% for time-series forecast purposes.

% 3) Obtain a set of initial conditions (IC) for the AR(p) model.

% 4) Run a Monte Carlo (MC) simulation for time-series forecast using the
% set of IC and randomly generated model excitation realizations.

% 5) Plot the obtained time-series forecast (mean, upper- and lower-bounds of the prediction interval)

M = readtable(['DengueSprint2025_AggregatedData_',UF,'.csv']); 
% reads data related to the selected state

kcc=M{:,2};  % known dengue cases from EW 1 of 2010 to EW 52 of 2025

ind_v3=701+52;  % index of the end of EW 25 of 2024 (upper bound observed data for validation 2)

cc=kcc(1:ind_v3);  % observed cases from EW 1 of 2010 to EW 25 of 2024

cc(cc==0)=0.1;  % replaces null value in cc with a small value. This is because we will apply 
% a log2 function to the data values. 

lwea=2*52-25;   % number of EW to be forecast, i.e., from EW 26 of 2024 up to EW 52 2025

cclog=log2(cc); % apply a log2 function to the observed raw data 
mcc=mean(cclog); % calculate and save the mean of cclog
sig=cclog-mcc;  % zero-mean log2 observed data

% sig is the signal to be analyzed via an AR(p) model

% Represents oscillations in sig via p-order AR(p) model 
p=92; % model order (p is chosen arbitrarily and should be larger than 52 (season period))
a=armcov(sig,p);  % AR model estimation via the modified covariance method
a=a(:); % makes it a column vector

e1=filter(a,1,sig);  % obtains the modeling error via inverse filtering
% Obs.: e1 will be used to obtain the initial conditions (IC) of the direct
% filter, during forecast
e=filter2(a,sig,'same'); % centered inverse filtering, i.e., vector 'e' is
% time-synchronous with sig
% 'e' is supposed to be white Gaussian noise
% Sequence 'e' will be used to estimate the typical variance of the model
% excitation used to genereate the forecast realizations

eo=e;  % original centered excitation (model error) 

PP=2*52;  % twice the period of 52 EW
% Idea here: we need a forecast of PP-25 weeks ahead. So we will organize
% sequence 'e' into a matrix (column wise) with PP rows, so that the excitations are all
% syncronized from EW 1 to EW 52 of the subsequent year. We later trim-off
% the first 25 rows, so that the excitations cover EW 26 of a given year to EW 52 of the
% subsequent year. We then calculate a mean excitation from the matrix
% columns.


E=buffer(e,PP); % organizes vector 'e' in a matrix with PP rows.
% Each column of E has an excitation vector related to 2 years (104 EWs)

% E will be used to obtain a set of artificial excitations (white Gaussian noise) to the AR model to
% extrapolate the data (time-series forecasting)

E=E'; % transpose matrix E (now with PP columns).
% Each row of E has a excitation vector related to 2 years (104 EWs). For a
% given year: EW 1 of a given year to EW 52 of the subsequent year


mE=mean(E);  % row vector of the mean excitation, i.e., mean of the ensamble (7) of excitations of PP samples
stdE=std(E); % row vector of the standard deviation of the ensamble (7) of excitations of PP samples

med_stdE=median(stdE); % median of vector stdE (informs the standard deviation of 
% a typical white gaussian noise to be generated to excite the direct AP(p) model

% Note: we could use a different standard deviation for each EW, as they are not about equal  
% across EW. Plot stdE to see the pattern. Nevertheless, we are using zero-mean excitations 
% which are white Gaussian noise realizations with the
% same standard-deviation (med_stdE) across the EWs

stdE2=med_stdE.*ones(size(stdE)); % row vector (PP values) with the same value med_stdE

eek=mE(26:end);  % known mean excitation related to EW 26 of 2010 to EW 25 of 2024 
eek=eek(:);  % make it a column vector

[aux,zf]=filter(1,a,e1);  % obtains the initial conditions 'zf' of the direct source-model filter

% Note: zf is the set of initial conditions for the direct AR(p) forecast
% filter, to which an artificial excitation will be fed.

MC=10000; % number of runs of a Monte Carlo simulation

% Now, we generate the set of realizations of artificial model excitations.
RE=randn(MC,PP);  % matrix with random realizations of white Gaussian noise (zero-mean), unit variance 
RE=RE.*(1.0*stdE2); % ajust variance of the noise according to that of the mean excitation 
% We keep a zero-mean realizations and only adjust the variance.

RE(:,1:25)=[];  % removes first 25 columns (since forecast starts from EW 26 onwards)

% Each column of matrix RE contains a realization of the excitation to be
% fed to the AR(p) model

CP_v=zeros(MC,lwea);  % blank matrix to store the forecast values of dengue cases

% The forecast below (with a mean measured excitation) is only for comparison purposes
cases_prediction_d=filter(1,a,eek,(zf));  % forecast using the mean excitation (measured)
cases_prediction_d=2.^(cases_prediction_d+mcc); % maps back to original scale

% Runs the Monte Carlo Simulation
for kk=1:MC 
    ee=RE(kk,:);  % one realization of the excitation (artificially generated)
    cases_prediction=filter(1,a,ee,(zf)); % direct filtering to obtain extrapolated signal with case predited values
    cases_prediction=2.^(cases_prediction+mcc); % maps back to the original scale
    CP_v(kk,:)=cases_prediction; % store forecast values
end

% Calculate statistics based on the set of forecast sequences

%  Obtain approximations of the [50 80 90 95]% prediction intervals (data driven)

set_prctile=[2.5 5 10 25 50 75 90 95 97.5]; % 2.5 to 97.5% percentiles
PP=prctile(CP_v,set_prctile); % calculates the percentiles and stores in PP
forecast_cases_q2p5 = PP(1,:);  % 2.5% percentile 
forecast_cases_q5 = PP(2,:);  % 5% percentile
forecast_cases_q10 = PP(3,:);  % 10% percentile
forecast_cases_q25 = PP(4,:);  % 25% percentile
mean_cases_forecast = PP(5,:);  % 50% percentile - median prediction
forecast_cases_q75 = PP(6,:); % 75% percentile
forecast_cases_q90 = PP(7,:); % 90% percentile 
forecast_cases_q95 = PP(8,:); % 95% percentile 
forecast_cases_q97p5 = PP(9,:); % 97.5% percentile 


% Note: the forecast results (mean, upper and lower bounds) are then 
% filtered by an SSA (Singular Spectral Analysis) reconstruction filter.

L=20; % window length for the SSA filter
nsv=5; % number of selected eigenvalues (ordered)
[mcff]=round(ssa_modPE(mean_cases_forecast,L,nsv)); % filtered mean forecast
[q2p5_f]=round(ssa_modPE(forecast_cases_q2p5,L,nsv));  % filtered 2.5% percentile 
[q5_f]=round(ssa_modPE(forecast_cases_q5,L,nsv));  % filtered 5% percentile 
[q10_f]=round(ssa_modPE(forecast_cases_q10,L,nsv));  % filtered 10% percentile 
[q25_f]=round(ssa_modPE(forecast_cases_q25,L,nsv));  % filtered 25% percentile 
[q75_f]=round(ssa_modPE(forecast_cases_q75,L,nsv));  % filtered 75% percentile 
[q90_f]=round(ssa_modPE(forecast_cases_q90,L,nsv));  % filtered 90% percentile 
[q95_f]=round(ssa_modPE(forecast_cases_q95,L,nsv));  % filtered 95% percentile 
[q97p5_f]=round(ssa_modPE(forecast_cases_q97p5,L,nsv));  % filtered 97.5% percentile 



indf_ini=665+52+52; % time index of the EW 41 2024
indf_end=716+52+52; % time index of the EW 40 2025

% Writes a CSV file with the known and forecast data

epiweek=[(202441:202452)';(202501:202540)'];
cases=kcc(indf_ini:min(indf_end,length(kcc)));
% cases=zeros(52,1);
% range2=indf_ini:length(kcc); Lr2=length(range2);
% cases(1:Lr2)=kcc(indf_ini:length(kcc));

pred_range=indf_end+1-indf_ini; % forecast range
gapf=15;  % gap in samples from EW 26 2024 to EW  40 2024  
median_cases=mcff; median_cases(1:gapf)=[]; median_cases=median_cases(1:pred_range);
q2p5=q2p5_f;  q2p5(1:gapf)=[]; q2p5=q2p5(1:pred_range); % 2.5% percentile 
q5=q5_f;  q5(1:gapf)=[]; q5=q5(1:pred_range); % 5% percentile 
q10=q10_f;  q10(1:gapf)=[]; q10=q10(1:pred_range); % 10% percentile 
q25=q25_f;  q25(1:gapf)=[]; q25=q25(1:pred_range); % 25% percentile 
q75=q75_f;  q75(1:gapf)=[]; q75=q75(1:pred_range); % 75% percentile
q90=q90_f;  q90(1:gapf)=[]; q90=q90(1:pred_range); % 90% percentile
q95=q95_f;  q95(1:gapf)=[]; q95=q95(1:pred_range); % 95% percentile
q97p5=q97p5_f;  q97p5(1:gapf)=[]; q97p5=q97p5(1:pred_range); % 97.5% percentile


%T = table(epiweek,cases,median_cases,q2p5,q5,q10,q25,q75,q90,q95,q97p5);

%writetable(T,['validation_3_ARp_',UF,'.csv'],'Delimiter',',')


LB95=q2p5;
UB95=q97p5;
LB90=q5;
UB90=q95;
LB80=q10;
UB80=q90;
LB50=q25;
UB50=q75;

T = table(epiweek,median_cases,LB95,UB95,LB90,UB90,LB80,UB80,LB50,UB50);

writetable(T,['..\planilhas\validation_3_ARp_',UF,'.csv'],'Delimiter',',')

% Generate plots for each state and saves in PDF files separately

max75=max(q75);
max95=max(q95);
max90=max(q90);
max97p5=max(q97p5);
EW_index=indf_ini:indf_end;


figure
subplot(221)
plot(indf_ini:min(indf_end,length(kcc)),cases,'linewidth',2); % plot known sequence of cases up to EW 52 of 2023
hold on;
plot(EW_index,median_cases,'r','linewidth',2)
plot(EW_index,q25,'k','linewidth',2)
plot(EW_index,q75,'g','linewidth',2)
legend('observed','median forecast','LB50','UB50')  
xlabel('Time (EW index)')
ylabel('Number of Cases')
title(['Forecast 50% -  ',UF])
axis([EW_index(1) EW_index(end) 0 2*max75])

subplot(222)
plot(indf_ini:min(indf_end,length(kcc)),cases,'linewidth',2); % plot known sequence of cases up to EW 52 of 2023
hold on;
plot(EW_index,median_cases,'r','linewidth',2)
plot(EW_index,q10,'k','linewidth',2)
plot(EW_index,q90,'g','linewidth',2)
legend('observed','median forecast','LB80','UB80')  
xlabel('Time (EW index)')
ylabel('Number of Cases')
title(['Forecast 80% -  ',UF])
axis([EW_index(1) EW_index(end) 0 2*max90])

subplot(223)
plot(indf_ini:min(indf_end,length(kcc)),cases,'linewidth',2); % plot known sequence of cases up to EW 52 of 2023
hold on;
plot(EW_index,median_cases,'r','linewidth',2)
plot(EW_index,q5,'k','linewidth',2)
plot(EW_index,q95,'g','linewidth',2)
legend('observed','median forecast','LB90','UB90')  
xlabel('Time (EW index)')
ylabel('Number of Cases')
title(['Forecast 90% -  ',UF])
axis([EW_index(1) EW_index(end) 0 2*max95])

subplot(224)
plot(indf_ini:min(indf_end,length(kcc)),cases,'linewidth',2); % plot known sequence of cases up to EW 52 of 2023
hold on;
plot(EW_index,median_cases,'r','linewidth',2)
plot(EW_index,q2p5,'k','linewidth',2)
plot(EW_index,q97p5,'g','linewidth',2)
legend('observed','median forecast','LB95','UB95')  
xlabel('Time (EW index)')
ylabel('Number of Cases')
title(['Forecast 95% -  ',UF])
axis([EW_index(1) EW_index(end) 0 2*max97p5])

print(['..\plots\Validation3_ARp_',UF],'-dpdf')

close all



