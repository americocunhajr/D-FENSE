function CVS2StandardFormat(inputDir, outputDir)
% CVS2StandardFormat  Converte CSVs de previsão para o layout padrão
% Uso:
%   CVS2StandardFormat('data_raw', 'output')  % pastas exemplo
%
% Saída:
%   - CSVs convertidos em outputDir, com colunas:
%     date, lower_95, lower_90, lower_80, lower_50, pred, upper_50, upper_80, upper_90, upper_95
%   - Arquivo ZIP com tudo: output_converted.zip
%
% Regras:
%   - Se 'date' contiver epiweek (YYYYWW), converte para DOMINGO anterior (semana Sunday-start) via ISO.
%   - Se 'date' já for uma data, normaliza para 'yyyy-mm-dd'.
%   - Aceita cabeçalhos:
%       (a) epiweek, median_cases, LB95, UB95, ...
%       (b) LB_95, LB_90, ..., prev_med, ..., Data

if nargin < 1 || isempty(inputDir),  inputDir  = pwd; end
if nargin < 2 || isempty(outputDir), outputDir = fullfile(inputDir,'output'); end
if ~exist(outputDir,'dir'), mkdir(outputDir); end

% Mapeamento original -> destino (aceita variações com "_" e nomes em pt)
renameMap = containers.Map( ...
    lower([ ...
        "epiweek","median_cases", ...
        "lb95","ub95","lb90","ub90","lb80","ub80","lb50","ub50", ...
        "lb_95","ub_95","lb_90","ub_90","lb_80","ub_80","lb_50","ub_50", ...
        "prev_med","data" ...
    ]), ...
    [ ...
        "date","pred", ...
        "lower_95","upper_95","lower_90","upper_90","lower_80","upper_80","lower_50","upper_50", ...
        "lower_95","upper_95","lower_90","upper_90","lower_80","upper_80","lower_50","upper_50", ...
        "pred","date" ...
    ] ...
);

% Ordem final das colunas
targetCols = ["date","lower_95","lower_90","lower_80","lower_50","pred","upper_50","upper_80","upper_90","upper_95"];

files = dir(fullfile(inputDir,'*.csv'));
if isempty(files)
    fprintf('Nenhum CSV encontrado em %s\n', inputDir); return;
end

for k = 1:numel(files)
    inPath = fullfile(files(k).folder, files(k).name);
    try
        % Import robusto (detecta delimitador e nomes)
        opts = detectImportOptions(inPath, 'NumHeaderLines', 0);
        % Garantir que epiweek venha como texto (evita 202541 virar 2.0254e+05)
        idx = find(strcmpi(opts.VariableNames,'epiweek'));
        if ~isempty(idx)
            opts = setvartype(opts, opts.VariableNames{idx}, 'char');
        end
        T = readtable(inPath, opts);

        % Normaliza nomes (trim e minúsculas para mapear)
        T.Properties.VariableNames = strtrim(T.Properties.VariableNames);
        lowerNames = lower(T.Properties.VariableNames);

        % Renomeia conforme mapa (case-insensitive)
        for i = 1:numel(lowerNames)
            key = lowerNames{i};
            if isKey(renameMap, key)
                T.Properties.VariableNames{i} = renameMap(key);
            end
        end

        % Se não renomeou por algum motivo, tenta achar epiweek "parecido" e promover a 'date'
        if ~any(strcmp(T.Properties.VariableNames,'date'))
            cand = contains(lowerNames,'epi') & contains(lowerNames,'week');
            if any(cand)
                T.Properties.VariableNames{find(cand,1)} = 'date';
            else
                error('Coluna epiweek/Data não encontrada em %s', files(k).name);
            end
        end

        % ---- Criar/normalizar coluna date ----
        dateCells = toCellStr(T.date);
        T.date = cellfun(@normalizeDate, dateCells, 'UniformOutput', false);

        % Garantir todas as colunas do esquema final
        for c = targetCols
            if ~ismember(c, T.Properties.VariableNames)
                T.(c) = missing;  % cria coluna vazia se necessário
            end
        end

        % Reordenar e manter apenas o esquema final
        T = T(:, targetCols);

        % Arredondar apenas colunas numéricas (todas exceto 'date')
        numCols = setdiff(targetCols, "date");
        for c = numCols
            if isnumeric(T.(c))
                T.(c) = round(T.(c));
                % Evitar zeros: substitui 0 por 1
                T.(c)(T.(c) == 0) = 1;
            end
        end

        % Salvar
        outPath = fullfile(outputDir, files(k).name);
        writetable(T, outPath);

        fprintf('OK: %s -> %s\n', files(k).name, outPath);
    catch ME
        warning('Falha em %s: %s', files(k).name, ME.message);
    end
