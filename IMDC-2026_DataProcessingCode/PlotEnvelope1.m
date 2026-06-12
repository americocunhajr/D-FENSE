% -----------------------------------------------------------------
%  PlotEnvelope1.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Aug 30, 2024
%           Last updated in: Jul 28, 2025
% -----------------------------------------------------------------
% This function plots a time series data with a solid line
% and a shaded area representing the range between minimum 
% and maximum values.
% 
% Input:
% time     - datetime vector
% T_min    - vector of minimum values
% T_med    - vector of median  values
% T_max    - vector of maximum values
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig       - the handle to the created figure
% ----------------------------------------------------------------- 
function fig = PlotEnvelope1(time,T_min,T_med,T_max,graphobj)
    
    % Check number of arguments
    if nargin < 5
        error('Too few inputs.')
    elseif nargin > 5
        error('Too many inputs.')
    end

    % Check arguments for length compatibility
    if length(time) ~= length(T_min) || ...
       length(time) ~= length(T_med) || ...
       length(time) ~= length(T_max)
        error('time, T_min, T_med, and T_max vectors must be the same length')
    end

    % Ensure all input vectors are row vectors
    if find(size(time) == max(size(time))) < 2
        time = time';
    end
    if find(size(T_min) == max(size(T_min))) < 2
        T_min = T_min';
    end
    if find(size(T_med) == max(size(T_med))) < 2
        T_med = T_med';
    end
    if find(size(T_max) == max(size(T_max))) < 2
        T_max = T_max';
    end
    
    % Create the figure
    fig = figure('Name',graphobj.gname,'NumberTitle','off');
    
    % Plot the shaded area between T_min and T_max
    fig1 = fill([time,fliplr(time)],[T_min, fliplr(T_max)], ...
                graphobj.shadecolor,'DisplayName',graphobj.labelshade,...
                'FaceAlpha', 0.3,'EdgeColor'  , 'none');
    hold on;
    
    % Plot the median Terature curve
    fig2 = plot(time,T_med,'LineWidth'  ,2,...
                                'Color'      ,graphobj.linecolor,...
                                'DisplayName',graphobj.labelcurve);

    % Set font and box
    set(gcf,'color','white');
    set(gca,'position',[0.2 0.2 0.7 0.7]);
    set(gca,'Box','on');
    set(gca,'TickDir','out','TickLength',[.02 .02]);
    set(gca,'XMinorTick','off','YMinorTick','off');
    set(gca,'XGrid','off','YGrid','off');
    set(gca,'XColor',[.3 .3 .3],'YColor',[.3 .3 .3]);
    set(gca,'FontName','Helvetica');
    set(gca,'FontSize',18);
    box on;
    grid on;

    % Set legend
    leg = [fig2; fig1];
    leg = legend(leg,'Location','NorthEast');
    set(leg,'FontSize',16);
    
    % Set axis limits
    xlim([min(time) max(time)]);

    % Formatting the x-axis to show dates in "month-year" format
    datetick('x', 'mmm yyyy', 'keepticks', 'keeplimits');
    
    % Rotate the x-axis labels for better readability
    xtickangle(45);

    if ( strcmp(graphobj.ymin,'auto') || strcmp(graphobj.ymax,'auto') )
        ylim('auto');
    else
        ylim([graphobj.ymin graphobj.ymax]);
    end
    
    % Set labels
    ylabel(graphobj.ylab, 'FontSize', 20, 'FontName', 'Helvetica');

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
