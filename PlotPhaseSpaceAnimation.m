% -----------------------------------------------------------------
%  PlotPhaseSpaceAnimation.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Sep 03, 2024
%           Last updated in: Sep 03, 2024
% -----------------------------------------------------------------
% This function plots a 3D phase space diagram of dengue dynamics
% and creates an animation showing the dynamics over time.
% 
% Input:
% T        - vector of temperature data
% P        - vector of total precipitation
% C        - vector of dengue cases
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig      - the handle to the created figure
% ----------------------------------------------------------------- 
function fig = PlotPhaseSpaceAnimation(T, P, C, graphobj)
    
    % Check number of arguments
    if nargin < 4
        error('Too few inputs.')
    elseif nargin > 4
        error('Too many inputs.')
    end

    % Check arguments for length compatibility
    if length(C) ~= length(T) || length(C) ~= length(P)
        error('C, T, and P vectors must be the same length')
    end

    % Ensure inputs are row vectors
    if find(size(C) == max(size(C))) < 2
        C = C';
    end
    if find(size(T) == max(size(T))) < 2
        T = T';
    end
    if find(size(P) == max(size(P))) < 2
        P = P';
    end
    
    % Create the figure
    fig = figure('Name', graphobj.gname, 'NumberTitle', 'off');
    set(gcf, 'color', 'white');
    
    % Initialize plot handle
    hPlot = plot3(T(1), P(1), C(1), 'Color', graphobj.linecolor, 'LineWidth', 1.5);
    hold on;
    
    % Set grid and axis limits
    grid on;
    xlim([0 max(T)]);
    ylim([0 max(P)]);
    zlim([0 max(C)]);
    view(45, 45);
    
    % Set axis labels from graphobj struct
    xlabel(graphobj.xlab, 'FontSize', 18, 'FontName', 'Helvetica');
    ylabel(graphobj.ylab, 'FontSize', 18, 'FontName', 'Helvetica');
    zlabel(graphobj.zlab, 'FontSize', 18, 'FontName', 'Helvetica');

    % Set title from graphobj struct
    title(graphobj.gtitle, 'FontSize', 24, 'FontName', 'Helvetica');

    % Add logo image to the northwest part of the plot
    axes('Position', [0.2 0.5 0.15 0.15]);
    imshow('logo/D-FENSE.png');
    axis off;

    % Add author name outside the plot area, parallel to y-label
    if isfield(graphobj, 'signature') && ~isempty(graphobj.signature)
        annotation('textbox', [0.98, 0.2, 0.5, 0.5], 'String', ...
            graphobj.signature, 'FontSize', 12, ...
            'FontName', 'Helvetica', 'Color', [0.5 0.5 0.5], ...
            'Rotation', 90, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'EdgeColor', 'none');
    end

    % Create GIF file
    gif_filename = [graphobj.gname, '.gif'];

    % Set the update interval
    update_interval = 8; % Update every 5 frames for faster rendering
    
    % Loop through each point to create animation frames
    for k = 1:update_interval:length(C)
        % Update the plot data instead of re-plotting
        set(hPlot, 'XData', T(1:k), 'YData', P(1:k), 'ZData', C(1:k));

        % Add the year as text above the plot box
        current_year = graphobj.years(k);
        year_text = text(max(xlim)+0.1*range(xlim),max(ylim)+0.6*range(ylim),max(zlim)+0.6*range(zlim),...
                         sprintf('%d', current_year), 'FontSize', 14, ...
                         'FontName', 'Helvetica', 'Color', 'k', ...
                         'HorizontalAlignment', 'center');
    
        % Capture the current frame for GIF
        frame = getframe(fig);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
    
        % Write to GIF file
        if k == 1
            imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
        else
            imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
    
        % Delete the year text to avoid overlap in the next frame
        delete(year_text);
    end
    
    % Save the full phase space diagram as EPS and PNG if required
    if strcmp(graphobj.print, 'yes')
        print('-depsc2', [graphobj.gname, '.eps']);
        print('-dpng', [graphobj.gname, '.png']);
    end

    % Close the figure if requested
    if strcmp(graphobj.close, 'yes')
        close(fig);
    end
end
% -----------------------------------------------------------------