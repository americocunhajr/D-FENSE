% -----------------------------------------------------------------
%  PlotPhaseSpace.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Sep 03, 2024
%           Last updated in: Sep 03, 2024
% -----------------------------------------------------------------
% This function plots a 3D phase space diagram of dengue dynamics.
% 
% Input:
% C        - vector of dengue cases
% T        - vector of temperature data
% P        - vector of total precipitation
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig      - the handle to the created figure
% ----------------------------------------------------------------- 
function fig = PlotPhaseSpace(T,P,C,graphobj)
    
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
    
    % Plot the true dynamics
    plot3(T,P,C,'Color',graphobj.linecolor,'LineWidth', 1.5);

    % Set font and box
    set(gcf,'color','white');
    %set(gca,'position',[0.2 0.2 0.7 0.7]);
    set(gca,'Box','on');
    set(gca,'TickDir','out','TickLength',[.02 .02]);
    set(gca,'XMinorTick','off','YMinorTick','off','ZMinorTick','off');
    set(gca,'XGrid','off','YGrid','off','ZGrid','off');
    set(gca,'XColor',[.3 .3 .3],'YColor',[.3 .3 .3],'ZColor',[.3 .3 .3]);
    set(gca,'FontName','Helvetica');
    set(gca,'FontSize',18);
    grid on
    
    % Set axis limits
    if ( strcmp(graphobj.xmin,'auto') || strcmp(graphobj.xmax,'auto') )
        xlim('auto');
    else
        xlim([graphobj.xmin graphobj.xmax]);
    end

    if ( strcmp(graphobj.ymin,'auto') || strcmp(graphobj.ymax,'auto') )
        ylim('auto');
    else
        ylim([graphobj.ymin graphobj.ymax]);
    end

    if ( strcmp(graphobj.zmin,'auto') || strcmp(graphobj.zmax,'auto') )
        zlim('auto');
    else
        zlim([graphobj.zmin graphobj.zmax]);
    end
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

    % Save the plot as an EPS and PNG file if required
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