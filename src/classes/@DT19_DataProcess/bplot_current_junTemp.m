function bplot_current_junTemp(obj, plt_current)
% This function make the bar plot of the junction temperature vs. current
    fld_names = fieldnames(obj.LIV_data);
    cond_num = length(fld_names); % This is the test condition number
    plt_current_ind = find(obj.current == plt_current); % This is the index of current for selecting the junction temperature
    
    if isempty(plt_current_ind)
        error('Please match plt_current with one of the test current');
    end
    
    % Find the total device number
    temp = obj.LIV_data.(fld_names{1});
    temp_var1 = ~isnan(temp.Var1);
    dev_num = length(find(temp_var1 == 1)); % This finds how many test devices
    
    % Create a junction temperature matix based on the test condition and
    % device number
    jun_temp = zeros(cond_num, dev_num); 

    fig_hd = figure('Name', ['JunTemp vs. Current@', num2str(plt_current)],...
        'Position', [1987 45 1031 773]); %#ok<NASGU>
  
    % Extract all the junction temperature data at selected current value.
    for i = 1:cond_num
        tb_data = obj.LIV_data.(fld_names{i});
        jun_temp(i,:) = tb_data{5:end, obj.ind(8) + plt_current_ind -1};
    end
    % Extract all the legend information
    for j = 1:dev_num
        leg{j} = ['@', num2str(plt_current), '[A]_',...
            num2str(tb_data{4+j, 'Var2'}), '_', 'DT19'];  %#ok<AGROW>
    end
    bar(jun_temp);% Make the bar plot
    set(gca, 'FontSize', 16, 'TickLabelInterpreter', 'none');
    legend(leg{:}, 'box','off', 'interpreter', 'none', 'location', 'northoutside', ...
        'NumColumns', 2);
    xticklabels(fld_names);
    xlabel('Flow Rate[lpm]');
    ylabel('Junc Temp[^oC]');
end