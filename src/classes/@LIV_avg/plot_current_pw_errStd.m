function plot_current_pw_errStd(obj)
    % This function plot the power vs. current
    % The power data is mean value with standard deviation errorbar
    
    data = obj.avg_data;
    
    % calculate the number of devices
    temp_var1 = ~isnan(data.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices 

    % extract the pw matrix, mean and std values
    pw_mat = data{5:(5+dev_num-1), obj.ind(1):(obj.ind(1) + numel(obj.current) -1)};
    % filter out the failed LIV devices.
    ind_fail_rw = find(isnan(pw_mat(:,1))); % find out the row number when LIV failed test.
    pw_mat(ind_fail_rw, :) = []; %#ok<FNDSB> % delete the row value where LIV failed.
    % calcualte the mean value and std deviation
    pw_avg = mean(pw_mat,1);
    pw_std = std(pw_mat);
    
    fig_hd = figure('Name', 'Power vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    
    % generate the plots
    leg = obj.test_order;
    % Plot the data   
    errorbar(obj.current, pw_avg, pw_std, 'DisplayName', leg, 'LineWidth', 1.5);            

    set(gca, 'FontSize', 16);
    legend('box','off', 'interpreter', 'none');
    xlabel('Current[A]');
    ylabel('Power[W]');
    grid on; grid minor;
end