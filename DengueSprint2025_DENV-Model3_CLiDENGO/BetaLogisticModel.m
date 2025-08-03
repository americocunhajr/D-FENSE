% -----------------------------------------------------------------
% BetaLogisticModel.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%              americo.cunhajr@gmail.com
%
%  Originally programmed in: Feb 13, 2025
%            Last update in: Jul 22, 2025
% -----------------------------------------------------------------
%  This function defines the ODE for the beta-logistic growth model,
%  with growth rate optionally modulated by temperature via a smooth
%  Briere function:
%  
%          dCdt = r*(C^q)*(1-(C/K)^alpha)^p
%
%  Model quantity                                   Unit
%  C        = cumulative number of probable cases   (individuals)
%  dCdt     = probable cases rate of change         (individuals/time)
%  r0       = baseline growth rate (r0 > 0)         (time^-1)
%  K        = epidemic final size (K > 0)           (individuals)
%  q        = initial growth profile (0 <= q <=1)   (dimensionless)
%  p        = late-time growth rate (p >= 1)        (dimensionless)
%  alpha    = degree of asymmetry (alpha >= 0)      (dimensionless)
%  m        = Briere asymmetry factor               (dimensionless)
%  delta    = Briere fitting factor                 (dimensionless)
%  beta     = boundary smoothness factor            (dimensionless)
%  r_inf    = final growth rate                     (time^-1)
%  eta      = rate of change for beta               (time^-1)
%  tau_beta = growth rate inflexion time            (time   )
%  T_min     = minimum temperature threshold        (temperature)
%  T_max     = maximum temperature threshold        (temperature)
%  T        = temperature time series               (temperature)
%  tspan    = temporal mesh                         (time)
% -----------------------------------------------------------------
function dCdt = BetaLogisticModel(t,C,ModelStruct)

    % model parameters
    r0      = ModelStruct.r0;
    K       = ModelStruct.K;
    q       = ModelStruct.q;
    p       = ModelStruct.p;
    alpha   = ModelStruct.alpha;
    m       = ModelStruct.m;
    delta   = ModelStruct.delta;
    beta    = ModelStruct.beta;
    T_min   = ModelStruct.T_min;
    T_max   = ModelStruct.T_max;
    P_min   = ModelStruct.P_min;
    P_max   = ModelStruct.P_max;
    H_min   = ModelStruct.H_min;
    H_max   = ModelStruct.H_max;
    T       = ModelStruct.T;
    P       = ModelStruct.P;
    H       = ModelStruct.H;
    tspan   = ModelStruct.tspan;
    
    % compute Briere modifiers for climate variables
    Briere_T = BriereSmooth(T,T_min,T_max,1,m,delta,beta);
    Briere_P = BriereSmooth(P,P_min,P_max,1,m,delta,beta);
    Briere_H = BriereSmooth(H,H_min,H_max,1,m,delta,beta);
    
    % normalize Briere modifiers (0 <= Briere <= 1)
    Briere_T = Briere_T./max(Briere_T);
    Briere_P = Briere_P./max(Briere_P);
    Briere_H = Briere_H./max(Briere_H);

    % interpolate climate variables at current time
    T_t = interp1(tspan,T,t);
    P_t = interp1(tspan,P,t);
    H_t = interp1(tspan,H,t);
    
    % interpolate Briere modifiers at current time
    Briere_T_t = interp1(T,Briere_T,T_t);
    Briere_P_t = interp1(P,Briere_P,P_t);
    Briere_H_t = interp1(H,Briere_H,H_t);

    % effective growth rate
    %r_eff = r0;
    %r_eff = r0.*Briere_T_t;
    %r_eff = r0.*Briere_T_t.*Briere_P_t;
    r_eff = r0.*Briere_T_t.*Briere_P_t.*Briere_H_t;

    % Beta-logistic differential equation
    dCdt = r_eff.*(C.^q).*(1-(C./K).^alpha).^p;
end
% -----------------------------------------------------------------