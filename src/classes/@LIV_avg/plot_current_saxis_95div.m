function plot_current_saxis_95div(file_name, leg)
    % file_name is the full file location.
    opts = detectImportOptions(file_name, 'FileType', 'text'); ...
        % using detectImportOptions is very convenient. It automaticlly detect the input file type
    data = readtable(file_name, opts);
    current = data.Curr;
    FF95 = data.FF95_;
    
    % Generate the plots.
    fig_hd = figure('Name', 'SAxis vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
   
    % Plot the data   
    plot(current, FF95, 'DisplayName', leg, 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 12);            

    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('95% SAxis Full Div[deg]');
    grid on; grid minor;
end

