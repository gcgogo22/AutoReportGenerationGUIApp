function active_proj_rack(obj)
    % This function will identify the cell color in the
    % ilasco_lifetest_table which shows the active project name in dark
    % green cell color. Then update the table in the app interface on the
    % 3rd tab with wafer number name and rack and drawer number. 
    % Use this information, you will select the interested project and make
    % the life test normalization data.
    
    d = uiprogressdlg(obj.app_hd.lf_time_report,'Title','Please Wait', 'Message', 'Updating the active life test table info...');
    pause(0.5);
    
    lf_summary = obj.lf_summary_tb_add;
    lf_data = readtable(lf_summary, 'ReadVariableNames', true);
    lf_data_len = size(lf_data,1); % Determine how many rows of data;
    % Create cell for function
    cell_array = num2cell(2:lf_data_len+1);
    fcn_hd = @(x) ['F', num2str(x)];
    cell_array = cellfun(fcn_hd, cell_array, 'UniformOutput', false);
    % Read out the color matrix
    len = numel(cell_array);
    pro_bar = round(linspace(1,len,4));
    for i = 1: len
        [red(i), green(i), blue(i)] = color_query(lf_summary, cell_array{i}); %#ok<*AGROW>
        if ismember(i, pro_bar)
            d.Value = i/len;
            d.Message = ['Finish ', num2str(round(100*d.Value, 0)),'%...'];
        end
    end
    color = [red', green', blue'];
    obj.lf_summary_tb_color = color; % Assign the cell color information to the obj
    % With color information, select the subtable with active ilasco life
    % test
    ind_red = find(red == 198); % This is the dark green ind with the active ilasco information
    tb_active = lf_data(ind_red,[4,5,6,7,8]); %#ok<*FNDSB>
    obj.lf_summary_active_tb = tb_active; % Assign the active table to the properties;
    % Update the App active table tab using the active table.
    tb_tab_hd = obj.app_hd.active_lf_table; % Active table handle
    tb_tab_hd.ColumnName = tb_active.Properties.VariableNames;
    tb_tab_hd.Data = tb_active;
    d.Value = 1; 
    d.Message = 'Active life test updating finished!';
    pause(0.8);
    close(d);
end

function [red, green, blue] = color_query(filename, cell)
    % This function takes file_name and cell_range as input. Check the
    % active project cell color and return its RGB cell color
    % cell for example 'F2';
    
    sheetname = 'lifetest_Summary';
    excel = actxserver('Excel.Application');  %start excel
    excel.Visible = true;    %optional, make excel visible
    workbook = excel.Workbooks.Open(filename);   %open excel file
    worksheet = workbook.Worksheets.Item(sheetname);  %get worksheet reference
    
    rgb = worksheet.Range(cell).Interior.Color;
    red = mod(rgb, 256);
    green = floor(mod(rgb / 256, 256));
    blue = floor(rgb / 65536);
    workbook.Close;
    excel.Quit;
end