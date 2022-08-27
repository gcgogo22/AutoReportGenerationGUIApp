function last_avg_power(obj, ax_hd)
    % When this function is called, it will check the active lines in the
    % current axis, extract the last data points of all the active lines
    % and calcualte the end hour avg normalized power
    
    ln_objs = findobj(ax_hd, 'Type', 'Line', 'LineStyle', '-', 'Visible', 'on');
    normal_power = get(ln_objs, 'YData');
    
    if iscell(normal_power)
        len = numel(normal_power);
    else
        len = 1;
    end
    
    if len >1
        for i = 1:len
            end_norl_pw(i) = normal_power{i}(end); %#ok<AGROW>
            % Also calculate the total running hours
            hr_len(i) = length(normal_power{i})*0.5; %#ok<AGROW> % power meter hr step is 0.5hr
        end
    else
            end_norl_pw = normal_power(end);
            hr_len = length(normal_power)*0.5;
    end
    end_avg_pw = mean(end_norl_pw);  
    % Show the calculate end average normalized power on the axis
    txt_x_pos = ax_hd.XLim(1) + 0.1*(ax_hd.XLim(2) - ax_hd.XLim(1));
    txt_y_pos = ax_hd.YLim(1) + 0.1*(ax_hd.YLim(2) - ax_hd.YLim(1));
    text(ax_hd, txt_x_pos, txt_y_pos, ['Active End-Hr Norm-Avg-Power: ', num2str(end_avg_pw, 2)],...
        'FontSize', 15);
    % Calculate the total running hours. If hr_len >1, calculate the min
    % and max hrs and compare
    if min(hr_len) == max(hr_len)
        text(ax_hd, txt_x_pos, txt_y_pos + 0.3, ['Active End-Hr: ', sprintf('%0.1f', min(hr_len))], 'FontSize', 15);
    else
        text(ax_hd, txt_x_pos, txt_y_pos + 0.3, {['Active End-Hr Max: ', sprintf('%d', max(hr_len))], ...
            ['Active End-Hr Min: ', sprintf('%d', min(hr_len))]}, 'FontSize', 15);
    end
end