function plot_current_vol_errStd(obj)
    % This function plot the power vs. current
    % The power data is mean value with standard deviation errorbar
    
    data = obj.avg_data;
    
    % calculate the number of devices
    temp_var1 = ~isnan(data.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    % extract the pw matrix, mean and std values
    vol_mat = data{5:(5+dev_num-1), obj.ind(2):(obj.ind(2) + numel(obj.current) -1)};
    % filter out the failed LIV devices.
    ind_fail_rw = find(isnan(vol_mat(:,1))); % find out the row number when LIV failed test.
    vol_mat(ind_fail_rw, :) = []; %#ok<FNDSB> % delete the row value where LIV failed.
    % calcualte the mean value and std deviation
    vol_avg = mean(vol_mat,1);
    vol_std = std(vol_mat);
    
    fig_hd = figure('Name', 'Vol vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    
    % generate the plots
    leg = obj.test_order;
    % Plot the data   
    errorbar(obj.current, vol_avg, vol_std, 'DisplayName', leg, 'LineWidth', 1.5);            

    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('Voltage[V]');
    grid on; grid minor;
end