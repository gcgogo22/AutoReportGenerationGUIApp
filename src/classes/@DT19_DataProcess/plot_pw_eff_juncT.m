function plot_pw_eff_juncT(obj)
    % This prepares for the coming meeting with TLS by averaging out all
    % the test devices at different flow rates with error bar.
    % It also plots double axes to show both the efficiency and junction temperateure. 
    current = [obj.current, 500];
    flow_cond = {'1.1[lpm]', '1.2[lpm]', '1.3[lpm]', '1.4[lpm]'};
    h_fig = figure('Name', 'PW Eff and JunT Plot', 'Position', [2129 15 1169 887], 'Color', 'w'); % Create a figure container for plotting
    % Define the additional 500A data. Row -> ilasco SN, Col: power, junction Temp, efficiency in 100%
    % Each page define the different flow rate
    data_500(:,:,1) = [439.3 116.1 48.6; 433 116.8 48; 446 113.6 49.6; 438.4 115.5 49];
    data_500(:,:,2) = [449.4 112.2 49.5; 444.4 113.5 49.2; 455.8 109.3 50.7; 447.8 112.8 50];
    data_500(:,:,3) = [454.9 111.3 50.1; 449.5 112.0 49.7; 460.6 107.9 51.2; 453.0 110.6 50.6];
    data_500(:,:,4) = [460.8 108.3 50.7; 453.9 110.2 50.1; 465.1 105.9 51.6; 458.0 108.9 51.1];
    % Added data ended

    test_cond = fieldnames(obj.LIV_data); % Extract all the fieldnames of test conditions of LIV_data.    
    len = length(test_cond);
    % Create color vector
    color = linspecer(len);
    
    for i = 1:len
        temp_data_tb = obj.LIV_data.(test_cond{i}); % Extract the table at different flow rate.
        temp.power = temp_data_tb{5:8, 10:25};
        temp.junT = temp_data_tb{5:8, 143:158}; % Extract the junction temperature
        temp.eff = temp_data_tb{5:8, 162:177}*100; % Extract the junction temperature
        % Add 500A data to each test condition.
        temp = add_500A(temp, data_500(:,:,i));
        % Call err_bar avergae function to calculate the mean value and
        % min and max for errorbar range
        temp_err = err_bar_val(temp);
        % Plot the data in the figure;
        [ax_pw, ax_eff, ax_junT] = plot_data(h_fig, temp_err, current, flow_cond, color, i);
    end
    axes(ax_pw); grid on; grid minor;
    % Turn on the legend
    legend('box', 'off', 'Position', [0.1528 0.7878 0.1095 0.1280]);
    axes(ax_eff); grid on; grid minor;
    axes(ax_junT); grid on; grid minor;
end

function temp_out = add_500A(temp_in, add_data)
    % This function receive temp_in structure and input add_data matrix 
    % It will operate to add the additional 500A data - power, junT and eff
    % to each matrix in the field.
    temp_in.power = [temp_in.power, add_data(:,1)];
    temp_in.junT = [temp_in.junT, add_data(:,2)];
    temp_in.eff = [temp_in.eff, add_data(:,3)];
    
    temp_out = temp_in; % Return the added value.
end

function temp_err = err_bar_val(temp)
    % This function receive a structure data and calculat the mean and std
    % of each matrix in the fieldname
    temp.power_mean = mean(temp.power);
    temp.power_min = temp.power_mean - min(temp.power);
    temp.power_max = max(temp.power) - temp.power_mean;
    
    temp.junT_mean = mean(temp.junT);
    temp.junT_min = temp.junT_mean - min(temp.junT);
    temp.junT_max = max(temp.junT) - temp.junT_mean;
    
    temp.eff_mean = mean(temp.eff);
    temp.eff_min = temp.eff_mean - min(temp.eff);
    temp.eff_max = max(temp.eff) - temp.eff_mean;
    
    % return the error bar required value
    temp_err = temp;
end

function [ax_pw, ax_eff, ax_junT] = plot_data(h_fig, temp_err, current, flow_cond, color, i)
    % This function create a 3x1 subplots and plot the power, efficiency
    % and junction temperature
    temp_err = fil_data(temp_err);
    figure(h_fig);
    % Plot power
    ax_pw = subplot(3,1,1,'FontSize', 18, 'XColor', 'none', 'XtickLabel', {});
    hold on;
    errorbar(current, temp_err.power_mean, temp_err.power_min, temp_err.power_max, 'linewidth', 3, ...
        'color', color(i,:), 'DisplayName', flow_cond{i});
    ylb_pw = ylabel('Power[W]');
    ylb_pw.Position(2) = 300;
    hold off;
    
    
    % Plot efficiency
    ax_eff = subplot(3,1,2,'FontSize', 18, 'XColor', 'none', 'XtickLabel', {});
    
    hold on;
    errorbar(current, temp_err.eff_mean, temp_err.eff_min, temp_err.eff_max, 'linewidth', 3, ...
        'color', color(i,:), 'DisplayName', flow_cond{i});
    ylb_eff = ylabel('Efficiency[%]');
    ylb_eff.Position(1) = ylb_pw.Position(1);
    ylb_eff.Position(2) = 40;
    hold off;
    
    % Plot junction temperature
    ax_junT = subplot(3,1,3,'FontSize', 18);
    
    hold on;
    errorbar(current, temp_err.junT_mean, temp_err.junT_min, temp_err.junT_max, 'linewidth', 3, ...
        'color', color(i,:), 'DisplayName', flow_cond{i});
    ylb_junT = ylabel('Junction Temperature[^oC]');
    ylb_junT.Position(1) = ylb_pw.Position(1);
    xlabel('Current[A]');
    hold off;
    
    
    % Set axes limit
    set(ax_pw, 'YLim', [0, 500], 'YTick', 0:100:500);
    set(ax_eff, 'YLim', [0, 70], 'YTick', 0:10:70);
    set(ax_junT, 'YLim', [30, 130], 'YTick', 30:20:130);
end

function data = fil_data(data)
    % This function filter the structure data and make sure all the data in
    % each field is >0
    fl_names = fieldnames(data);
    len = length(fl_names);
    for i = 1:len
        temp_data = data.(fl_names{i});
        temp_data(temp_data<0) = 0;
        data.(fl_names{i}) = temp_data;
    end
end