end

% Zip com tudo
zip(fullfile(outputDir,'output_converted.zip'), fullfile(outputDir,'*.csv'));
fprintf('ZIP gerado em: %s\n', fullfile(outputDir,'output_converted.zip'));

end

% --------- Funções auxiliares ---------

function s = toCellStr(col)
% Converte vetor/tabela para cellstr, com limpeza de '.0' ao fim se vier de floats
if iscell(col)
    s = col;
elseif isstring(col)
    s = cellstr(col);
elseif ischar(col)
    s = {col};
elseif isnumeric(col)
    s = cellstr(num2str(col(:)));
else
    s = cellstr(string(col));
end
% remove sufixo ".0" comum em CSVs
for i=1:numel(s)
    if ~isempty(s{i}) && endsWith(s{i},'.0')
        s{i} = extractBefore(s{i}, strlength(s{i})-1);
    end
end
end

function ymd = normalizeDate(s)
% Detecta automaticamente epiweek (YYYYWW) ou data e retorna 'yyyy-mm-dd'.
    s = strtrim(string(s));
    if endsWith(s,'.0'), s = extractBefore(s, strlength(s)-1); end

    if isEpiweekString(s)
        ymd = epiweekToSunday(s);  % domingo anterior à segunda ISO
        return;
    end

    % tenta parsear como data (vários formatos comuns)
    fmts = ["yyyy-MM-dd","dd/MM/yyyy","MM/dd/yyyy","dd-MM-yyyy","MM-dd-yyyy","yyyy/MM/dd","dd.MM.yyyy","MM.dd.yyyy"];
    dt = NaT;
    for f = fmts
        try
            dt = datetime(s, 'InputFormat', f);
            if ~isnat(dt), break; end
        catch
        end
    end
    if isnat(dt)
        % última tentativa: deixar o MATLAB decidir (pode falhar em strings ambíguas)
        try
            dt = datetime(s);
        catch
            error("Não foi possível interpretar a data: '%s'", s);
        end
    end
    ymd = datestr(dt, 'yyyy-mm-dd');
end

function tf = isEpiweekString(s)
% True se a string for exatamente 6 dígitos (YYYYWW)
    tf = ~isempty(regexp(s, '^\d{6}$', 'once'));
end

function ymd = epiweekToSunday(weekId)
% Converte "YYYYWW" (sem separador) para data do DOMINGO (Sunday-start) da semana ISO correspondente.
% Estratégia:
%   - ISO semana 1 = semana que contém 4 de janeiro.
%   - Pegamos a SEGUNDA da semana alvo (ISO), depois:
%       domingo = dateshift(segunda, 'dayofweek', 'sunday', 'previous')
%     (ou seja, o domingo imediatamente anterior à segunda ISO da semana W).
    str = strtrim(weekId);
    if strlength(str) < 6
        error('epiweek inválido: %s', str);
    end
    Y = str2double(extractBefore(str,5));
    W = str2double(extractAfter(str,4));

    % Segunda-feira da semana 1 (ISO) do ano Y (semana que contém 4 de janeiro)
    d = datetime(Y,1,4);
    dow = weekday(d, 'monday');                   % 1=segunda ... 7=domingo
    monday_w1 = d - days(dow-1);                  % volta até segunda
    monday_target = monday_w1 + days(7*(W-1));    % pula semanas W-1

    % Domingo "que abre" a semana Sunday-start (anterior à segunda ISO)
    sunday = dateshift(monday_target, 'dayofweek', 'sunday', 'previous');
    ymd = datestr(sunday, 'yyyy-mm-dd');
end
