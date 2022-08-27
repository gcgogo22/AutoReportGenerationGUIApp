function plot_current_junTemp(obj)
% This function plot the junction temperature vs. current
    fld_names = fieldnames(obj.LIV_data);
    cond_num = length(fld_names); % This is the test condition number
    colors = linspecer(cond_num); % This define different colors for test condition

    temp = obj.LIV_data.(fld_names{1});
    temp_var1 = ~isnan(temp.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    fig_hd = figure('Name', 'JunTemp vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    hold on;
    for i = 1:cond_num
        for j = 1:dev_num
            if dev_num > length(obj.marker_shape)
                marker = obj.marker_shape{rem(dev_num, numel(obj.marker_shape))}; % Reiterate if more test devices than markert num
            else
                marker = obj.marker_shape{j};
            end
            
            % Extract the legend
            item1_sn = num2str(obj.LIV_data.(fld_names{i}).Var2(4+j)); % Extract the device serial number
            item2_wo = obj.LIV_data.(fld_names{i}).Var3{4+j}; % Extract the work order number
            item3_test_cond = fld_names{i};
            
            leg = [item3_test_cond, '_', item1_sn, '_', item2_wo];
            % Plot the data
            tb_data = obj.LIV_data.(fld_names{i});
            junTemp_data = tb_data{4+j, obj.ind(8):1:obj.ind(8)+ length(obj.current)-1};
            plot(obj.current, junTemp_data, 'DisplayName', leg, 'Color', colors(i, :), 'Marker', marker, 'MarkerSize', 10, ...
                'LineWidth', 2);            
        end 
    end
    hold off; 
    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('Junc Temp[^oC]');
    grid on; grid minor;
end