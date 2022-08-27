function plot_bm_parameter(obj)
    % Assign all the obj properties to the variables
    bm_parameter = obj.bm_parameter;
    cam_rel = obj.cam_rel;
    focal_dis = obj.focal_dis; % system focal distance in mm

    current = [bm_parameter.current];
    [current_sort, ia, ~] = unique(current);
    iter = length(current)/length(ia);
    color = linspecer(iter); % Create colors
    h_centroid = figure('Position', [2013 56 1016 839], 'Name', 'Centroid');
    h_bmwidth = figure('Position', [2013 56 1016 839], 'Name', 'Beam Width');
    try
        iter_step = length(current_sort)-1;
    for i = 1:iter
        % Plot the centroid
        temp = bm_parameter((i + (i-1)*iter_step) : (i + (i-1)*iter_step + iter_step));
        data = temp(ia);
        figure(h_centroid); hold on;
        centroid_slow = [data.centroid_slow];
        centroid_fast = [data.centroid_fast];
        plot(current_sort,(centroid_slow(1) - centroid_slow)*cam_rel/focal_dis, '-.o', ...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module, ' SAxis CenShift'], 'Color', color(i, :));
        plot(current_sort,(centroid_fast(1) - centroid_fast)*cam_rel/focal_dis , '-o', ...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module, ' FAxis CenShift'], 'Color', color(i, :));
        xlabel('Current [A]');
        ylabel('Centroid Shift [mrad]');
        legend('box', 'off', 'Location', 'northoutside', 'NumColumns', round(iter/2), 'fontsize', 12, 'interpreter', 'none');
        hold off;
        % Plot the beam width        
        data = temp(ia);
        figure(h_bmwidth); hold on;
        bmwid_slow = [data.bmWid_slow];
        bmwid_fast = [data.bmWid_fast];
        
        % Plot the beam width in yyaxis, in um
        yyaxis left;
        plot(current_sort,bmwid_slow*cam_rel, '-.s',...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module,' SAxis BmWid'], 'Color', color(i, :));
        ylabel('SAxis Beam Width [\mum]');
        set(gca, 'YColor', 'k');
        yyaxis right;
        plot(current_sort,bmwid_fast*cam_rel, '-s',...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module,' FAxis BmWid'], 'Color', color(i, :));
        xlabel('Current [A]');
        ylabel('FAxis Beam Width [\mum]');
        set(gca, 'YColor', 'k');
        legend('box', 'off', 'Location', 'northoutside', 'NumColumns', 2, 'fontsize', 12, 'interpreter', 'none');
        hold off;
    end
    catch ex
        disp(ex.message);
    end
    figure(h_centroid), set(gca,'FontSize', 16);
    grid on; grid minor;
    figure(h_bmwidth), set(gca,'FontSize', 16);
    grid on; grid minor; 
    
    % Change to data folder and save the centroid and beam width plots in
    % data folder
    cd(obj.img_fld);
    fig_h = findobj(0, 'Type', 'figure');
    len = numel(fig_h);
    % Save all the open figure;
    for i = 1:len
        saveas(fig_h(i), fig_h(i).Name, 'fig');
        saveas(fig_h(i), fig_h(i).Name, 'png');
    end
end