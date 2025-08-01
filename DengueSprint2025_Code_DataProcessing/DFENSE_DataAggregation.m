% -----------------------------------------------------------------
%  DFENSE_DataAggregation.m
% -----------------------------------------------------------------
%  This program collects and aggregates datasets associated 
%  with Dengue surveillance and climate variables in Brazil 
%  over the period 2010-2025.
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               
%  Initially Programmed: Aug 13, 2024
%           Last Update: Jul 25, 2025
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
disp(' Surveillance and Climate Data Aggregation              ')
disp('                                                        ')
disp(' by                                                     ')
disp(' Americo Cunha Jr                                       ')
disp(' ------------------------------------------------------ ')
% -----------------------------------------------------------


% Load surveillance and climate data
% -----------------------------------------------------------
tic
disp(' '); 
disp(' --- loading surveillance and climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% ..........................................................
% Dataset downloaded from:
%    Coelho, F. C. et al.
%    Full dataset for dengue forecasting in Brazil
%    Zenodo (2024) https://doi.org/10.5281/zenodo.13328231
% ..........................................................



% name of the csv data files
FileName1 = 'dengue.csv';
FileName2 = 'climate.csv';
FileName3 = 'map_regional_health.csv';

% read the datasets organized as tables
cd DataRaw
DATASET1 = readtable(FileName1);
DATASET2 = readtable(FileName2);
DATASET3 = readtable(FileName3);
cd ..

toc
% -----------------------------------------------------------


% Clear surveillance and climate data
% -----------------------------------------------------------
tic
disp(' '); 
disp(' --- Cleaning surveillance and climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% Fields that must be positive
PositiveFields1 = {'epiweek','casos','geocode'};
PositiveFields2 = {'epiweek','geocode',...
                   'precip_min','precip_med','precip_max',...
                   'rel_humid_min','rel_humid_med','rel_humid_max',...
                   'thermal_range'};
PositiveFields3 = {'geocode'};

% Cleaning the raw data tables
DATASET1 = DataCleaning(DATASET1,PositiveFields1);
DATASET2 = DataCleaning(DATASET2,PositiveFields2);
DATASET3 = DataCleaning(DATASET3,PositiveFields3);

toc
% -----------------------------------------------------------


% Collect the data
% -----------------------------------------------------------
tic
disp(' ')
disp(' --- collecting surveillance and climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% Extract federative units (ufs) / Brazilian states
FederativeUnitsNames = unique(DATASET1.uf);

% Number of federative units (ufs) / Brazilian states
Nufs = length(FederativeUnitsNames);

% Define the valid range of 'epiweek' from 201001 to 202452
years          = 2010:2024;
weeks          = 1:52;
valid_epiweeks = [];
for y = years
    for w = weeks
        valid_epiweeks = [valid_epiweeks; y*100 + w];
    end
end

% Define the output filenames for the current state
FileNameCSV  = 'DengueSprint2025_AggregatedData_';
FileNameEPS1 = 'DengueSprint2025_ProbableCases_';
FileNameEPS2 = 'DengueSprint2025_Temperature_';
FileNameEPS3 = 'DengueSprint2025_Precipitation_';
FileNameEPS4 = 'DengueSprint2025_RelativyHumidity_';

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
    disp(['Processing data for ', current_uf, ' ...']);

    % Find all 'geocodes' that correspond to the current 'uf'
    geocodes_for_uf = DATASET3.geocode(strcmp(DATASET3.uf, current_uf));

    % Extract the rows where 'uf' is equal to the 'current_uf'
    RawData1 = DATASET1(strcmp(DATASET1.uf, current_uf), :);
    RawData2 = DATASET2(ismember(DATASET2.geocode, geocodes_for_uf), :);

    % Filter raw data to keep only valid epidemic weeks
    RawData1 = RawData1(ismember(RawData1.epiweek, valid_epiweeks), :);
    RawData2 = RawData2(ismember(RawData2.epiweek, valid_epiweeks), :);
    
    % Extract data for current state
    SelectedData1 = [RawData1.epiweek'; ...
                     RawData1.casos'    ...
                     ]';
    
    SelectedData2 = [RawData2.epiweek'      ; ...
                     RawData2.temp_min'     ; ...
                     RawData2.temp_med'     ; ...
                     RawData2.temp_max'     ; ...
                     RawData2.precip_min'   ; ...
                     RawData2.precip_med'   ; ...
                     RawData2.precip_max'   ; ...
                     RawData2.pressure_min' ; ...
                     RawData2.pressure_med' ; ...
                     RawData2.pressure_max' ; ...
                     RawData2.rel_humid_min'; ...
                     RawData2.rel_humid_med'; ...
                     RawData2.rel_humid_max';...
                     RawData2.thermal_range';...
                     RawData2.rainy_days'    ...
                     ]';
    
    % Extract unique epiweeks
    unique_epiweeks1 = unique(SelectedData1(:,1));
    unique_epiweeks2 = unique(SelectedData2(:,1));
    
    % Number of unique epiweeks
    Nepiweeks = length(unique_epiweeks1);

    % Number of features
    Nfeatures = size(SelectedData1,2) + size(SelectedData2,2) - 1;
    
    % Initialize an array to store the aggregated data
    AggregatedData = zeros(Nepiweeks,Nfeatures);
    
    % Aggregate the data
    for i = 1:Nepiweeks
        % Find the indices of the current epiweek in the first column
        current_indices1 = SelectedData1(:,1) == unique_epiweeks1(i);
        current_indices2 = SelectedData2(:,1) == unique_epiweeks2(i);
        % Agragate the corresponding data
        AggregatedData(i, 1) = unique_epiweeks1(i);
        AggregatedData(i, 2) =  sum(SelectedData1(current_indices1, 2));
        AggregatedData(i, 3) = mean(SelectedData2(current_indices2, 2));
        AggregatedData(i, 4) = mean(SelectedData2(current_indices2, 3));
        AggregatedData(i, 5) = mean(SelectedData2(current_indices2, 4));
        AggregatedData(i, 6) = mean(SelectedData2(current_indices2, 5));
        AggregatedData(i, 7) = mean(SelectedData2(current_indices2, 6));
        AggregatedData(i, 8) = mean(SelectedData2(current_indices2, 7));
        AggregatedData(i, 9) = mean(SelectedData2(current_indices2, 8));
        AggregatedData(i,10) = mean(SelectedData2(current_indices2, 9));
        AggregatedData(i,11) = mean(SelectedData2(current_indices2,10));
        AggregatedData(i,12) = mean(SelectedData2(current_indices2,11));
        AggregatedData(i,13) = mean(SelectedData2(current_indices2,12));
        AggregatedData(i,14) = mean(SelectedData2(current_indices2,13));
        AggregatedData(i,15) = mean(SelectedData2(current_indices2,14));
        AggregatedData(i,16) =  max(SelectedData2(current_indices2,15));
    end

    % Convert 'epiweek' to datetime format
    years     = floor(AggregatedData(:, 1) / 100);
    weeks     =   mod(AggregatedData(:, 1), 100);
    epi_dates = datetime(years, 1, 1) + calweeks(weeks - 1);
    
    % Plot cases data
    % ..........................................................
    graphobj1.gname     = [FileNameEPS1,current_uf,'_Raw'];
    graphobj1.gtitle    = ['Dengue Reports in ',current_uf,' (Brazil)'];
    graphobj1.ymin      = 0.0;
    graphobj1.ymax      = 'auto';
    graphobj1.xlab      = [];
    graphobj1.ylab      = 'Probable Cases \times 10^3';
    graphobj1.linecolor = MyRed;
    graphobj1.signature = 'Author: Americo Cunha Jr (LNCC/UERJ)';
    graphobj1.print     = 'yes';
    graphobj1.close     = 'no';
    Fig1 = PlotCurve1(epi_dates,AggregatedData(:,2)/1000,graphobj1);
    % ..........................................................

    % Plot temperature data
    % ..........................................................
    graphobj2.gname      = [FileNameEPS2,current_uf,'_Raw'];
    graphobj2.gtitle     = ['Temperature in ',current_uf,' (Brazil)'];
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
    Fig2 = PlotEnvelope1(epi_dates,AggregatedData(:,3),...
                                   AggregatedData(:,4),...
                                   AggregatedData(:,5),graphobj2);
    % ..........................................................

    % Plot precipitation data
    % ..........................................................
    graphobj3.gname        = [FileNameEPS3,current_uf,'_Raw'];
    graphobj3.gtitle       = ['Precipitation in ',current_uf,' (Brazil)'];
    graphobj3.ymin         = 0.0;
    graphobj3.ymax         = 160.0;
    graphobj3.xlab         = [];
    graphobj3.ylab         = 'Precipitation (mm/h)';
    graphobj3.labelcurve   = 'Mean';
    graphobj3.labelshade   = 'Min-Max';
    graphobj3.linecolor    = MyBlue;
    graphobj3.shadecolor   = MyLightBlue;
    graphobj3.signature    = 'Author: Americo Cunha Jr (LNCC/UERJ)';
    graphobj3.print        = 'yes';
    graphobj3.close        = 'no';
    Fig3 = PlotEnvelope1(epi_dates,AggregatedData(:,6),...
                                   AggregatedData(:,7),...
                                   AggregatedData(:,8),graphobj3);
    % ..........................................................

    % Plot relativy humidity
    % ..........................................................
    graphobj4.gname      = [FileNameEPS4,current_uf,'_Raw'];
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
    Fig4 = PlotEnvelope1(epi_dates,AggregatedData(:,12),...
                                   AggregatedData(:,13),...
                                   AggregatedData(:,14),graphobj4);
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
    
    % Save the aggregated data to a CSV file
    OutputDataTable = array2table(AggregatedData);
    OutputDataTable.Properties.VariableNames(:) = DataFields;
    writetable(OutputDataTable,[FileNameCSV,current_uf,'.csv'])
    
    % Display saving message
    disp(['Data saved to ',[FileNameCSV,current_uf,'.csv']]);
    disp(' ');

end

% create a directory to store the saved files
mkdir DataAggregated
mkdir Figures

% move files for a proper directory
movefile *.csv DataAggregated
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
