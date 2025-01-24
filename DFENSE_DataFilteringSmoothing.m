% -----------------------------------------------------------------
%  DFENSE_DataFilteringSmoothing.m
% -----------------------------------------------------------------
%  This program filters the processed datasets associated 
%  with Dengue surveillance and climate variables in Brazil 
%  over the period 2010-2024.
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               
%  Initially Programmed: Aug 13, 2024
%           Last Update: Aug 30, 2024
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
disp(' Surveillance and Climate Data Filtering and Smoothing  ')
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

% Define the output filenames for the current state
FileNameCSV = 'DengueSprint2024_ProcessedData_';
FileNameEPS1 = 'DengueSprint2024_ReportedCases_';
FileNameEPS2 = 'DengueSprint2024_Temperature_';
FileNameEPS3 = 'DengueSprint2024_Precipitation_';

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

% Define parameters for denoising
Window   = 52;
Order    = 3;
FrameLen = 11;

% Custom colors
MyRed         = [0.6350 0.0780 0.1840];
MyGreen       = [0.0000 0.5000 0.0000];
MyBlue        = [0.0000 0.4470 0.7410];
MyOrange      = [0.8500 0.3250 0.0980];
MyPink        = [1.0000 0.5000 0.7500];
MyLightBlue   = [0.5000 0.7235 0.8705];
MyLightRed    = [0.8175 0.5390 0.5920];
MyLightOrange = [0.9250 0.6625 0.5490];

