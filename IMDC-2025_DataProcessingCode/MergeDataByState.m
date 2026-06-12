function MergeDataByState(inputDir, outputDir)
% MergeDataByState  Merge, per state (UF), raw epidemiological CSV files by epiweek (YYYYWW).
% Usage:
%   MergeDataByState('data_in', 'data_out')
%
% Expected filenames (examples):
%   DengueSprint2025_AggregatedData_AC.csv
%   DengueSprint2025_AggregatedData_AC_updated_2025.csv
%
% Behavior:
%   - Scans all *.csv in inputDir.
%   - Groups files by the 2-letter UF inferred from the filename.
%   - Reads each CSV, ensures epiweek is TEXT (YYYYWW), cleans trailing ".0".
%   - OUTER-JOINs rows by epiweek. When a week exists in multiple files:
%       1) prefer the file whose name contains "updated";
%       2) otherwise, prefer the file with the most recent modification time.
%   - Keeps only the raw columns.
%   - Sorts by epiweek (chronological since YYYYWW is fixed-width).
%   - Writes one merged CSV per UF into outputDir: Merged_<UF>_raw.csv.

if nargin < 1 || isempty(inputDir),  inputDir  = pwd; end
if nargin < 2 || isempty(outputDir), outputDir = fullfile(inputDir, 'merged'); end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

% Canonical raw schema (cell array of char)
rawCols = {...
    'epiweek','cases','temp_min','temp_med','temp_max', ...
    'precip_min','precip_med','precip_max', ...
    'pressure_min','pressure_med','pressure_max', ...
    'rel_humid_min','rel_humid_med','rel_humid_max', ...
    'thermal_range','rainy_days'};

files = dir(fullfile(inputDir, '*.csv'));
if isempty(files)
    fprintf('No CSV files found in %s\n', inputDir);
    return;
end

% Group files by UF
groups = struct();
for k = 1:numel(files)
    fname = files(k).name;
    uf = extractUF(fname);
    if isempty(uf)
        fprintf('Warning: could not infer UF from "%s". Skipping.\n', fname);
        continue;
    end
    entry.path      = fullfile(files(k).folder, fname);
    entry.name      = fname;
    entry.isUpdated = contains(lower(fname), 'updated');
    entry.modTime   = files(k).datenum;
    if ~isfield(groups, uf), groups.(uf) = []; end
    groups.(uf) = [groups.(uf), entry];
end

ufList = fieldnames(groups);
if isempty(ufList)
    fprintf('No state (UF) groups detected in %s.\n', inputDir);
    return;
end

for i = 1:numel(ufList)
    uf = ufList{i};
    entries = groups.(uf);
    if numel(entries) == 0, continue; end

    % Priority: updated first, then newest modification time
    [~, idx] = sortrows([~[entries.isUpdated]' , -[entries.modTime]'], [1 2]);
    entries = entries(idx);

    % Load first file as base
    try
        T = readRawCSV(entries(1).path, rawCols);
    catch ME
        warning('Failed to read/standardize %s: %s', entries(1).name, ME.message);
        continue;
    end

    % Merge the rest for this UF
    for j = 2:numel(entries)
        try
            U = readRawCSV(entries(j).path, rawCols);
        catch ME
            warning('Failed to read/standardize %s: %s', entries(j).name, ME.message);
            continue;
        end

        % Outer join by epiweek
        leftVars  = T.Properties.VariableNames;
        rightVars = setdiff(U.Properties.VariableNames, {'epiweek'});
        TJ = outerjoin(T, U, 'Keys', 'epiweek', 'MergeKeys', true, ...
                       'Type', 'full', ...
                       'LeftVariables',  leftVars, ...
                       'RightVariables', rightVars);

        % Resolve conflicts (prefer right/U) for all raw columns except epiweek
        nonKey = setdiff(rawCols, {'epiweek'});
        for kcol = 1:numel(nonKey)
            c  = nonKey{kcol};
            cL = [c '_T'];
            cR = [c '_U'];
            if ismember(cL, TJ.Properties.VariableNames) && ismember(cR, TJ.Properties.VariableNames)
                TJ.(c) = preferRight(TJ.(cL), TJ.(cR));
                TJ.(cL) = [];
                TJ.(cR) = [];
            elseif ismember(cL, TJ.Properties.VariableNames)
                TJ.(c) = TJ.(cL); TJ.(cL) = [];
            elseif ismember(cR, TJ.Properties.VariableNames)
                TJ.(c) = TJ.(cR); TJ.(cR) = [];
            elseif ~ismember(c, TJ.Properties.VariableNames)
                TJ.(c) = missing;
            end
        end

        % Deduplicate and standardize
        ew = string(TJ.epiweek);
        [~, ui] = unique(ew, 'stable');
        TJ = TJ(ui, :);
        TJ = TJ(:, rawCols);
        TJ = sortByEpiweek(TJ);
        T  = TJ;
    end

    % Final sort and save
    T = sortByEpiweek(T);
    outPath = fullfile(outputDir, sprintf('Merged_%s_raw.csv', uf));
    writetable(T, outPath);
    fprintf('UF %s -> %s (%d rows)\n', uf, outPath, height(T));
