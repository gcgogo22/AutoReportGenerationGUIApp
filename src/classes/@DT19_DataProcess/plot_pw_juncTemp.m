function plot_pw_juncTemp(obj)
    %This function plot the power and junction temperature combination.
    fld_names = fieldnames(obj.LIV_data);
    cond_num = length(fld_names); % This is the test condition number
    colors = linspecer(cond_num); % This define different colors for test condition

    temp = obj.LIV_data.(fld_names{1});
    temp_var1 = ~isnan(temp.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    fig_hd = figure('Name', 'Power & JuncTemp vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
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
            pw_data = tb_data{4+j, obj.ind(1):1:obj.ind(1)+ length(obj.current)-1};
            juncTemp_data = (tb_data{4+j,obj.ind(8):1:obj.ind(8)+ length(obj.current)-1}); % This extract the junction temperature
            yyaxis left;
            plot(obj.current, pw_data, 'DisplayName', leg, 'Color', colors(i, :), 'Marker', marker, 'MarkerSize', 10, ...
                'LineWidth', 2, 'LineStyle', '-');
            yyaxis right;
            plot(obj.current, juncTemp_data, 'LineStyle', '-.', 'Color', colors(i, :), 'Marker', marker, 'MarkerSize', 10, ...
                'LineWidth', 2, 'DisplayName', '');
        end 
    end
    hold off; 
    set(gca, 'FontSize', 16, 'YColor', 'k');
    hleg = legend('box','off', 'interpreter', 'none');
    % Delete the efficiency legend;
    leg_num = numel(hleg.String)/2;
    hleg.String(leg_num+1:end) = [];
    %
    xlabel('Current[A]');
    yyaxis left;
    set(gca, 'YColor', 'k');
    ylabel('Power[W]');
    ylim([0 500]);
    yyaxis right;
    ylabel('Junction Temp[^oC]');
    ylim([30 150]);
    grid on; grid minor;
end