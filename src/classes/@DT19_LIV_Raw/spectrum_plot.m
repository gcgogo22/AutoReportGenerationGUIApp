function spectrum_plot(obj)
    % This function makes the spectrum plot at 500A for all files in the
    % folder.
    
    %% Extract data from specific folder
    fld = uigetdir('D:\Trumpf_R&D\RD_TestData\test_folder\', 'Select the test folder');
    fl_name = ls([fld, '\*.xlsx']);
    % Create spreadsheet readin option
    opts_summary = spreadsheetImportOptions;
    opts_summary.Sheet = 'Spectrum';
    % Acquire the data in 3-D matrix
    for i = 1:size(fl_name,1)
        fl_name_full = fullfile(fld, strip(fl_name(i,:)));
        opts_summary.DataRange = 'A4:A3635';
        opts_summary.VariableTypes = {'double'};
        dt_wv = readtable(fl_name_full, opts_summary); % Read in the wavelength data
        opts_summary.DataRange = 'AP4:AP3635';
        dt_nor = readtable(fl_name_full, opts_summary); % Read in the normalized value data
        data_mat(:,:,i) =  [dt_wv.Var1, dt_nor.Var1];
    end
    % Calculate the mean, min and max value
    data_mean = mean(data_mat,3);
    data_min = min(data_mat(:,2,:),[], 3);
    data_max = max(data_mat(:,2,:),[], 3);
    % Generate the bar plot
    figure('Position', [1987 0 1173 903], 'Name', 'Spectrum plot');
    % Using confident plot to generate the plots.
    x = data_mean(:,1); % Wavelength mean value
    y1 = data_mean(:,2); % Normalized value
    y2 = data_min; % min values.
    y3 = data_max; % max values.
    % Generate confident plot 
    plot_ci(x,[y1 y2 y3], 'PatchColor', 'r', 'PatchAlpha', 0.2, ...
          'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', 'b', ...
          'LineStyle','none');
    % Set axis
    ax = gca;
    set(ax, 'FontSize', 16); grid on; grid minor;
    xlabel('Wavelength[nm]');
    ylabel('Norm Intensity[a.u.]');
    legend(ax.Children(3), 'Spectrum', 'box', 'off');
    axis tight;
end