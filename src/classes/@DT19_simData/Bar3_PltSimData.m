function Bar3_PltSimData(obj)
    % This method function makes 3D bar plot function in a quadrant
    % plots
    % Each bar represents the junction temperature at different fin length,
    % different AlN thickness and different flow rate.
    h_fig = figure('Name', 'JuncT Sim Data', 'Position', [2066 20 1122 851]);
    flw_rate = [1.1, 1.4]; % flow rate in lpm
    % set up title and legend
    tl = {'4mm Bar-Sim', '5mm Bar-Sim'};
    leg = {'1.1 lpm-300\mum AlN','1.4 lpm-300\mum AlN', ...
        '1.1 lpm-380\mum AlN', '1.4 lpm-380\mum AlN'};
    
    fld_names_bar = pri_property_name();
    fld_names_flw = fieldnames(obj.(fld_names_bar{1}));
    
    for i = 1:numel(fld_names_bar) % This is to process 4mm and 5mm bar data.
        for j = 1:numel(fld_names_flw) % This is to 1p1 and 1p4 lpm flow rate data
            % Divide data and stack based on the fin length
            if j<=4
                data_fin_len(1,j) = obj.(fld_names_bar{i}).(fld_names_flw{j}); %#ok<*AGROW>
            else
                data_fin_len(2,j-4) = obj.(fld_names_bar{i}).(fld_names_flw{j}); 
            end            
        end
        % Make the bar3 plot
        cmp_data{i} = data_fin_len; % Save all the data;
        ax = subplot(1,2,i);
        h_bar{i} = bar3([5,6], data_fin_len, 'stacked');
        set(gca,'FontSize',16);
        ylabel('Fin Length[mm]', 'Rotation', -35);
        zlabel('T_j[^oC]');
        grid on; grid minor;
        title(tl{i});
        legend(leg{:}, 'box','off','Position',...
            [0.3025044595818,0.875352528628252,0.35650623365307,0.034077554941177], 'NumColumns',2);
        set(gcf,'color','w');
    end
end

function name_cell = pri_property_name()
    % This function return a cell string with stored private property names
    meta_call = ?DT19_simData;
    pro_list = meta_call.PropertyList;
    len = numel(pro_list);
    for i = 1:len
        name_cell{i} = pro_list(i).Name;
    end
end