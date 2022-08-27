function FF_plot(obj)
    % This function plot the far field divergence angle at 1.1 and 1.4 lpm
    div_ang_1p1 = obj.data_FF_1p1.FF95_;
    div_ang_1p4 = obj.data_FF_1p4.FF95_;
    
    h_fig = figure('Name', 'FF 95% Div Angle', 'Position', [2066 20 1122 851]);
    h_1p1 = plot(obj.current, div_ang_1p1,'r-','LineWidth',2, 'DisplayName', '1.1 lpm');
    hold on;
    h_1p4 = plot(obj.current, div_ang_1p4,'g-','LineWidth',2, 'DisplayName', '1.4 lpm');
    hold off;
    
    set(gca,'FontSize', 20);
    xlabel('Current [A]');
    ylabel('FF SAxis Full Div Angle [deg]');
    legend('box', 'off', 'Location', 'northwest');
    grid on;
    grid minor;
end