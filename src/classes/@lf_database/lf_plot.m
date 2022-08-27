function lf_plot(obj)
    % This function will update the life time data plot based on the rack
    % and drawer selection in the app.
    app_hd = obj.app_hd; 
    % identify the rack name
    fld = obj.meas_folder;
    rack_sel = obj.app_hd.RackSel.Value; % The callback function makes value selection from the dropdown menu
    file_fld = fullfile(fld,rack_sel); % This gives the selected file folder. 
    [file,path] = uigetfile([file_fld, '/*.xlsm'],'MultiSelect', 'off');% disable muti selection
    file_nm = fullfile(path, file); 
    % make axes assignment to a axes handle matrix
    ax_hd = [app_hd.drawer1, app_hd.drawer2, app_hd.drawer3,app_hd.drawer4];
    % define the drawer list box handle
    ls_box_hd = [app_hd.Drawer1ListBox, app_hd.Drawer2ListBox, app_hd.Drawer3ListBox, app_hd.Drawer4ListBox];
    %%% Create a spreadsheet datasore structure
    % create a progress dialog
    d = uiprogressdlg(app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Downloading Data...', 'Indeterminate','on');
    ssds = spreadsheetDatastore(file_nm, 'Sheets', 3);
    close(d);
    %%%
    % find the ax selection based on the drawer selection value.
    switch app_hd.DrawSel.Value
        case '1'
            ax_hd_sel = ax_hd(1);
            lsbox_sel = ls_box_hd(1); 
        case '2'
            ax_hd_sel = ax_hd(2);
            lsbox_sel = ls_box_hd(2);
        case '3'
            ax_hd_sel = ax_hd(3);
            lsbox_sel = ls_box_hd(3);
        case '4'
            ax_hd_sel = ax_hd(4);
            lsbox_sel = ls_box_hd(4);
        case '12'
            ax_hd_sel = [ax_hd(1), ax_hd(2)];
            lsbox_sel = [ls_box_hd(1), ls_box_hd(2)];
        case '34'
            ax_hd_sel = [ax_hd(3), ax_hd(4)];
            lsbox_sel = [ls_box_hd(3), ls_box_hd(4)];
    end
    % call DMW_plot, when rack_sel is 'DWM 1'; otherwise call Rack_plot
    if strcmpi(rack_sel, 'DWM 1')
        DWM_plot(obj, ssds, ax_hd_sel);
        % After generating the plots call the listbox_update function to
        % update the list box items.
        d = uiprogressdlg(app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Updating the listbox...', 'Indeterminate','on');
        listbox_update(ax_hd_sel, lsbox_sel);
        % Call last_avg_power function to calculate the end average power
        last_avg_power(obj, ax_hd_sel);
        pause(1.5);
        delete(d);
    else % Plot the rack data; For rack, drawer 1 is the same with DWM, drawer2 shift position
        DWM_plot(obj, ssds, ax_hd_sel(1)); % plot drawer 1 data.
        % Important!!: ssds is a handle object, whenever, the copy modify
        % the properties, you need to reset or fix it.
        d = uiprogressdlg(app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Updating the listbox...', 'Indeterminate','on');
        listbox_update(ax_hd_sel(1), lsbox_sel(1));
        last_avg_power(obj, ax_hd_sel(1));
        pause(1.5);
        delete(d);
        
        Rack_plot(obj, ssds, ax_hd_sel(2)); % plot drawer 2 data.
        d = uiprogressdlg(app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Updating the listbox...', 'Indeterminate','on');
        listbox_update(ax_hd_sel(2), lsbox_sel(2));
        last_avg_power(obj, ax_hd_sel(2));
        pause(1.5);
        delete(d);
    end
end

function DWM_plot(obj, ssds, ax_hd_sel)
    % This function is used for plotting the DWM data only, DMW drawer only
    % has 1 drawer 2 carrier, which is different than other rack.
    
    % Create the total color line; For DWM plot, one file contains 2 carrier only, total 24 lines ploted
    ln_color = colormap(ax_hd_sel, hsv(24));
    % Build up selected variable
    try
    % generate the percentage progressive plot
    d = uiprogressdlg(obj.app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Extracting device SN...');
    DWM_col = num2cell([obj.lf_dcol.DWM_dr1_c1 obj.lf_dcol.DWM_dr1_c2]);
    fcn_h = @(x) ['Var', num2str(x)];
    DWM_col_cell = cellfun(fcn_h, DWM_col, 'UniformOutput', false);
    d.Value = 0.3; 
    % Processing the serial number line for legend
    ssds.ReadVariableNames = false;
    ssds.Range = 'A5:CU5';
    ssds.SelectedVariableNames = DWM_col_cell;
    reset(ssds); 
    DWM_sn_leg = table2cell(read(ssds)); % Use for legend
    % call function to filter out the dummy pcs
    [DWM_sn_leg, DWM_col_cell] = filter_dummy(DWM_sn_leg, DWM_col_cell);
    d.Value = 0.6;
    %
    d.Message = 'Loading normalized power data...';
    reset(ssds);
    % Processing and read out the data
    ssds.Range = ''; 
    ssds.NumHeaderLines = 11;
    ssds.SelectedVariableNames = DWM_col_cell;
    pw_data_tb = read(ssds); 
    d.Value = 0.8;
    d.Message = 'Generating plots...';
    % create a function to eliminate the trailing 0s of column data
    % loop through the column extract the data and make the plot
    cla(ax_hd_sel); % clear the axis for plotting 
    for i = 1:size(pw_data_tb,2)
        data_ex = pw_data_tb{:,i};
        data_ex_elzero = el_tr_zero(data_ex);
        plot(ax_hd_sel, 0.5*(1:numel(data_ex_elzero)), data_ex_elzero, 'LineWidth', 1.5,...
            'color', ln_color(i, :), 'DisplayName', DWM_sn_leg{i});
        drawnow; % drawing figure;
        hold(ax_hd_sel,'on');
    end
    % Draw a 80% black dashed line.
    x_data = [0, max(ax_hd_sel.XLim)]; y_data = [0.8 0.8];
    plot(ax_hd_sel, x_data, y_data, '-.k', 'LineWidth', 1.5, 'DisplayName', '80% Limit'); 
    hold(ax_hd_sel,'off');
    legend(ax_hd_sel, 'box', 'off', 'Interpreter','none', 'FontSize', 6, 'location', 'EastOutside');
    ax_hd_sel.YLim = [0, 1.2]; % Setting the YLim of axis;
    d.Value = 1;
    d.Message = 'Finished!';
    pause(1);
    close(d);
    catch Ex
        disp(Ex.message);
    end
end

function Rack_plot(obj, ssds, ax_hd_sel)
    % This function is used for plotting the Rack data only, Rack has two
    % drawer and each drawer has 2 carrier
    % This function is used for plotting the Rack data only, Rack has two
    % drawer and each drawer has 2 carrier

    ln_color = colormap(ax_hd_sel, hsv(24));
    % Build up selected variable
    try
    % generate the percentage progressive plot
    d = uiprogressdlg(obj.app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Extracting device SN...');
    rack_col = num2cell([obj.lf_dcol.Rack_dr2_c1 obj.lf_dcol.Rack_dr2_c2]);
    fcn_h = @(x) ['Var', num2str(x)];
    rack_col_cell = cellfun(fcn_h, rack_col, 'UniformOutput', false);
    d.Value = 0.3; 
    % Processing the serial number line for legend
    ssds.NumHeaderLines = 0;
    ssds.ReadVariableNames = false;
    ssds.Range = 'A5:CV5';
    ssds.SelectedVariableNames = rack_col_cell;
    reset(ssds); % After changing the ssds range, requires a reset before reading out the data.
    rack_sn_leg = table2cell(read(ssds)); % Use for legend
    % call function to filter out the dummy pcs
    [rack_sn_leg, rack_col_cell] = filter_dummy(rack_sn_leg, rack_col_cell);
    d.Value = 0.6;
    %
    d.Message = 'Loading normalized power data...';
    reset(ssds); % After reading data out of ssds, reset it for next reading. 
    % Processing and read out the data
    ssds.Range = ''; 
    ssds.NumHeaderLines = 11;
    ssds.SelectedVariableNames = rack_col_cell;
    pw_data_tb = read(ssds); 
    d.Value = 0.8;
    d.Message = 'Generating plots...';
    % create a function to eliminate the trailing 0s of column data
    % loop through the column extract the data and make the plot
    cla(ax_hd_sel); % clear the axis for plotting 
    for i = 1:size(pw_data_tb,2)
        data_ex = pw_data_tb{:,i};
        data_ex_elzero = el_tr_zero(data_ex);
        plot(ax_hd_sel, 0.5*(1:numel(data_ex_elzero)), data_ex_elzero, 'LineWidth', 1.5,...
            'color', ln_color(i, :), 'DisplayName', rack_sn_leg{i});
        drawnow; % drawing figure;
        hold(ax_hd_sel,'on');
    end
    % Draw a 80% black dashed line.
    x_data = [0, max(ax_hd_sel.XLim)]; y_data = [0.8 0.8];
    plot(ax_hd_sel, x_data, y_data, '-.k', 'LineWidth', 1.5, 'DisplayName', '80% Limit'); 
    hold(ax_hd_sel,'off');
    legend(ax_hd_sel, 'box', 'off', 'Interpreter','none', 'FontSize', 6, 'location', 'EastOutside');
    ax_hd_sel.YLim = [0, 1.2]; % Setting the YLim of axis;
    d.Value = 1;
    d.Message = 'Finished!';
    pause(1);
    close(d);
    catch Ex
        disp(Ex.message);
    end
end

function output_vec = el_tr_zero(input_vec)
    % This function is used to eliminate trailing zeros and trailing NaN of a vector
    input_vec(isnan(input_vec)) = []; % Get rid of the NaN value at the end;
    zero_pos = (input_vec == 0);
    ind = find(zero_pos(end:-1:1) == 0); 
    ind = ind(1); % find from the back the first nonzero position
    output_vec = input_vec(1:end-ind-1); % This eliminates the trailing 0s from the vector 
end

function [sn_leg, col_cell] = filter_dummy(sn_leg, col_cell)
    % use contains to check if sn_leg contains Dummy, then update the
    % sn_leg and col_cell
    % Important, sometimes sn_leg cell content contains num data, first
    % need to change all the numerical data to str
    fcn_filnum_h = @(x) num2str(x);
    sn_leg = cellfun(fcn_filnum_h, sn_leg, 'UniformOutput', false);
    
    fcn_h = @(x) ~contains(x,'Dummy', 'IgnoreCase', true);
    ind = cellfun(fcn_h, sn_leg);
    sn_leg = sn_leg(ind); 
    col_cell = col_cell(ind);
end

function listbox_update(ax_hd, lstbox_hd)
    % listbox_update function will take axis handle and listbox handle as
    % input. It will examine the current plotted lines in the axes and
    % populate the listbox item list with the plotted line displayed names.
    lines = findobj(ax_hd, 'Type', 'Line', 'LineStyle', '-');
    lines = lines(end:-1:1); % reverse the line order
    item_list = {lines.DisplayName};
    % populate the listbox item list with item_list cell array
    lstbox_hd.Items = [item_list, {'All'}];
    lstbox_hd.Value = 'All'; % make the initial default selection as 'All'   
end