% -----------------------------------------------------------------
%  MyModel.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%              americo.cunhajr@gmail.com
%
%  Originally programmed in: Jul 11, 2025
%            Last update in: Jul 17, 2025
% -----------------------------------------------------------------
%  This function evaluates the stochastic model output function 
%  given by the solution of a beta-logistic epidemic model and 
%  its derivative.
%
%  Input:
%  X           - (Nvars x 1) model parameters vector
%  ModelStruct - struct with the model quantities
%  
%  Output:
%  U           - (nSamp x nReal) matrix with QoIs realizations
%  U           - (nSamp x nReal) matrix with QoIs derivative realizations 
% -----------------------------------------------------------------
function [U,dU] = MyModel(X,ModelStruct)

    % model hyperparameters
    tspan  = ModelStruct.tspan;  % temporal interval of analysis
    nSamp  = length(tspan);      % number of samples in each realization
    nReal  = ModelStruct.nReal;  % number of Monte Carlo realizations
    winLen = ModelStruct.winLen; % temporal window length
    stride = ModelStruct.stride; % step size between indices

    % initial conditions from data
    C0 = ModelStruct.C0;

    % update model parameters
	r0       = X(1);
	K        = X(2);
	q        = X(3);
	p        = X(4);
	alpha    = X(5);
	r0_cv    = X(6);
	K_cv     = X(7);
	q_cv     = X(8);
	p_cv     = X(9);
	alpha_cv = X(10);
	lag_T    = round(X(11));
    lag_P    = round(X(12));
    lag_H    = round(X(13));
     
	ModelStruct.r0    = r0;
    ModelStruct.K     = K;
    ModelStruct.q     = q;
    ModelStruct.p     = p;
    ModelStruct.alpha = alpha;
    
    % climate data time-series
    T_data = ModelStruct.T_data;
    P_data = ModelStruct.P_data;
    H_data = ModelStruct.H_data;

    % baseline (filtered) climate time-series
    T_baseline = ModelStruct.T_baseline;
    P_baseline = ModelStruct.P_baseline;
    H_baseline = ModelStruct.H_baseline;

    % generate syntetic climate time-series
    T_gen = ClimateGen(T_data,T_baseline,winLen,stride,nSamp,nReal);
    P_gen = ClimateGen(P_data,P_baseline,winLen,stride,nSamp,nReal);
    H_gen = ClimateGen(H_data,H_baseline,winLen,stride,nSamp,nReal);

    % apply the time-lag to account climate delay dependence
    T_gen = circshift(T_gen,lag_T);
    P_gen = circshift(P_gen,lag_P);
    H_gen = circshift(H_gen,lag_H);
    
    % generate realizations for the model parameters
    % ---    r0 ~ Gamma distribution
    % ---     K ~ Uniform distribution
    % ---     q ~ Uniform distribution
    % ---     p ~ Translated Gamma distribution
    % --- alpha ~ Uniform distribution
     r0_shape     = 1/r0_cv^2;
     r0_scale     = r0*r0_cv^2;
     K_min        = K*(1-sqrt(3)*K_cv);
     K_max        = K*(1+sqrt(3)*K_cv);
     q_min        = q*(1-sqrt(3)*q_cv);
     q_max        = q*(1+sqrt(3)*q_cv);
     p_shape      = 1/p_cv^2;
     p_scale      = p*p_cv^2;
     alpha_min    = alpha*(1-sqrt(3)*alpha_cv);
     alpha_max    = alpha*(1+sqrt(3)*alpha_cv);
 
        r0_samp = gamrnd(r0_shape,r0_scale,[nReal,1]);
         K_samp = K_min + (K_max-K_min)*rand([nReal,1]);
         q_samp = q_min + (q_max-q_min)*rand([nReal,1]);
         p_samp = 1 + gamrnd(p_shape,p_scale,[nReal,1]);
     alpha_samp = alpha_min + (alpha_max-alpha_min)*rand([nReal,1]);

    % generate syntetic initial conditions
    C0_gen = C0(ceil(numel(C0)*rand(nReal,1)));

    % preallocate memory for the model response
     U = zeros(nSamp,nReal);
    dU = zeros(nSamp,nReal);

    % loop for Monte Carlo simulation
    for j=1:nReal

        % update the random parameters
         ModelStruct.r0     =    r0_samp(j);
         ModelStruct.K      =     K_samp(j);
         ModelStruct.q      =     q_samp(j);
         ModelStruct.p      =     p_samp(j);
         ModelStruct.alpha  = alpha_samp(j);

        % update initial condition realization
        %IC = C0(j);
        IC = C0_gen(j);
        
        % update climate time-series realization
        ModelStruct.T = T_gen(:,j);
        ModelStruct.P = P_gen(:,j);
        ModelStruct.H = H_gen(:,j);
        
        % simulate the model using the current model parameters
        [~,C] = ode45(@(t,x)BetaLogisticModel(t,x,ModelStruct),tspan,IC);
           dC = BetaLogisticModel(tspan,C,ModelStruct);

         % j-th realization of the model response
          U(:,j) = C;
         dU(:,j) = dC;
    end
end
% -----------------------------------------------------------------