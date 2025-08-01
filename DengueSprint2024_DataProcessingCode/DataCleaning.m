% -----------------------------------------------------------------
%  DataCleaning.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Sep 03, 2024
%           Last updated in: Sep 10, 2024
% -----------------------------------------------------------------
% This function preprocesses raw data by eliminating +-Inf, NaN,
% empty, and negative entries for specified positive quantities.
% Additional forbidden entries can be specified. Forbidden entries 
% are replaced with zeros.
% 
% Input:
% RawData          - table containing the raw data
% PositiveFields   - cell array of field names that must have 
%                    positive values (optional)
% ForbiddenValues - cell array of forbidden values or ranges 
%                    (e.g., {[-1, -2], [100, Inf]}) (optional)
% 
% Output:
% CleanData        - updated data table, forbidden entries 
%                    replaced with zeros
% ----------------------------------------------------------------- 
function CleanData = DataCleaning(RawData,PositiveFields,ForbiddenValues)

    % Check number of arguments
    if nargin < 1
        error('Too few inputs.')
    elseif nargin > 3
        error('Too many inputs.')
    end

    % Check if the input is a table
    if ~istable(RawData)
        error('Input data must be a table.');
    end

    % Initialize optional inputs if not provided
    if nargin < 2 || isempty(PositiveFields)
        PositiveFields = {}; % Set as empty if not provided
    elseif ~iscell(PositiveFields) || ~all(cellfun(@ischar, PositiveFields))
        error('Positive fields must be provided as a cell array of strings.');
    end

    if nargin < 3
        ForbiddenValues = {}; % Set as empty if not provided
    elseif ~iscell(ForbiddenValues)
        error('Forbidden values must be provided as a cell array.');
    end

    % Loop through all variables in the table
    for var = RawData.Properties.VariableNames
        
        % Convert the variable to a numeric array for processing
        column_data = RawData.(var{1});

        % Replace Inf, NaN, and empty values with zero
        if isnumeric(column_data)
            column_data(~isfinite(column_data)) = 0.0;
            column_data(    isnan(column_data)) = 0.0;
            column_data(  isempty(column_data)) = 0.0;
        end

        % Check if the field is specified to be positive
        if ismember(var{1}, PositiveFields)
            % Replace negative values with zero
            column_data(column_data < 0.0) = 0.0;
        end

        % Replace other forbidden entries specified by the user
        if ~isempty(ForbiddenValues)
            for i = 1:length(ForbiddenValues)
                forbidden_range = ForbiddenValues{i};
                if isnumeric(forbidden_range) && numel(forbidden_range) == 2
                    % Replace entries within the forbidden range with zero
                    column_data(column_data >= forbidden_range(1) & column_data <= forbidden_range(2)) = 0;
                else
                    error('Forbidden values must be numeric arrays of length 2.');
                end
            end
        end

        % Update the table with the cleaned data
        RawData.(var{1}) = column_data;
    end

    % Return the processed table
    CleanData = RawData;
end
% -----------------------------------------------------------------