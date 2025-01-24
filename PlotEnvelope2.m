% -----------------------------------------------------------------
%  PlotEnvelope2.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Aug 30, 2024
%           Last updated in: Sep 10, 2024
% -----------------------------------------------------------------
% This function plots a time series data with a solid line
% and a shaded area representing the range between minimum 
% and maximum values on the left y-axis, and a separate line 
% on the right y-axis.
% 
% Input:
% time     - datetime vector
% P_min    - vector of minimum values
% P_med    - vector of median  values
% P_max    - vector of maximum values
% P_tot    - vector of total   values
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig       - the handle to the created figure
% ----------------------------------------------------------------- 
function fig = PlotEnvelope2(time,P_min,P_med,P_max,P_tot,graphobj)
    
    % Check number of arguments
    if nargin < 6
        error('Too few inputs.')
    elseif nargin > 6
        error('Too many inputs.')
    end

    % Check arguments for length compatibility
    if length(time) ~= length(P_min) || ...
       length(time) ~= length(P_med) || ...
       length(time) ~= length(P_max) || ...
       length(time) ~= length(P_tot)
        error('time, P_min, P_med, P_max, and P_tot vectors must be the same length')
    end

    % Ensure all input vectors are row vectors
    if find(size(time) == max(size(time))) < 2
        time = time';
    end
    if find(size(P_min) == max(size(P_min))) < 2
        P_min = P_min';
    end
    if find(size(P_med) == max(size(P_med))) < 2
        P_med = P_med';
    end
    if find(size(P_max) == max(size(P_max))) < 2
        P_max = P_max';
    end
    if find(size(P_tot) == max(size(P_tot))) < 2
        P_tot = P_tot';
    end
    
    % Create the figure
    fig = figure('Name', graphobj.gname, 'NumberTitle', 'off');

    colororder({'k','k'})
    
    % Plot the shaded area between P_min and P_max on the left y-axis
    yyaxis left;
    fig1 = fill([time, fliplr(time)], [P_min, fliplr(P_max)], ...
                graphobj.shadecolor, 'DisplayName', graphobj.labelshade, ...
                'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on;
    
    % Plot the median precipitation curve on the left y-axis
    fig2 = plot(time, P_med, '-','LineWidth'  ,2, ...
                                  'Color'      ,graphobj.linecolor_l,...
                                  'DisplayName',graphobj.labelcurve_l);

    % Set left y-axis properties
    ylabel(graphobj.ylab_l, 'FontSize', 20, 'FontName', 'Helvetica');

    if strcmp(graphobj.ymin_l, 'auto') || strcmp(graphobj.ymax_l, 'auto')
        yyaxis left;
        ylim('auto');
    else
        yyaxis left;
        ylim([graphobj.ymin_l graphobj.ymax_l]);
    end
    
    % Plot the total precipitation on the right y-axis
    yyaxis right;
    fig3 = plot(time, P_tot,'--','LineWidth',0.8, ...
                                 'Color'      ,graphobj.linecolor_r,...
                                 'DisplayName',graphobj.labelcurve_r);

    % Set left y-axis properties
    ylabel(graphobj.ylab_r, 'FontSize', 20, 'FontName', 'Helvetica');

    % Set font and box
    set(gcf, 'color', 'white');
    set(gca, 'position', [0.2 0.2 0.6 0.7]);
    set(gca, 'Box', 'on');
    set(gca, 'TickDir', 'out', 'TickLength', [.02 .02]);
    set(gca, 'XMinorTick', 'off', 'YMinorTick', 'off');
    set(gca, 'XGrid', 'off', 'YGrid', 'off');
    %set(gca, 'XColor', [.3 .3 .3], 'YColor', [.3 .3 .3]);
    set(gca, 'FontName', 'Helvetica');
    set(gca, 'FontSize', 18);
    box on;
    grid on;

    % Set legend
    leg = legend([fig2; fig1; fig3], 'Location', 'NorthEast');
    set(leg, 'FontSize', 16);
    
    % Set axis limits
    xlim([min(time) max(time)] + calmonths([0 6]));
    
    if strcmp(graphobj.ymin_r, 'auto') || strcmp(graphobj.ymax_r, 'auto')
        yyaxis right;
        ylim('auto');
    else
        yyaxis right;
        ylim([graphobj.ymin_r graphobj.ymax_r]);
    end

    % Formatting the x-axis to show dates in "month-year" format
    datetick('x', 'mmm yyyy', 'keepticks');

    % Rotate the x-axis labels for better readability
    xtickangle(45);

    % Set the title
    title(graphobj.gtitle, 'FontSize', 24, 'FontName', 'Helvetica');

    % Add logo image to the northwest part of the plot
    axes('Position', [0.22 0.75 0.15 0.15]);
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

    % Save the plot as an EPS file if required
    if strcmp(graphobj.print, 'yes')
        print('-depsc2', [graphobj.gname, '.eps']);
        print('-dpng'  , [graphobj.gname, '.png']);
    end

    % Close the figure if requested
    if strcmp(graphobj.close, 'yes')
        close(fig);
    end
end
% -----------------------------------------------------------------
