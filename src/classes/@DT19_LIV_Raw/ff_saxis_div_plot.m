function ff_saxis_div_plot(obj)
    % This function make the far field slow axis full divergence plot.
    % The template address is
    % '\\srv23data6\departmental\PT_Projects\DT19\57_Testing\TestingData\20191031_DM17_HigherFlowRate_E15p4_4mm_SpeCooler\FF_SAxis_Div'.
    % The template file name is 'FF_SAxis_Div_Template';
    % The function is using confidental plot.
    
    %% Open the file location    
    fld = fullfile(obj.fld_add, 'FF_SAxis_Div');
    [file, path] = uigetfile([fld,'\*.xlsx'], 'Select FF SAxis Divergence Angle Data File');
    file_add = fullfile(path, file);
    current = 50:50:500;
    current_len = numel(current);
    order_num = 3;
    dev_num = 4;
    color = linspecer(order_num);
    leg1p1 = {'1.1lpm-300\mum AlN', '1.1lpm-200\mum Channel', '1.1lpm-6mm Fin'};
    leg1p4 = {'1.4lpm-300\mum AlN', '1.4lpm-200\mum Channel', '1.4lpm-6mm Fin'};
    %% Load in the data file
    data_type = cell(1,order_num*dev_num);
    data_type(:) = {'double'};
    opts_summary = spreadsheetImportOptions('NumVariables', order_num*dev_num);
    opts_summary.Sheet = 1;
    data_range_s = input('Please input the data range: ex A1:C2\n', 's');
    opts_summary.DataRange = data_range_s;
    opts_summary.VariableTypes = data_type;
    divg_data = readtable(file_add, opts_summary);    
    %% Separate table into sub-table with different test conditions
    divg_1p1 = divg_data{1:current_len, :};
    divg_1p4 = divg_data{(current_len+1):end, :};
    % with device number, calculate the average, min and max value for 1p1
    % and 1p4 lpm of different cooler type
    % 1.1lpm condition
    figure;
    for i = 1:order_num
        temp_data = divg_1p1(:, (dev_num*(i-1)+1): (dev_num*i));
        % Remove the nan value from the matrix and reshpae the matrix
        temp_data(isnan(temp_data)) = [];
        temp_data = reshape(temp_data, numel(current), []);
        %
        temp_data_mean = mean(temp_data,2);
        temp_data_min = min(temp_data, [], 2); 
        temp_data_max = max(temp_data, [], 2);
        % generate confidental plot.
        plot_ci(current,[temp_data_mean temp_data_min temp_data_max], 'PatchColor', color(:,i), 'PatchAlpha', 0.2, ...
          'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', color(:,i), ...
          'LineStyle','none');
        hold on;
    end
    hold off;
    set(gcf,'Position', [1987 0 1173 903], 'Name', '1.1lpm FF SAxis Full Div angle'); 
    set(gca, 'FontSize', 16);
    xlabel('Current[A]');
    ylabel('FF SAxis Full Div Angle [deg]');
    grid on; grid minor;
    % Process the legend
    ln_obj = findobj(gca, 'Type', 'line', 'LineStyle', '-');
    ln_obj = ln_obj(end:-1:1);
    legend(ln_obj,leg1p1, 'box', 'off', 'Location', 'northoutside', 'NumColumns', order_num);
    % 1.4lpm condition
    figure;
    for j = 1:order_num
        temp_data = divg_1p4(:, (dev_num*(j-1)+1): (dev_num*j));
        % Remove the nan value from the matrix and reshpae the matrix
        temp_data(isnan(temp_data)) = [];
        temp_data = reshape(temp_data, numel(current), []);
        %
        temp_data_mean = mean(temp_data,2);
        temp_data_min = min(temp_data, [], 2); 
        temp_data_max = max(temp_data, [], 2);
        % generate confidental plot.
        plot_ci(current,[temp_data_mean temp_data_min temp_data_max], 'PatchColor', color(:,j), 'PatchAlpha', 0.2, ...
          'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', color(:,j), ...
          'LineStyle','none');
        hold on;
    end
    hold off;
    set(gcf,'Position', [1987 0 1173 903], 'Name', '1.4lpm FF SAxis Full Div angle'); 
    set(gca, 'FontSize', 16);
    xlabel('Current[A]');
    ylabel('FF SAxis Full Div Angle [deg]');
    grid on; grid minor;
    % Process the legend
    ln_obj = findobj(gca, 'Type', 'line', 'LineStyle', '-');
    ln_obj = ln_obj(end:-1:1);
    legend(ln_obj,leg1p4, 'box', 'off', 'Location', 'northoutside', 'NumColumns', order_num);
    % Process the legend
end