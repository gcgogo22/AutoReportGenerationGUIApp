function scatter_press_plot(obj)
 % This function makes the scatter plot with pressure in bar and power
 % information in colorbar.
 
 %% Open the file location
 %fld = 'D:\Trumpf_R&D\RD_TestData\test_folder\20191101_DT19_DataAnalysis\E16.9_4mm_Bar\Flow_rate';
 fld = obj.fld_add;
 [file, path] = uigetfile([fld,'\*.xlsx'], 'Select Flow Rate Data File');
 file_add = fullfile(path, file);
 current = [30:30:480, 500];
 psi_to_bar = 14.5038;
 %% Load in the data file
 data_type = cell(1,16); 
 data_type(:) = {'double'};
 opts_summary = spreadsheetImportOptions('NumVariables', 16);
 opts_summary.Sheet = 1;
 data_range_s = input('Please input the data range: ex A1:C2\n', 's');
 opts_summary.DataRange = data_range_s;
 opts_summary.VariableTypes = data_type;
 flw_rate_data = readtable(file_add, opts_summary);
 %% Extract the data and generate the plot
 % Assign all 1.1lpm flow rate power and pressure
 pw_1p1 = flw_rate_data{:, 1:4:16};
 pw_1p1_avg = mean(pw_1p1, 2);
 pre_1p1 = flw_rate_data{:, 2:4:16}/psi_to_bar;
 pre_1p1_avg = mean(pre_1p1, 2);
 % Assign all 1.4lpm flow rate power and pressure
 pw_1p4 = flw_rate_data{:, 3:4:16};
 pw_1p4_avg = mean(pw_1p4, 2);
 pre_1p4 = flw_rate_data{:, 4:4:16}/psi_to_bar;
 pre_1p4_avg = mean(pre_1p4, 2);
 %% Make the scattering plot
 h_fig = figure('Position', [1987 0 1173 903], 'Name', 'Flw Scattering Plot');
 h1_sca = scatter(current, pre_1p1_avg, 60, pw_1p1_avg, 'filled', 'o'); % scatter plot of the 1p1 pressure
 hold on;
 plot(current, pre_1p1_avg, 'k--', 'linewidth', 1.5, 'DisplayName', '1.1lpm');
 h2_sca = scatter(current, pre_1p4_avg, 60, pw_1p4_avg, 'filled', 'd'); % scatter plot of the 1p4 pressure
 plot(current, pre_1p4_avg, 'k-', 'linewidth', 1.5, 'DisplayName', '1.4lpm');
 hold off;
 
 set(gca,'FontSize', 16);
 xlabel('Current[A]');
 ylabel('Pressure Drop[Bar]');
 colormap(jet);
 colorbar;
 legend([h1_sca, h2_sca], {'1.1lpm', '1.4lpm'}); 
 legend boxoff;
end