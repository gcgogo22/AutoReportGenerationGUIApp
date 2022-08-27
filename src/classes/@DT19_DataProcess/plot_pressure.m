function plot_pressure(obj)
    %This function plot the pressure data saved in the obj
    color = linspecer((size(obj.pressure, 2)-1)/2);
    loop_num = size(color, 1);
    
    current = obj.pressure.Var1';
    pre_diff_1p1 = obj.pressure.Var3;
    pre_diff_1p2 = obj.pressure.Var5;
    pre_diff_1p3 = obj.pressure.Var7;
    pre_diff_1p4 = obj.pressure.Var9;
    pre_diff_1p6 = obj.pressure.Var11;
    pre_diff_1p8 = obj.pressure.Var13;
    
    pressure = -[pre_diff_1p1'; pre_diff_1p2'; pre_diff_1p3'; pre_diff_1p4'; pre_diff_1p6'; pre_diff_1p8'];
    pressure_dipNm = {'cnd_1.1 lpm', 'cnd_1.2 lpm', 'cnd_1.3 lpm', 'cnd_1.4 lpm', 'cnd_1.6 lpm', 'cnd_1.8 lpm'};
    
    fig_hd = figure('Name', 'Pressure vs. Current', 'Position', [1987 45 1031 773]); %#ok<NASGU>
    hold on;
    for i = 1:loop_num
       plot(current, pressure(i,:), 'LineWidth', 2, 'DisplayName', pressure_dipNm{i}, 'color', color(i,:));
       % Plot the average value
       plot(current, repmat(mean(pressure(i,:)), size(current)), 'LineWidth', 2, ...
           'DisplayName', [pressure_dipNm{i}, '_Avg'], 'color', color(i,:), 'LineStyle', '-.');
    end
    hold off;
    
    set(gca, 'FontSize', 16, 'XLim', [30, 500], 'YMinorTick', 'on'); 
    xlabel('Current[A]'); 
    ylabel('Pressure drop [Psi]');
    legend('Box', 'off', 'interpreter', 'none', 'Location', 'northoutside', 'NumColumns', 4);
    title('')
    % Add second Yaxis with bar unit.
    add_bar(gca);
end

function add_bar(ax)
    %This function will add one more yaxis on the existing plot with bar
    %unit calculation. 
    %ax is the handle of the current plot to which you will add yaxix
    hold on;
    %Format the ytick label
    tick = ax.YTick*0.06895;
    tick = num2cell(tick);
    fcn_h = @(x) num2str(x,3);
    tick = cellfun(fcn_h, tick, 'UniformOutput', false);
    %
    ax_add = axes('Position', ax.Position, 'FontSize', 16, ...
        'YLim', ax.YLim, 'YTick', ax.YTick, 'YTickLabel', tick, ...
        'XColor', 'none', 'Color', 'none', 'YMinorTick', 'on'); % Change to Bar unit
    ylabel('Pressure drop [Bar]');
    ax_add.Position(1) = 0.09;
    ax.Position(1) = 0.18;
    hold off
end