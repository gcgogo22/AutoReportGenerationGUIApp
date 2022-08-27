function plot_current_junT(obj)
    % This function plot the power vs. current
    
    temp = obj.avg_data;
    temp_var1 = ~isnan(temp.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    % calculate how many colors to generate
    marker_len = length(obj.marker_shape);
    cond_num = ceil(dev_num/marker_len); % how many colors to use in the plot
    colors = linspecer(cond_num); % This define different colors for test condition
    
    fig_hd = figure('Name', 'JuncT vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    hold on;
    
   
    counter = 0; % color counter
    for j = 1: dev_num
            if rem(j, marker_len) == 1
                counter = counter + 1;
            end
            % assign the marker 
            if rem(j, marker_len) ~= 0
                marker = obj.marker_shape{rem(j,marker_len)}; % Reiterate if more test devices than markert num
            else
                marker = obj.marker_shape{end};
            end
            
            % assign the color
            cl = colors(counter,:);
         
            % Extract the legend
            item1_sn = num2str(obj.avg_data.Var2(4+j)); % Extract the device serial number
            item2_wo = obj.avg_data.Var3{4+j}; % Extract the work order number
            item3_test_cond = 'flw_2.2lpm';
            
            leg = [item3_test_cond, '_', item1_sn, '_', item2_wo];
            % Plot the data
            tb_data = obj.avg_data;
            junT_data = tb_data{4+j, obj.ind(end-1):1:obj.ind(end-1)+ length(obj.current)-1};
            plot(obj.current, junT_data, 'DisplayName', leg, 'Color', cl, 'Marker', marker, 'MarkerSize', 6, ...
                'LineWidth', 1.5);            
    end
    
    
    
    hold off; 
    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('JuncT[^oC]');
    grid on; grid minor;
end