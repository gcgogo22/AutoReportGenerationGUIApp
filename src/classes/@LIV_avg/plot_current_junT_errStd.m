function plot_current_junT_errStd(obj)
    % This function plot the power vs. current
    % The power data is mean value with standard deviation errorbar
    
    data = obj.avg_data;
    
    % calculate the number of devices
    temp_var1 = ~isnan(data.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    % extract the pw matrix, mean and std values
    junT_mat = data{5:(5+dev_num-1), obj.ind(end-1):(obj.ind(end-1) + numel(obj.current) -1)};
    % filter out the failed LIV devices.
    ind_fail_rw = find(isnan(junT_mat(:,1))); % find out the row number when LIV failed test.
    junT_mat(ind_fail_rw, :) = []; %#ok<FNDSB> % delete the row value where LIV failed.
    % calcualte the mean value and std deviation
    junT_avg = mean(junT_mat,1);
    junT_std = std(junT_mat);
    
    fig_hd = figure('Name', 'junT vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    
    % generate the plots
    leg = obj.test_order;
    % Plot the data   
    errorbar(obj.current, junT_avg, junT_std, 'DisplayName', leg, 'LineWidth', 1.5);            

    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('T_j[^oC]');
    grid on; grid minor;
end