% Loop over each federative unit to process and save data
for j = 1:Nufs
    
    % Extract the current state 'uf'
    current_uf = FederativeUnitsNames{j};
    
    % Display processing message
    disp(['Processing data for ',current_uf,' ...']);
    
    % Construct the filename
    InputFileName = ['DengueSprint2024_AggregatedData_',current_uf,'.csv'];
    
    % Read the CSV file into a table
    cd DataAggregated
    RawData = readtable(InputFileName);
    cd ..
    
    % Extract relevant columns from the table
    ProcessedData = [RawData.epiweek'   ; ...
                     RawData.cases'     ; ...
                     RawData.temp_min'  ; ...
                     RawData.temp_med'  ; ...
                     RawData.temp_max'  ; ...
                     RawData.precip_min'; ...
                     RawData.precip_med'; ...
                     RawData.precip_max'; ...
                     RawData.precip_tot']';

    % Number of unique epiweeks
    Nepiweeks = length(ProcessedData(:,1));
    
    % Denoise each time series
    ProcessedData(:,2) = sgolayfilt(DenoiseSVD(ProcessedData(:,2),Window),Order,FrameLen);
    ProcessedData(:,3) = sgolayfilt(DenoiseSVD(ProcessedData(:,3),Window),Order,FrameLen);
    ProcessedData(:,4) = sgolayfilt(DenoiseSVD(ProcessedData(:,4),Window),Order,FrameLen);
    ProcessedData(:,5) = sgolayfilt(DenoiseSVD(ProcessedData(:,5),Window),Order,FrameLen);
    ProcessedData(:,6) = sgolayfilt(DenoiseSVD(ProcessedData(:,6),Window),Order,FrameLen);
    ProcessedData(:,7) = sgolayfilt(DenoiseSVD(ProcessedData(:,7),Window),Order,FrameLen);
    ProcessedData(:,8) = sgolayfilt(DenoiseSVD(ProcessedData(:,8),Window),Order,FrameLen);
    ProcessedData(:,9) = sgolayfilt(DenoiseSVD(ProcessedData(:,9),Window),Order,FrameLen);
    
    % Define time vectors for spline interpolation
    time1 = 1:Nepiweeks;
    time2 = 1:0.5:Nepiweeks;
    
    % Smooth the data using cubic spline fitting
    C_s     = spline(time1,ProcessedData(:,2),time2)';
    T_min_s = spline(time1,ProcessedData(:,3),time2)';
    T_med_s = spline(time1,ProcessedData(:,4),time2)';
    T_max_s = spline(time1,ProcessedData(:,5),time2)';
    P_min_s = spline(time1,ProcessedData(:,6),time2)';
    P_med_s = spline(time1,ProcessedData(:,7),time2)';
    P_max_s = spline(time1,ProcessedData(:,8),time2)';
    P_tot_s = spline(time1,ProcessedData(:,9),time2)';
    
    ProcessedData(:,2) =     C_s(1:2:end);
    ProcessedData(:,3) = T_min_s(1:2:end);
    ProcessedData(:,4) = T_med_s(1:2:end);
    ProcessedData(:,5) = T_max_s(1:2:end);
    ProcessedData(:,6) = P_min_s(1:2:end);
    ProcessedData(:,7) = P_med_s(1:2:end);
    ProcessedData(:,8) = P_max_s(1:2:end);
    ProcessedData(:,9) = P_tot_s(1:2:end);

    % Round reported cases to an integer value
    ProcessedData(:,2) = round(ProcessedData(:,2));

    % Remove potentially negative values
    ProcessedData(ProcessedData < 0.0) = 0.0;
    
    % Convert 'epiweek' to datetime format for plotting
    years     = floor(ProcessedData(:,1)/100);
    weeks     =   mod(ProcessedData(:,1),100);
    epi_dates = datetime(years, 1, 1) + calweeks(weeks - 1);
    
    % Plot cases data
    % ..........................................................
    graphobj1.gname     = [FileNameEPS1, current_uf,'_Filtered'];
    graphobj1.gtitle    = ['Dengue Reports in ', current_uf, ' (Brazil)'];
    graphobj1.ymin      = 'auto';
    graphobj1.ymax      = 'auto';
    graphobj1.xlab      = [];
    graphobj1.ylab      = 'Probable Cases \times 10^3';
    graphobj1.linecolor = MyRed;
    graphobj1.signature = 'Author: Americo Cunha Jr (UERJ)';
    graphobj1.print     = 'yes';
    graphobj1.close     = 'no';
    Fig1 = PlotCurve1(epi_dates,ProcessedData(:,2)/1000,graphobj1);
    % ..........................................................

    % Plot temperature data
    % ..........................................................
    graphobj2.gname      = [FileNameEPS2, current_uf,'_Filtered'];
    graphobj2.gtitle     = ['Temperature in ', current_uf, ' (Brazil)'];
    graphobj2.ymin       = 5.0;
    graphobj2.ymax       = 40.0;
    graphobj2.xlab       = [];
    graphobj2.ylab       = 'Temperature (ºC)';
    graphobj2.labelcurve = 'Mean';
    graphobj2.labelshade = 'Min-Max';
    graphobj2.linecolor  = MyOrange;
    graphobj2.shadecolor = MyLightOrange;
    graphobj2.signature  = 'Author: Americo Cunha Jr (UERJ)';
    graphobj2.print      = 'yes';
    graphobj2.close      = 'no';
    Fig2 = PlotEnvelope1(epi_dates,ProcessedData(:,3),...
                                   ProcessedData(:,4),...
                                   ProcessedData(:,5),graphobj2);
    % ..........................................................

    % Plot precipitation data
    % ..........................................................
    graphobj3.gname        = [FileNameEPS3, current_uf,'_Filtered'];
    graphobj3.gtitle       = ['Precipitation in ', current_uf, ' (Brazil)'];
    graphobj3.ymin_l       = 0.0;
    graphobj3.ymax_l       = 3.0;
    graphobj3.ymin_r       = 0.0;
    graphobj3.ymax_r       = 'auto';
    graphobj3.xlab         = [];
    graphobj3.ylab_l       = 'Precipitation (mm/h)';
    graphobj3.ylab_r       = 'Total Precipitation (mm)';
    graphobj3.labelcurve_l = 'Mean';
    graphobj3.labelcurve_r = 'Total';
    graphobj3.labelshade   = 'Min-Max';
    graphobj3.linecolor_l  = MyBlue;
    graphobj3.linecolor_r  = MyGreen;
    graphobj3.shadecolor   = MyLightBlue;
    graphobj3.signature    = 'Author: Americo Cunha Jr (UERJ)';
    graphobj3.print        = 'yes';
    graphobj3.close        = 'no';
    Fig3 = PlotEnvelope2(epi_dates,ProcessedData(:,6),...
                                   ProcessedData(:,7),...
                                   ProcessedData(:,8),...
                                   ProcessedData(:,9),graphobj3);
    % ..........................................................

    % Display saving message
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.png']]);
    disp(['Plot saved to ',[FileNameEPS2,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS2,current_uf,'.png']]);
    disp(['Plot saved to ',[FileNameEPS3,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS3,current_uf,'.png']]);

    % Data field for output table
    DataFields = {'epiweek','cases','temp_min','temp_med','temp_max',...
                  'precip_min','precip_med','precip_max','precip_tot'};

    % Save the processed data to a CSV file
    OutputDataTable = array2table(ProcessedData,'VariableNames',DataFields);
    writetable(OutputDataTable,[FileNameCSV,current_uf,'.csv']);
    
    % Display saving message
    disp(['Data saved to ', [FileNameCSV, current_uf, '.csv']]);
    disp(' ');

end

% Create a directory to store the saved files
mkdir DataProcessed
mkdir Figures

% Move files to the appropriate directory
movefile *.csv DataProcessed
movefile *.eps Figures
movefile *.png Figures

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
