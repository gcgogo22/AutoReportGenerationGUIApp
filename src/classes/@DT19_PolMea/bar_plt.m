function bar_plt(obj) %#ok<INUSD>
    % This bar plot function can be called to generate subplots of bar vs. test current
    % at different flow rate
    fld_name = {'E15p4_pol.flw_1p1', 'E15p4_pol.flw_1p4', ...
        'E16p9_pol.flw_1p1','E16p9_pol.flw_1p4'};
    m = 2; 
    n = 2;
    % Make subplot
    h_fig = figure('Name', 'Polarization', 'Position', [2025 64 1653 926]);
    for i = 1:m*n
        data = eval(['obj.', fld_name{i}]);
        sub_plt(data, subplot(m,n,i));
    end
    % Generate the plot titles
    tl= {'E15.4@1.1lpm', 'E15.4@1.4lpm', 'E16.9@1.1lpm', 'E16.9@1.4lpm'};
    ax = findobj(gcf, 'Type', 'axes');
    ax = ax(end:-1:1);
    bar_num = zeros(1,numel(ax)); % used to record the maximum number of bar array
    for j = 1:numel(ax)
        title(ax(j), tl{j});
        bar_num(j) = numel(findobj(ax(j), 'Type', 'bar'));
    end
    bar_num_max = max(bar_num);
    % Use maximum bar number to generate colormap
    color_map = summer(bar_num_max); % set up the cooler bar
    for k1 = 1:numel(ax)
        h_bar = findobj(ax(k1), 'Type', 'bar');
        for k2 = 1:numel(h_bar)
            set(h_bar(k2), 'FaceColor', color_map(k2, :));
        end
    end
end

function sub_plt(data, ax)
    fld_name = fieldnames(data);
    temp = struct2cell(data);
    temp_data = cell2mat(temp(2:end)'); % generate polarization matrix
    current = temp{1};
    bar(ax, current, temp_data);
    h_leg = legend(fld_name(2:end), 'box', 'off', 'interpreter', 'none', 'location', 'eastoutside');
    set(gca, 'FontSize', 12);
    xlabel('Current[A]');
    ylabel('DOP[%]');
    ylim([80, 96]);
    yticks(80:2:96);
    
    % Add the baseline of DM17 into the figure
    dm17_mean = 85.97857;
    dm17_min = 83.7;
    dm17_max = 90.1;
     
    hold on; 
    line([50, 700],[dm17_mean, dm17_mean], 'linestyle', '-', 'linewidth', 1.5, 'color', 'k');
    line([50, 700],[dm17_min, dm17_min], 'linestyle', '-.', 'linewidth', 1.5, 'color', 'k');
    line([50, 700],[dm17_max, dm17_max], 'linestyle', '-.', 'linewidth', 1.5, 'color', 'k');
    hold off;
    xlim([50, 600]);
    
    % remove the leg from data1
    temp = h_leg.String;
    fcn = @(x) contains(x, 'data1');
    ind = find(cellfun(fcn, temp));
    h_leg.String(ind:end) = [];
end