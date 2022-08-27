function ex_data_lin(obj, Y_label, i)
    % This add the extracted data as line into the plots
    % Please input Y_label with unit.
    % i is the group number in the FlwData_ex property, which defines which
    % type data you want to plot, ex. power, efficiency, junction temp,
    % thermal resistance or slope rate
    
    %% Set data range to read in
    ind = (1:4) + (i-1)*4;
    flw_data = obj.FlwData_ex;
    %% Check if there is any ax open if not create one
    ax_hd = findobj(0, 'Type', 'axes');
    if isempty(ax_hd)
        ax_hd = axes('XTick', obj.current, ...
            'FontSize',14);
        fig_hd = gcf;
        fig_hd.Position = [1987 0 1173 903];
    end
    axes(ax_hd); % make the axes current selection
    xlabel('Current[A]');
    ylabel(Y_label);
    
    %% Extract the legend for the confident plot
    leg1 = fieldnames(flw_data);
    leg1 = leg1(ind);
    leg2 = {'f1p1', 'f1p4'};
    color = colormap(jet(numel(leg1)*numel(leg2)));
    %% Extract the data and make the confident plot
    hold on;
    leg = cell(size(1,numel(leg1)*numel(leg2)));
    count =1;
    for i = 1:numel(leg1)
        for j = 1:numel(leg2)
            leg{count} = [leg1{i}, ' ', leg2{j}];
            temp_data = flw_data.(leg1{i}).(leg2{j});
            % Check if this is the efficiency plot
            if strcmpi(Y_label, 'Efficiency[%]')
                temp_data = temp_data*100;
            end
            errorbar(obj.current, temp_data(:,1), temp_data(:,1) - temp_data(:,2), temp_data(:,3) - temp_data(:,1), ...
                'LineWidth', 2, ...
                'Color', color(count,:));
            count = count + 1;
        end
    end
    hold off;
    grid on; grid minor;
    legend(leg, 'box', 'off', 'Interpreter', 'none', 'Location', 'northoutside', 'NumColumns', 4);
    h_ax = gca; h_ax.YLim(1) = 0;
end