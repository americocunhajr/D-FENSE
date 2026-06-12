% -----------------------------------------------------------------
%  PlotStatistics.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%              americo.cunhajr@gmail.com
%
%  Originally programmed in: Dec 26, 2017
%            Last update in: Sep 11, 2024
% -----------------------------------------------------------------
% This function plots the PDF curve and other statistics of a 
% given random variable, including the mean, standard deviation,
% and quantiles.
%
% Input:
% X_supp   - pdf x data vector
% X_pdf    - pdf y data vector
% X_mean   - mean value
% X_std    - standard deviation
% X_low    - lower quantile
% X_upp    - upper quantile
% X_bins   - histogram bin edges
% X_freq   - histogram frequencies
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig      - handle to the created figure
% ----------------------------------------------------------------- 
function fig = PlotStatistics(X_supp,X_pdf,X_mean,X_std,...
                              X_low,X_upp,X_bins,X_freq,graphobj)
    
    % Check number of arguments
    if nargin ~= 9
        error('Incorrect number of inputs.');
    end

    % Check vector length compatibility
    if length(X_supp) ~= length(X_pdf)
        error('X_supp and X_ksd must have the same length.');
    end
    
    % Ensure all input vectors are row vectors
    if iscolumn(X_supp) 
        X_supp = X_supp';
    end
    if iscolumn(X_pdf) 
        X_pdf = X_pdf';
    end

    % Create figure
    fig = figure('Name', graphobj.gname, 'NumberTitle', 'off');
    
    % Plot histogram as bar
    fh6 = bar(X_bins,X_freq,0.9,'FaceColor',graphobj.barcolor,...
                                'EdgeColor',graphobj.barcolor,...
                                'LineStyle','-');
    hold on;
    
    % Plot PDF curve and statistics lines
    fh1 = plot(X_supp,X_pdf, ...
         'Color'      , graphobj.linecolor1,...
         'LineWidth'  , 2 ,...
         'DisplayName', graphobj.leg1);
    fh2 = line([X_mean X_mean],[graphobj.ymin graphobj.ymax],...
         'Color'      , graphobj.linecolor2,...
         'LineWidth'  , 3  , ...
         'DisplayName', graphobj.leg2);
    fh3 = line([X_std X_std],[graphobj.ymin graphobj.ymax], ...
         'Color'      , graphobj.linecolor3,...
         'LineStyle'  , '--', ...
         'LineWidth'  , 2   , ...
         'DisplayName', graphobj.leg3);
    fh4 = line([X_low X_low],[graphobj.ymin graphobj.ymax], ...
         'Color'      , graphobj.linecolor4,...
         'LineStyle'  , '-.', ...
         'LineWidth'  , 2   , ...
         'DisplayName', graphobj.leg4);
    fh5 = line([X_upp X_upp],[graphobj.ymin graphobj.ymax], ...
         'Color'      , graphobj.linecolor4,...
         'LineStyle', '-.', ...
         'LineWidth', 2);
    
    % Set axes properties
    set(gcf, 'color', 'white');
    set(gca,'position',[0.2 0.2 0.7 0.7]);
    set(gca,'Box','on');
    set(gca,'TickDir','out','TickLength',[.02 .02]);
    set(gca,'XMinorTick','off','YMinorTick','off');
    set(gca,'XGrid','off','YGrid','off');
    set(gca,'XColor',[.3 .3 .3],'YColor',[.3 .3 .3]);
    set(gca,'FontName','Helvetica');
    set(gca,'FontSize',18);
    box on
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
    
    % Set labels and title
    xlabel(graphobj.xlab, 'FontSize', 20, 'FontName', 'Helvetica');
    ylabel(graphobj.ylab, 'FontSize', 20, 'FontName', 'Helvetica');
    
    % Set legend
        %leg = legend([fh1; fh2; fh3; fh4]);
    legend([fh1; fh2; fh3; fh4], 'Location', 'northeast', 'FontSize', 16);

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

    % Save the plot if required
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