function add_box_plot(obj, parameter, current) 
    % This function add box plot for all different cooler types: 
    % Plot two flow rate next to each other for comparison, in subplot
    % diagram.
    % From left to right will be standard cooler, 300um AlN cooler, 200um channel cooler and 6mm fin cooler;
    % Parameter will be one of the following for comparsion 
    % P = {'I', 'P', 'V', 'Centroid', 'FW90', 'P_dissip', 'Chirp_nm',
    % 'R_th', 'T_junct', 'Effic', 'Slope'};
    % Current should be the following value for comparison
    % I = [30:480, 500];
    
    %% Constant
    %mn_fld = 'D:\Trumpf_R&D\RD_TestData\test_folder\20191101_DT19_DataAnalysis\E16.9_4mm_Bar'; % Requires modification
    mn_fld = obj.fld_add;
    sub_flds = {'std_cooler', 'c300um_AlN', 'c200um_channel', 'c6mm_fin'};
    flow_flds = {'_1.1lpm', '_1.4lpm'};
    var_parameter = {'I', 'P', 'V', 'Centroid', 'FW90', 'P_dissip', 'Chirp_nm','R_th', 'T_junct', 'Effic', 'Slope'};
    y_label = {'Current[A]', 'Power[W]', 'Voltage[V]', 'Centroid[nm]', 'FW90[nm]','P Dissp[W]', ...
        'Chirp[nm]', 'Thermal Res[K/W]', 'Junction Temp[^oC]', 'Efficiency[%]', 'Slope'};
    I = [30:30:480, 500];
    % Extract the variable number
    var_ind = find(strcmpi(var_parameter, parameter));
    row_ind = I == current;
    %% Read out the data for plotting
    for i = 1:numel(sub_flds)
        for j = 1:numel(flow_flds)
           file_fld = fullfile(mn_fld, sub_flds{i}, flow_flds{j});
           files = ls(file_fld);
           for k = 3:size(files,1)
               % Crate an object and read out the data
               temp_obj = DT19_LIV_Raw(fullfile(file_fld, strip(files(k, :))));
               temp_data = temp_obj.LIV_data.LIV;
               data_point = temp_data{row_ind, var_ind};
               try
                data_out(k-2, (i-1)*numel(flow_flds) + j) = data_point;
               catch Ex
                   disp(Ex.message);
               end
           end
        end
    end

% Process the data_out information and replace 0 to nan
data_out(data_out == 0) = nan;
%% Now with the data_out information, generate the boxplot
figure('Position', [1987 0 1173 903]);
h_ax = subplot(2,1,1);
h = iosr.statistics.boxPlot(data_out,...
                  'symbolColor','k',...
                  'medianColor','k', 'showScatter', true, ...
                  'scatterColor', 'r', 'scatterMarker', {'.'}, ...
                  'scatterSize', 200);
set(gca, 'FontSize', 16);
ylabel(y_label{var_ind});
if var_ind == 10
    h_ax.YTickLabel = cellfun(@num2str, num2cell(h_ax.YTick*100), 'UniformOutput', false);        
end
set(h_ax, 'XTick', 1:2:2*numel(sub_flds),'XTickLabel', sub_flds, 'TickLabelInterpreter', 'none', 'XGrid', 'off', 'XMinorGrid', 'off', ...
    'YGrid', 'on', 'YMinorGrid', 'on');
title(['Measurement @', num2str(current), 'A']);
%% Create another axis to label the plot
h_ax_btm = subplot(2,1,2);
set(h_ax_btm, 'Position',[0.1300, 0.1100, 0.7750, 0.0938], 'XLim', [0, 2*numel(sub_flds)], 'YLim', [0,1], ...
    'XTick', [], 'YTick', [], 'box', 'on');
text(1:2:2*numel(sub_flds)-0.5, ones(1,length(1:2:2*numel(sub_flds)))*0.75, sub_flds, 'FontSize', 14, 'FontWeight', 'b', 'Interpreter','none');
flw_label = {'1.1lpm', '1.4lpm','1.1lpm', '1.4lpm','1.1lpm', '1.4lpm','1.1lpm', '1.4lpm'};
text(1:1:2*numel(sub_flds), ones(1,length(1:1:2*numel(sub_flds)))*0.25, flw_label, 'FontSize', 14);
% make the grid plot
line([0,9], [0.5, 0.5], 'LineWidth', 0.8, 'Color', 'k');
%% Set the position of the two plots
h_ax.Position = [0.1300, 0.2492, 0.7750, 0.6758];
h_ax.XLim = [0,9];
h_ax_btm.XLim = [0,9];
h_ax.XTickLabel = [];
h_ax.Box = 'on';
end     