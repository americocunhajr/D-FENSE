% -----------------------------------------------------------------
%  DFENSE_DataCollection_Surveillance.m
% -----------------------------------------------------------------
%  This program collects datasets associated with Dengue
%  surveillance in Brazil over the period 2010-2024.
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
disp(' Surveillance Data Collection                           ')
disp('                                                        ')
disp(' by                                                     ')
disp(' A. Cunha Jr                                            ')
disp(' ------------------------------------------------------ ')
% -----------------------------------------------------------


% Load surveillance data
% -----------------------------------------------------------
tic
disp(' '); 
disp(' --- loading surveillance data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% name of the csv data files
FileName1 = 'dengue.csv';

% dataset for Dengue cases notifications
DATASET1 = readtable(FileName1);

toc
% -----------------------------------------------------------


% Collect surveillance data
% -----------------------------------------------------------
tic
disp(' ')
disp(' --- collecting surveillance data --- ');
disp(' ');
disp('    ... ');
disp(' ');

% Custom colors
MyBlue = [0      0.4470 0.7410];
MyRed  = [0.6350 0.0780 0.1840];

% Extract unique states (uf)
unique_states = unique(DATASET1.uf);

% plot period from Jan 2010 until Dec 2023
iperiod = 1:731;

% Loop over each state to process and save data
for j = 1:length(unique_states)
    
    % Extract the current state (uf)
    current_state = unique_states{j};
    
    % Display processing message
    disp(['Processing data for ', current_state, '...']);
    
    % Extract the rows where 'uf' is equal to the current state
    RawData = DATASET1(strcmp(DATASET1.uf, current_state), :);
    
    % Extract data for current state
    RawData = [RawData.epiweek'; RawData.casos']';
    
    % Extract unique epiweeks
    unique_epiweeks = unique(RawData(:, 1));
    
    % Initialize an array to store the aggregated data
    Data = zeros(length(unique_epiweeks), 2);
    
    % Aggregate the data
    for i = 1:length(unique_epiweeks)
        % Find the indices of the current epiweek in the first column
        current_indices = RawData(:, 1) == unique_epiweeks(i);
        % Sum the corresponding cases
        Data(i, 1) = unique_epiweeks(i);
        Data(i, 2) = sum(RawData(current_indices, 2));
    end
    
    % Define the output filename for the current state
    OutputFileName = ['DengueCases_', current_state, '.csv'];
    
    % Save the aggregated data to a CSV file
    writematrix(Data, OutputFileName);
    
    % Display saving message
    disp(['Data saved to ', OutputFileName]);

    % Convert "epiweek" to datetime format
    years     = floor(Data(:, 1) / 100);
    weeks     =   mod(Data(:, 1), 100);
    epi_dates = datetime(years, 1, 1) + calweeks(weeks - 1);
    %epi_dates = datetime(years, 1, 1) + days(7*(weeks-1));

    % Plot the data
    figure;
    plot(epi_dates(iperiod), Data(iperiod, 2), 'LineWidth', 2, 'Color', MyRed);
    xlim([min(epi_dates) max(epi_dates)] + calmonths([0 6]));
    grid on;
    ylabel('Probable Cases', 'FontSize', 20, 'FontName', 'Helvetica');
    title(['Dengue Reports in ', current_state, ' (Brazil)'],...
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
    eps_filename = ['DengueCases_', current_state, '.eps'];
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
movefile DengueCases_* DataCollection

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
