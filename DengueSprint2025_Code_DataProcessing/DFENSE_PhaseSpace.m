% -----------------------------------------------------------------
%  DFENSE_PhaseSpace.m
% -----------------------------------------------------------------
%  This program plots the phase space for Dengue dynamics 
%  in Brazil over the period 2010-2024.
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               
%  Initially Programmed: Sep 02, 2024
%           Last Update: Sep 02, 2024
% -----------------------------------------------------------------


clc; clear; close all

% program execution start time
% -----------------------------------------------------------
timeStart = tic();
% -----------------------------------------------------------


% Program header
% -----------------------------------------------------------
disp(' ------------------------------------------------------ ')
disp(' DENGUE Sprint Challenge 2024                           ')
disp(' Phase Space Plot                                       ')
disp('                                                        ')
disp(' by                                                     ')
disp(' Americo Cunha Jr                                       ')
disp(' ------------------------------------------------------ ')
% -----------------------------------------------------------


% Filter and smooth the data
% -----------------------------------------------------------
tic
disp(' ')
disp(' --- filtering and smoothing surveillance and climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% Custom colors
MyRed         = [0.6350 0.0780 0.1840];
MyGreen       = [0.0000 0.5000 0.0000];
MyBlue        = [0.0000 0.4470 0.7410];
MyOrange      = [0.8500 0.3250 0.0980];
MyPink        = [1.0000 0.5000 0.7500];
MyLightBlue   = [0.5000 0.7235 0.8705];
MyLightRed    = [0.8175 0.5390 0.5920];
MyLightOrange = [0.9250 0.6625 0.5490];


% Define the output filenames for the current state
FileNameCSV = 'DengueSprint2024_ProcessedData_';
FileNameEPS1 = 'DengueSprint2024_PhaseSpace_';

% List of the federative units (ufs) / Brazilian states
FederativeUnitsNames = {
    'AC',  % Acre
    'AL',  % Alagoas
    'AP',  % Amapa
    'AM',  % Amazonas
    'BA',  % Bahia
    'CE',  % Ceara
    'DF',  % Distrito Federal
    'ES',  % Espirito Santo
    'GO',  % Goias
    'MA',  % Maranhao
    'MT',  % Mato Grosso
    'MS',  % Mato Grosso do Sul
    'MG',  % Minas Gerais
    'PA',  % Para
    'PB',  % Paraiba
    'PR',  % Parana
    'PE',  % Pernambuco
    'PI',  % Piaui
    'RJ',  % Rio de Janeiro
    'RN',  % Rio Grande do Norte
    'RS',  % Rio Grande do Sul
    'RO',  % Rondonia
    'RR',  % Roraima
    'SC',  % Santa Catarina
    'SP',  % Sao Paulo
    'SE',  % Sergipe
    'TO'   % Tocantins
};

% Number of federative units (ufs) / Brazilian states
Nufs = length(FederativeUnitsNames);

% Loop over each federative unit to process and save data
for j = 1:Nufs
    
    % Extract the current state 'uf'
    current_uf = FederativeUnitsNames{j};
    
    % Display processing message
    disp(['Processing data for ',current_uf,' ...']);
    
    % Construct the filename
    InputFileName = ['DengueSprint2024_ProcessedData_',current_uf,'.csv'];
    
    % Read the CSV file into a table
    cd DataProcessed
    ProcessedData = readtable(InputFileName);
    cd ..
    
    % Extract relevant columns from the table
    epiweek = ProcessedData.epiweek;
    C       = ProcessedData.cases;
    T_min   = ProcessedData.temp_min;
    T_med   = ProcessedData.temp_med;
    T_max   = ProcessedData.temp_max;
    P_min   = ProcessedData.precip_min;
    P_med   = ProcessedData.precip_med;
    P_max   = ProcessedData.precip_max;
    P_tot   = ProcessedData.precip_tot;
% 
%     T = (T_med-T_min)./(T_max-T_min);
%     P = (P_med-P_min)./(P_max-P_min);    
    
    % Plot phase space
    % ..........................................................
    graphobj1.gname     = [FileNameEPS1, current_uf,'_PhaseSpace'];
    graphobj1.gtitle    = ['Dengue Dynamics for ', current_uf, ' (Brazil)'];
    graphobj1.xmin      = 'auto';
    graphobj1.xmax      = 'auto';
    graphobj1.ymin      =  0.0;
    graphobj1.ymax      = 'auto';
    graphobj1.zmin      =  0.0;
    graphobj1.zmax      = 'auto';
    graphobj1.xlab      = 'Temperature (ºC)';
    graphobj1.ylab      = 'Precipitation (mm/h)';
    graphobj1.zlab      = 'Probable Cases \times 10^3';
    graphobj1.linecolor = MyBlue;
    graphobj1.signature = 'Author: Americo Cunha Jr (UERJ)';
    graphobj1.years     = repelem(2010:2023,52)';
    graphobj1.print     = 'yes';
    graphobj1.close     = 'no';
    Fig1 = PlotPhaseSpaceAnimation(T_med,P_med,C/1000,graphobj1);
    % ..........................................................

    % Display saving message
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.png']]);

end

% Create a directory to store the saved files
mkdir DataProcessed

% Move files to the appropriate directory
movefile DengueSprint2024_* DataProcessed

toc
% -----------------------------------------------------------


% Program execution time
% -----------------------------------------------------------
disp(' ');
disp(' -----------------------------');
disp('            THE END!          ');
disp(' -----------------------------');
disp('  Total execution time:       ');
disp(['  ',num2str(toc(timeStart)),' seconds']);
disp(' -----------------------------');
% -----------------------------------------------------------
