% -----------------------------------------------------------------
%  PlotPhaseSpaceAnimation.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%               <americo.cunhajr@gmail.com>
%
%  Originally programmed in: Sep 03, 2024
%            Last update in: Aug 08, 2025
% -----------------------------------------------------------------
% This function plots a 3D phase-space diagram (T,P,C) and creates
% an animation. The trajectory color is a normalized mapping of C:
%   - min(C)  -> lowest color in the colormap
%   - max(C)  -> highest color in the colormap
% The colorbar is displayed WITHOUT ticks or labels.
%
% Input:
%   T        - vector of temperature data (N x 1 or 1 x N)
%   P        - vector of precipitation data (N x 1 or 1 x N)
%   C        - vector of dengue cases       (N x 1 or 1 x N)
%   graphobj - struct with fields (some optional):
%       .gname     - figure / file base name
%       .xlab      - x-axis label
%       .ylab      - y-axis label
%       .zlab      - z-axis label
%       .gtitle    - plot title
%       .signature - optional text annotation (string)
%       .print     - 'yes' to save EPS/PNG
%       .close     - 'yes' to close figure after creation
%       .colormap  - Kx3 RGB colormap (default: parula(256))
%       .years     - (optional) vector of years for per-frame label (length >= N)
%       .update_interval - positive integer (default: 8)
%
% Output:
%   fig - handle to the created figure
% -----------------------------------------------------------------
function fig = PlotPhaseSpaceAnimation(T, P, C, graphobj)

    % ------------------------------
    % check number of arguments
    % ------------------------------
    if nargin < 4
        error('Too few inputs.');
    elseif nargin > 4
        error('Too many inputs.');
    end

    % ------------------------------
    % check inputs and reshape
    % ------------------------------
    if ~isvector(T) || ~isvector(P) || ~isvector(C)
        error('T, P, and C must be vectors.');
    end
    T = T(:)';  P = P(:)';  C = C(:)';   % row orientation

    N = numel(C);
    if numel(T) ~= N || numel(P) ~= N
        error('T, P, and C must have the same length.');
    end

    % ------------------------------
    % colormap and normalization
    % ------------------------------
    if isfield(graphobj,'colormap') && ~isempty(graphobj.colormap)
        cmap = graphobj.colormap;
    else
        cmap = parula(256);
    end

    % normalize color by C-range only: min(C)->0, max(C)->1
    cminRef = min(C);
    cmaxRef = max(C);
    if cmaxRef == cminRef
        normColor = zeros(1,N);                % flat color if constant C
    else
        normColor = (C - cminRef) / (cmaxRef - cminRef);
        normColor = max(0, min(1, normColor)); % clamp to [0,1]
    end

    % ------------------------------
    % figure and axes
    % ------------------------------
    fig = figure('Name', graphobj.gname, 'NumberTitle', 'off');
    set(gcf, 'Color', 'white');
    ax = axes('Parent', fig);
    hold(ax, 'on'); grid(ax, 'on');
    view(ax, 45, 45);

    % axis limits from data
    xlim(ax, [graphobj.xmin graphobj.xmax]);
    ylim(ax, [graphobj.ymin graphobj.ymax]);
    zlim(ax, [graphobj.zmin graphobj.zmax]);

    % labels and title
    xlabel(ax, getfielddef(graphobj,'xlab','Temperature'), ...
        'FontSize', 18, 'FontName', 'Helvetica');
    ylabel(ax, getfielddef(graphobj,'ylab','Precipitation'), ...
        'FontSize', 18, 'FontName', 'Helvetica');
    zlabel(ax, getfielddef(graphobj,'zlab','Cases'), ...
        'FontSize', 18, 'FontName', 'Helvetica');
    title(ax, getfielddef(graphobj,'gtitle',''), ...
        'FontSize', 24, 'FontName', 'Helvetica');

    % colormap and color scale (unit interval)
    colormap(ax, cmap);
    caxis(ax, [0 1]);

    % colorbar WITHOUT ticks or labels
    cb = colorbar(ax);
    cb.Ticks = [];
    cb.TickLabels = {};
    % (intentionally no ylabel for the colorbar)

    % ------------------------------
    % colored trajectory (surface-trick)
    % ------------------------------
    % draw a 1-pixel "ribbon" whose EdgeColor is interpolated by CData
    XX = [T(1); T(1)];
    YY = [P(1); P(1)];
    ZZ = [C(1); C(1)];
    CC = [normColor(1); normColor(1)];
    hLine = surface(ax, XX, YY, ZZ, CC, ...
        'FaceColor', 'none', 'EdgeColor', 'interp', 'LineWidth', 2);

    % ------------------------------
    % optional logo (if file exists)
    % ------------------------------
    if exist('logo/D-FENSE.png','file') == 2
        axLogo = axes('Position', [0.20 0.50 0.15 0.15]);
        imshow('logo/D-FENSE.png'); axis off;
        axes(ax); % back to main axes
    end

    % ------------------------------
    % optional signature
    % ------------------------------
    if isfield(graphobj,'signature') && ~isempty(graphobj.signature)
        annotation('textbox', [0.98, 0.2, 0.5, 0.5], ...
            'String', graphobj.signature, ...
            'FontSize', 12, 'FontName', 'Helvetica', ...
            'Color', [0.5 0.5 0.5], 'Rotation', 90, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'LineStyle', 'none');
    end

    % ------------------------------
    % animation setup
    % ------------------------------
    gif_filename    = [graphobj.gname, '.gif'];
    update_interval = getfielddef(graphobj,'update_interval',8);

    % position for year label (if provided)
    xr = xlim(ax); yr = ylim(ax); zr = zlim(ax);
    x_text = xr(1) + 0.60*(xr(2)-xr(1));
    y_text = yr(1) + 0.60*(yr(2)-yr(1));
    z_text = zr(1) + 1.10*(zr(2)-zr(1));

    % ------------------------------
    % animation loop
    % ------------------------------
    for k = 1:update_interval:N
        % update line data up to frame k
        set(hLine, ...
            'XData', [T(1:k); T(1:k)], ...
            'YData', [P(1:k); P(1:k)], ...
            'ZData', [C(1:k); C(1:k)], ...
            'CData', [normColor(1:k); normColor(1:k)]);

        % draw year (if available)
        year_text = [];
        if isfield(graphobj,'years') && numel(graphobj.years) >= k
            year_text = text(ax, x_text, y_text, z_text, ...
                sprintf('%d', graphobj.years(k)), ...
                'FontSize', 14, 'FontName', 'Helvetica', ...
                'Color', 'k', 'HorizontalAlignment', 'center');
        end

        % capture frame and write to GIF
        drawnow;
        frame = getframe(fig);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        if k == 1
            imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
        else
            imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end

        if ~isempty(year_text)
            delete(year_text);
        end
    end

    % ------------------------------
    % save static images if required
    % ------------------------------
    if isfield(graphobj,'print') && strcmpi(graphobj.print,'yes')
        print(fig, '-depsc2', [graphobj.gname, '.eps']);
        print(fig, '-dpng'  , [graphobj.gname, '.png']);
    end

    % ------------------------------
    % close figure if requested
    % ------------------------------
    if isfield(graphobj,'close') && strcmpi(graphobj.close,'yes')
        close(fig);
    end
end
% -----------------------------------------------------------------

% -----------------------------------------------------------------
function v = getfielddef(s, f, d)
    if isfield(s,f) && ~isempty(s.(f))
        v = s.(f);
    else
        v = d;
    end
end
% -----------------------------------------------------------------