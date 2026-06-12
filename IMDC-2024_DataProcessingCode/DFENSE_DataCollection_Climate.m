% -----------------------------------------------------------------
%  DFENSE_DataCollection_Climate.m
% -----------------------------------------------------------------
%  This program collects datasets associated with climate
%  variables in Brazil over the period 2010-2024.
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               
%  Initially Programmed: Aug 13, 2024
%           Last Update: Aug 14, 2024
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
disp(' Climate Data Collection                                ')
disp('                                                        ')
disp(' by                                                     ')
disp(' A. Cunha Jr                                            ')
disp(' ------------------------------------------------------ ')
% -----------------------------------------------------------


% Load climate data
% -----------------------------------------------------------
tic
disp(' '); 
disp(' --- loading climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% name of the csv data files
FileName1 = 'climate.csv';
FileName2 = 'regic2018.csv';

% dataset for climate variables
DATASET1 = readtable(FileName1);

% dataset for geographic variables
DATASET2 = readtable(FileName2);

toc
% -----------------------------------------------------------


% Collect climate data
% -----------------------------------------------------------
tic
disp(' ')
disp(' --- collecting climate data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% Custom colors
MyBlue   = [0      0.4470 0.7410];
MyRed    = [0.6350 0.0780 0.1840];
MyOrange = [0.8500 0.3250 0.0980];

% Extract unique UFs
unique_ufs = unique(DATASET2.UF);

% plot period from Jan 2010 until Dec 2023
iperiod = 2:732;

% Loop over each UF to process and save data
for j = 1:length(unique_ufs)
    
    % Extract the current UF
    current_state = unique_ufs{j};
    
    % Display processing message
    disp(['Processing data for ', current_state, '...']);
    
    % Find all geocodes that correspond to the current UF
    geocodes_for_uf = DATASET2.geocode(strcmp(DATASET2.UF, current_state));
    
    % Filter the climate data for the current UF by matching geocodes
    RawData = DATASET1(ismember(DATASET1.geocode, geocodes_for_uf), :);

    % Extract data for current state
    RawData = [RawData.epiweek'; ...
               RawData.temp_min'; ...
               RawData.temp_med'; ...
               RawData.temp_max'; ...
               RawData.precip_min'; ...
               RawData.precip_med'; ...
               RawData.precip_max'; ...
               RawData.precip_tot']';
    
    % Extract unique epiweeks
    unique_epiweeks = unique(RawData(:, 1));

    % Initialize an array to store the aggregated data
    Data = zeros(length(unique_epiweeks), 8);
    
    % Aggregate the data
    for i = 1:length(unique_epiweeks)
        % Find the indices of the current epiweek in the first column
        current_indices = RawData(:, 1) == unique_epiweeks(i);
        % Aggregate the corresponding cases
        Data(i, 1) = unique_epiweeks(i);
        Data(i, 2) = mean(RawData(current_indices, 2));
        Data(i, 3) = mean(RawData(current_indices, 3));
        Data(i, 4) = mean(RawData(current_indices, 4));
        Data(i, 5) = mean(RawData(current_indices, 5));
        Data(i, 6) = mean(RawData(current_indices, 6));
        Data(i, 7) = mean(RawData(current_indices, 7));
        Data(i, 8) =  sum(RawData(current_indices, 8));
    end
    
    % Define the output filename for the current UF
    OutputFileName = ['Climate_', current_state, '.csv'];
    
    % Save the aggregated data to a CSV file
    writematrix(Data, OutputFileName);
    
    % Display saving message
    disp(['Data saved to ', OutputFileName]);
    
    % Convert "epiweek" to datetime format
    years     = floor(Data(:, 1) / 100);
    weeks     =   mod(Data(:, 1), 100);
    epi_dates = datetime(years, 1, 1) + calweeks(weeks - 1);
    %epi_dates = datetime(years, 1, 1) + days(7*(weeks-1));

    % Plot the data (temperature)
    figure;
    plot(epi_dates(iperiod), Data(iperiod, 3), 'LineWidth', 2, 'Color', MyOrange);
    grid on;
    ylim([0 40]);
    ylabel('Temperature (ºC)', 'FontSize', 20, 'FontName', 'Helvetica');
    title(['Temperature Reports in ', current_state, ' (Brazil)'],...
           'FontSize', 24, 'FontName', 'Helvetica');
    
    % Formatting the x-axis to show dates in "month-year" format
    datetick('x', 'mmm yyyy', 'keepticks');

    % Rotate the x-axis labels for better readability
    xtickangle(45);

    % Set font and box
    set(gca, 'FontName', 'Helvetica');
    set(gca, 'FontSize', 18);
    box on;
    
    % Save the plot as an EPS file
    eps_filename = ['Temperature_', current_state, '.eps'];
    print('-depsc2', eps_filename);

    % Close the figure to avoid memory issues
    close;

    % Plot the data (precipitation)
    figure;
    plot(epi_dates(iperiod), Data(iperiod, 6), 'LineWidth', 2, 'Color', MyBlue);
    grid on;
    ylim([0 2]);
    ylabel('Precipitation (mm/h)', 'FontSize', 20, 'FontName', 'Helvetica');
    title(['Precipitation Reports in ', current_state, ' (Brazil)'],...
           'FontSize', 24, 'FontName', 'Helvetica');
    
    % Formatting the x-axis to show dates in "month-year" format
    datetick('x', 'mmm yyyy', 'keepticks');

    % Rotate the x-axis labels for better readability
    xtickangle(45);

    % Set font and box
    set(gca, 'FontName', 'Helvetica');
    set(gca, 'FontSize', 18);
    box on;
    
    % Save the plot as an EPS file
    eps_filename = ['Precipitation_', current_state, '.eps'];
    print('-depsc2', eps_filename);

    % Close the figure to avoid memory issues
    close;

    % Display saving message
    disp(['Plot saved to ', eps_filename]);
    disp(' ');

end

% create a directory to store the saved files
mkdir DataCollection

% move files for a proper directory
movefile Climate_* DataCollection
movefile Temperature_* DataCollection
movefile Precipitation_* DataCollection

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
