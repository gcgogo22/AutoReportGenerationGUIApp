function NF_plot(obj)
    % This is the method of the 'NF_FF_bmWid_Analysis' class to plot the
    % average NF 95% beam width, as well as the selected emitters
    
    % check emitter number
    em_num = size(obj.data_NF,2)-1; % This gives the total emitter number
    
    if em_num == 32
        em_sel = obj.emitter_num_70;
    else
        em_sel = obj.emitter_num_60;
    end
    
    % find the average 95% NF bm width in um
    temp = obj.data_NF.Var2;
    fcn_h = @(x) strcmpi(x,'NF95%');
    ind = find(cellfun(fcn_h, temp) == 1); % find the index of 'NF95%';
    bm_wid_95_avg = cellfun(@str2double, temp(ind+1:end)); 
    
    % find the selected emitter position beam width
    row_st = 4:13;
    col_num = em_sel + 1; % The row and column number export the matrix with 95% beam width at selected emitters
    bm_wid_95_sel = cellfun(@str2double, obj.data_NF{row_st, col_num}); % This extract the emitters at selected positions
    % make the plot
    NF_plot_bm(obj, bm_wid_95_avg, bm_wid_95_sel, em_sel); 
end

function NF_plot_bm(obj, avg_em, sel_em, em_sel)
    % This function will make the bar plots of the selected emitter width
    % and average plots of all the emitters 95% width in current
    h_fig = figure('Name', 'NF 95% Beam Width', 'Position', [2066 20 1122 851]);
    bar(obj.current,sel_em,1); % This makes the bar plots with the selected emitter.
    hold on;
    plot(obj.current, avg_em, 'k-.o', 'linewidth', 2);
    hold off;
    
    ax = gca;
    ax.YLim = [150, 300]; 
    ax.FontSize = 20;
    ax.YTick = 150:25:300;
    ax.YGrid = 'on';
    ax.YMinorGrid = 'on';
    xlabel('Current [A]');
    ylabel('95% SAxis Emitter Beam Width [\mum]'); 
    
    for i = 1:numel(em_sel)
        leg{i} = ['Emitter Pos:', num2str(em_sel(i))]; %#ok<AGROW>
    end
    leg{end + 1} = 'Avg';
    
    legend(leg{:}, 'box', 'off');
end