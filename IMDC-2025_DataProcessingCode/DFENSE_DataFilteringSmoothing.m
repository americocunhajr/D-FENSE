% -----------------------------------------------------------------
%  DFENSE_DataFilteringSmoothing.m
% -----------------------------------------------------------------
%  This program filters the processed datasets associated 
%  with Dengue surveillance and climate variables in Brazil 
%  over the period 2010-2025.
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               
%  Initially Programmed: Aug 13, `
%           Last Update: Jul 28, 2025
% -----------------------------------------------------------------


clc; clear; close all

% program execution start time
% -----------------------------------------------------------
timeStart = tic();
% -----------------------------------------------------------


% Program header
% -----------------------------------------------------------
disp(' ------------------------------------------------------ ')
disp(' DENGUE Sprint Challenge 2025                           ')
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
FileNameCSV  = 'DengueSprint2025_ProcessedData_';
FileNameEPS1 = 'DengueSprint2025_ProbableCases_';
FileNameEPS2 = 'DengueSprint2025_Temperature_';
FileNameEPS3 = 'DengueSprint2025_Precipitation_';
FileNameEPS4 = 'DengueSprint2025_RelativyHumidity_';

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
MyLightRed    = [0.8175 0.5390 0.5920];
MyGreen       = [0.0000 0.5000 0.0000];
MyLightGreen  = [0.5000 0.7500 0.5000];
MyBlue        = [0.0000 0.4470 0.7410];
MyLightBlue   = [0.5000 0.7235 0.8705];
MyOrange      = [0.8500 0.3250 0.0980];
MyLightOrange = [0.9250 0.6625 0.5490];
MyPink        = [1.0000 0.5000 0.7500];
MyLightPink   = [1.0000 0.7500 0.8500];

% Loop over each federative unit to process and save data
for j = 1:Nufs
    
    % Extract the current state 'uf'
    current_uf = FederativeUnitsNames{j};
    
    % Display processing message
    disp(['Processing data for ',current_uf,' ...']);
    
    % Construct the filename
    InputFileName = ['DengueSprint2025_AggregatedData_',current_uf,'.csv'];
    
    % Read the CSV file into a table
    cd DataAggregated
    RawData = readtable(InputFileName);
    cd ..
    
    % Extract relevant columns from the table
    ProcessedData = [RawData.epiweek'      ; ...
                     RawData.cases'        ; ...
                     RawData.temp_min'     ; ...
                     RawData.temp_med'     ; ...
                     RawData.temp_max'     ; ...
                     RawData.precip_min'   ; ...
                     RawData.precip_med'   ; ...
                     RawData.precip_max'   ; ...
                     RawData.pressure_min' ; ...
                     RawData.pressure_med' ; ...
                     RawData.pressure_max' ; ...
                     RawData.rel_humid_min'; ...
                     RawData.rel_humid_med'; ...
                     RawData.rel_humid_max'; ...
                     RawData.thermal_range'; ...
                     RawData.rainy_days'     ...
                    ]';


    % Number of unique epiweeks
    Nepiweeks = length(ProcessedData(:,1));

    % Number of features
    Nfeatures = size(ProcessedData,2) - 1;
    
    % Denoise each time series
    ProcessedData(:, 2) = sgolayfilt(DenoiseSVD(ProcessedData(:, 2),Window),Order,FrameLen);
    ProcessedData(:, 3) = sgolayfilt(DenoiseSVD(ProcessedData(:, 3),Window),Order,FrameLen);
    ProcessedData(:, 4) = sgolayfilt(DenoiseSVD(ProcessedData(:, 4),Window),Order,FrameLen);
    ProcessedData(:, 5) = sgolayfilt(DenoiseSVD(ProcessedData(:, 5),Window),Order,FrameLen);
    ProcessedData(:, 6) = sgolayfilt(DenoiseSVD(ProcessedData(:, 6),Window),Order,FrameLen);
    ProcessedData(:, 7) = sgolayfilt(DenoiseSVD(ProcessedData(:, 7),Window),Order,FrameLen);
    ProcessedData(:, 8) = sgolayfilt(DenoiseSVD(ProcessedData(:, 8),Window),Order,FrameLen);
    ProcessedData(:, 9) = sgolayfilt(DenoiseSVD(ProcessedData(:, 9),Window),Order,FrameLen);
    ProcessedData(:,10) = sgolayfilt(DenoiseSVD(ProcessedData(:,10),Window),Order,FrameLen);
    ProcessedData(:,11) = sgolayfilt(DenoiseSVD(ProcessedData(:,11),Window),Order,FrameLen);
    ProcessedData(:,12) = sgolayfilt(DenoiseSVD(ProcessedData(:,12),Window),Order,FrameLen);
    ProcessedData(:,13) = sgolayfilt(DenoiseSVD(ProcessedData(:,13),Window),Order,FrameLen);
    ProcessedData(:,14) = sgolayfilt(DenoiseSVD(ProcessedData(:,14),Window),Order,FrameLen);
    ProcessedData(:,15) = sgolayfilt(DenoiseSVD(ProcessedData(:,15),Window),Order,FrameLen);
    
    % Define time vectors for spline interpolation
    time1 = 1:Nepiweeks;
    time2 = 1:0.5:Nepiweeks;
    
    % Smooth the data using cubic spline fitting
    SmoothedData       = zeros(length(time2),Nfeatures);
    SmoothedData(:, 1) = spline(time1,ProcessedData(:, 2),time2)';
    SmoothedData(:, 2) = spline(time1,ProcessedData(:, 3),time2)';
    SmoothedData(:, 3) = spline(time1,ProcessedData(:, 4),time2)';
    SmoothedData(:, 4) = spline(time1,ProcessedData(:, 5),time2)';
    SmoothedData(:, 5) = spline(time1,ProcessedData(:, 6),time2)';
    SmoothedData(:, 6) = spline(time1,ProcessedData(:, 7),time2)';
    SmoothedData(:, 7) = spline(time1,ProcessedData(:, 8),time2)';
    SmoothedData(:, 8) = spline(time1,ProcessedData(:, 9),time2)';
    SmoothedData(:, 9) = spline(time1,ProcessedData(:,10),time2)';
    SmoothedData(:,10) = spline(time1,ProcessedData(:,11),time2)';
    SmoothedData(:,11) = spline(time1,ProcessedData(:,12),time2)';
    SmoothedData(:,12) = spline(time1,ProcessedData(:,13),time2)';
    SmoothedData(:,13) = spline(time1,ProcessedData(:,14),time2)';
    SmoothedData(:,14) = spline(time1,ProcessedData(:,15),time2)';
    SmoothedData(:,15) = spline(time1,ProcessedData(:,16),time2)';
    
    ProcessedData(:, 2) = SmoothedData(1:2:end, 1);
    ProcessedData(:, 3) = SmoothedData(1:2:end, 2);
    ProcessedData(:, 4) = SmoothedData(1:2:end, 3);
    ProcessedData(:, 5) = SmoothedData(1:2:end, 4);
    ProcessedData(:, 6) = SmoothedData(1:2:end, 5);
    ProcessedData(:, 7) = SmoothedData(1:2:end, 6);
    ProcessedData(:, 8) = SmoothedData(1:2:end, 7);
    ProcessedData(:, 9) = SmoothedData(1:2:end, 8);
    ProcessedData(:,10) = SmoothedData(1:2:end, 9);
    ProcessedData(:,11) = SmoothedData(1:2:end,10);
    ProcessedData(:,12) = SmoothedData(1:2:end,11);
    ProcessedData(:,13) = SmoothedData(1:2:end,12);
    ProcessedData(:,14) = SmoothedData(1:2:end,13);
    ProcessedData(:,15) = SmoothedData(1:2:end,14);
    ProcessedData(:,16) = SmoothedData(1:2:end,15);

    % Round reported cases to an integer value
    ProcessedData(:, 2) = round(ProcessedData(:, 2));
    ProcessedData(:,16) = round(ProcessedData(:,16));

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
    graphobj1.ymin      = 0.0;
    graphobj1.ymax      = 'auto';
    graphobj1.xlab      = [];
    graphobj1.ylab      = 'Probable Cases \times 10^3';
    graphobj1.linecolor = MyRed;
    graphobj1.signature = 'Author: Americo Cunha Jr (LNCC/UERJ)';
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
    graphobj2.signature  = 'Author: Americo Cunha Jr (LNCC/UERJ)';
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
    graphobj3.ymin         = 0.0;
    graphobj3.ymax         = 160.0;
    graphobj3.xlab         = [];
    graphobj3.ylab         = 'Precipitation (mm/h)';
    graphobj3.labelcurve   = 'Mean';
    graphobj3.labelcurve   = 'Total';
    graphobj3.labelshade   = 'Min-Max';
    graphobj3.linecolor    = MyBlue;
    graphobj3.shadecolor   = MyLightBlue;
    graphobj3.signature    = 'Author: Americo Cunha Jr (LNCC/UERJ)';
    graphobj3.print        = 'yes';
    graphobj3.close        = 'no';
    Fig3 = PlotEnvelope1(epi_dates,ProcessedData(:,6),...
                                   ProcessedData(:,7),...
                                   ProcessedData(:,8),graphobj3);
    % ..........................................................

    % Plot relativy humidity
    % ..........................................................
    graphobj4.gname      = [FileNameEPS4,current_uf,'_Filtered'];
    graphobj4.gtitle     = ['Relativity Humidity in ',current_uf,' (Brazil)'];
    graphobj4.ymin       =   0.0;
    graphobj4.ymax       = 100.0;
    graphobj4.xlab       = [];
    graphobj4.ylab       = 'Relativity Humidity (%)';
    graphobj4.labelcurve = 'Mean';
    graphobj4.labelshade = 'Min-Max';
    graphobj4.linecolor  = MyPink;
    graphobj4.shadecolor = MyLightPink;
    graphobj4.signature  = 'Author: Americo Cunha Jr (LNCC/UERJ)';
    graphobj4.print      = 'yes';
    graphobj4.close      = 'no';
    Fig4 = PlotEnvelope1(epi_dates,ProcessedData(:,12),...
                                   ProcessedData(:,13),...
                                   ProcessedData(:,14),graphobj4);
    % ..........................................................

    % Display saving message
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS1,current_uf,'.png']]);
    disp(['Plot saved to ',[FileNameEPS2,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS2,current_uf,'.png']]);
    disp(['Plot saved to ',[FileNameEPS3,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS3,current_uf,'.png']]);
    disp(['Plot saved to ',[FileNameEPS4,current_uf,'.eps']]);
    disp(['Plot saved to ',[FileNameEPS4,current_uf,'.png']]);

    % Data field for output table
    DataFields = {'epiweek'      ,...
                  'cases'        ,...
                  'temp_min'     ,...
                  'temp_med'     ,...
                  'temp_max'     ,...
                  'precip_min'   ,...
                  'precip_med'   ,...
                  'precip_max'   ,...
                  'pressure_min' ,...
                  'pressure_med' ,...
                  'pressure_max' ,...
                  'rel_humid_min',...
                  'rel_humid_med',...
                  'rel_humid_max',...
                  'thermal_range',...
                  'rainy_days'    ...
                  };

    % Save the processed data to a CSV file
    OutputDataTable = array2table(ProcessedData);
    OutputDataTable.Properties.VariableNames(:) = DataFields;
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