end
end

% ===================== Helpers =====================

function uf = extractUF(fname)
% Extract two-letter UF from filename.
uf = '';
tok = regexp(fname, '[_-]([A-Z]{2})(?:[_\-\.])', 'tokens', 'once');
if isempty(tok)
    tok = regexp(upper(fname), '([A-Z]{2})\.CSV$', 'tokens', 'once');
end
if ~isempty(tok), uf = upper(tok{1}); end
end

function T = readRawCSV(pathCsv, rawCols)
% Read a raw CSV, enforce schema, keep epiweek as text (YYYYWW).
opts = detectImportOptions(pathCsv, 'NumHeaderLines', 0);
idx = find(strcmpi(opts.VariableNames, 'epiweek'));
if ~isempty(idx), opts = setvartype(opts, opts.VariableNames{idx}, 'char'); end
T = readtable(pathCsv, opts);

% Normalize headers
names = T.Properties.VariableNames;
names = strtrim(names);
lowerNames = cellfun(@lower, names, 'UniformOutput', false);
renameMap = containers.Map( ...
    lower({ ...
        'epiweek','cases','temp_min','temp_med','temp_max', ...
        'precip_min','precip_med','precip_max', ...
        'pressure_min','pressure_med','pressure_max', ...
        'rel_humid_min','rel_humid_med','rel_humid_max', ...
        'thermal_range','rainy_days' ...
    }), ...
    { ...
        'epiweek','cases','temp_min','temp_med','temp_max', ...
        'precip_min','precip_med','precip_max', ...
        'pressure_min','pressure_med','pressure_max', ...
        'rel_humid_min','rel_humid_med','rel_humid_max', ...
        'thermal_range','rainy_days' ...
    } ...
);
for i = 1:numel(names)
    key = lowerNames{i};
    if isKey(renameMap, key), names{i} = renameMap(key); end
end
T.Properties.VariableNames = names;

if ~ismember('epiweek', T.Properties.VariableNames)
    hit = find(contains(lowerNames,'epi') & contains(lowerNames,'week'), 1);
    if ~isempty(hit)
        names{hit} = 'epiweek';
        T.Properties.VariableNames = names;
    else
        error('Column epiweek not found in %s', pathCsv);
    end
end

% Ensure required columns
for kcol = 1:numel(rawCols)
    c = rawCols{kcol};
    if ~ismember(c, T.Properties.VariableNames), T.(c) = missing; end
end

% Clean epiweek and keep as text YYYYWW
T.epiweek = string(cleanEpiweekStrings(T.epiweek));

% Reorder and sort
T = T(:, rawCols);
T = sortByEpiweek(T);
end

function s = cleanEpiweekStrings(col)
% Convert to strings and remove trailing .0 if present.
if iscell(col), s = string(col);
elseif isstring(col), s = col;
elseif ischar(col), s = string({col});
elseif isnumeric(col), s = string(num2str(col(:)));
else, s = string(col);
end
for i = 1:numel(s)
    si = strtrim(s(i));
    if endsWith(si, '.0'), s(i) = extractBefore(si, strlength(si)-1); else, s(i) = si; end
end
end

function out = preferRight(leftCol, rightCol)
% Prefer values from rightCol when available.
if iscell(leftCol) || iscell(rightCol)
    ls = string(leftCol); rs = string(rightCol);
    useR = rs ~= "" & rs ~= "NaN" & rs ~= "NA";
    out = ls; out(useR) = rs(useR);
    return;
end
if isnumeric(leftCol) && isnumeric(rightCol)
    out = leftCol; mask = ~isnan(rightCol); out(mask) = rightCol(mask);
    return;
end
out = leftCol; mask = ~ismissing(rightCol); out(mask) = rightCol(mask);
end

function T = sortByEpiweek(T)
% Sort table chronologically by epiweek YYYYWW.
ew = string(T.epiweek);
num = str2double(ew);
tmp = table(num, ew, 'VariableNames', {'num','ew'});
T = sortrows([tmp T], {'num','ew'}, {'ascend','ascend'});
T.num = []; T.ew = [];
end
