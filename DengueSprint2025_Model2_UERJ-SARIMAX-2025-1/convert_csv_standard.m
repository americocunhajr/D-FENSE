function convert_csv_standard(inputDir, outputDir, filePattern)
% convert_csv_standard  Convert and reorder CSVs to a standard layout
%
%   convert_csv_standard(inputDir, outputDir, filePattern)
%
%   Reads all CSVs matching filePattern in inputDir, drops the first
%   column, renames/reorders columns to:
%       lower_95, lower_90, lower_80, lower_50, pred,
%       upper_50, upper_80, upper_90, upper_95, date
%   Converts numeric fields to positive integers, and writes the cleaned
%   files into outputDir, preserving filenames.
%
%   Example:
%     convert_csv_standard('raw_data','cleaned','T*_arimax_*.csv');

    if nargin < 1 || isempty(inputDir)
        error('Input directory must be specified.');
    end
    if nargin < 2 || isempty(outputDir)
        error('Output directory must be specified.');
    end
    if nargin < 3 || isempty(filePattern)
        filePattern = '*.csv';
    end

    % ensure output dir exists
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    % list matching files
    files = dir(fullfile(inputDir, filePattern));
    if isempty(files)
        warning('No files found matching %s in %s.', filePattern, inputDir);
        return;
    end

    % desired final column order
    standardCols = { ...
        'lower_95','lower_90','lower_80','lower_50', ...
        'pred', ...
        'upper_50','upper_80','upper_90','upper_95', ...
        'date' };

    for k = 1:numel(files)
        fname = files(k).name;
        inpath = fullfile(inputDir, fname);

        %--- sniff delimiter ---
        fid = fopen(inpath,'r');
        line1 = fgetl(fid);
        fclose(fid);
        if contains(line1, sprintf('\t'))
            delim = '\t';
        elseif contains(line1, ';')
            delim = ';';
        else
            delim = ',';
        end

        %--- read table ---
        opts = detectImportOptions(inpath, 'Delimiter', delim);
        T = readtable(inpath, opts);

        %--- drop first (useless) column ---
        T(:,1) = [];

        %--- normalize names: trim, lower, drop BOM ---
        names = T.Properties.VariableNames;
        for i = 1:numel(names)
            v = strtrim(names{i});
            v = lower(strrep(v, char(65279), ''));
            T.Properties.VariableNames{i} = v;
        end

        %--- rename raw → standard (date directly) ---
        mappings = { ...
            'data','date'; ...
            'prev_med','pred'; ...
            'lb_95','lower_95'; 'lb_90','lower_90'; ...
            'lb_80','lower_80'; 'lb_50','lower_50'; ...
            'ub_50','upper_50'; 'ub_80','upper_80'; ...
            'ub_90','upper_90'; 'ub_95','upper_95' };
        for i = 1:size(mappings,1)
            old = mappings{i,1};
            new = mappings{i,2};
            if ismember(old, T.Properties.VariableNames)
                T.Properties.VariableNames{strcmp(T.Properties.VariableNames,old)} = new;
            end
        end

        %--- check required cols ---
        if ~all(ismember(standardCols, T.Properties.VariableNames))
            missing = setdiff(standardCols, T.Properties.VariableNames);
            error('File %s missing columns: %s', fname, strjoin(missing,','));
        end

        %--- convert numeric date (year+week) into ISO-Monday string ---
        yw = T.date;
        ds = strings(size(yw));
        for i = 1:numel(yw)
            s = sprintf('%06.0f', yw(i));
            yr = str2double(s(1:4));
            wk = str2double(s(5:6));
            dref = datetime(yr,1,4);
            off = mod(weekday(dref)-2,7);
            mon1 = dref - days(off);
            ds(i) = datestr(mon1 + calweeks(wk-1),'yyyy-mm-dd');
        end
        T.date = ds;

        %--- reorder columns ---
        T = T(:, standardCols);

        %--- enforce positive integers on numeric fields ---
        for i = 1:(width(T)-1)  % skip 'date'
            col = T{:,i};
            if isnumeric(col)
                T{:,i} = abs(round(col));
            else
                T{:,i} = round(abs(str2double(string(col))));
            end
        end

        %--- write cleaned CSV ---
        writetable(T, fullfile(outputDir,fname));
        fprintf('Processed %s → %s\n', fname, fullfile(outputDir,fname));
    end

    fprintf('All done. Clean files in %s\n', outputDir);
end

