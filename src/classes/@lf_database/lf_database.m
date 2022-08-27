classdef lf_database <handle
    % This class is created to process the ilasco_lifetest_table. It's the
    % recently updated summary table of all the projects in the life test.
    % This table is maintained by Aloy and updated biweekly.
    
    % This class will be part of the application program, which will
    % connect and download this table and generate the combined bar and
    % lineout plots.
    
    properties
        app_hd; % This is the application handle
        data; % This is the life time summary table
        lf_summary_tb_add;
        lf_summary_tb_color;
        lf_summary_active_tb; % This is the active table
        % Data base information
        meas_folder = '\\SRV23DATA2\5_Engineering\Dev_Eng_global\Development\05_Reliability\05_Gen 5_Chip_Lifetesting\Final1\Measurements';
        % DMW_Rack data column information
        lf_dcol; % life test data column
    end
    
    methods
        function obj = lf_database(app)
            % app is the application program handle, which provides plotted
            % figure and axis handles.
            obj.app_hd = app;
            % load data summary file, if no file is found, open the file
            % dialog and ask user to find this file
            fld_dir = '\\SRV23DATA2\5_Engineering\Dev_Eng_global\Development\05_Reliability\05_Gen 5_Chip_Lifetesting\Final1\Data_Summary';
            fl_name = 'illasco_lifetest_table.xlsx';
            full_file_nm = fullfile(fld_dir,fl_name);
            % load in the excel summary tbale, if there is error, asks to
            % manually open this file.
            try 
                obj.data = readtable(full_file_nm);
            catch Ex
                messge = sprintf([Ex.message, '\n', 'Please select the life test summary table:\n']);
                disp(messge); %#ok<DSPS>
                [fl_name, fld_dir] = uigetfile('\\SRV23DATA2\5_Engineering\Dev_Eng_global\Development\05_Reliability\05_Gen 5_Chip_Lifetesting\Final1\Data_Summary\', ...
                    'Select the lift test summary table', '*.xlsx');
                full_file_nm = fullfile(fld_dir,fl_name);
                obj.data = readtable(full_file_nm); % Read in the user selection file;
            end
            obj.lf_summary_tb_add = full_file_nm; % Assign the final full file address to the obj summary table address
            % Assign value to the life time data column 
            obj.lf_dcol.DWM_dr1_c1 = 3:2:25; % DWM dr1 c1
            obj.lf_dcol.DWM_dr1_c2 = 28:2:50; % DWM dr1 c2
            % Rack has same dr1 configuration
            obj.lf_dcol.Rack_dr2_c1 = 53:2:75; % Rack dr2 c1
            obj.lf_dcol.Rack_dr2_c2 = 78:2:100; % Rack dr2 c2
        end
            % Method function claim
            active_proj_rack(obj); % This function will update the table with active project rack number and drawer number
            lf_plot(obj); % This function plot the rack and drawer data based on the selection
            updata_ln_display(obj,ax_hd, value); % This function is used to show the interested lineplots based on the listbox value selection
            last_avg_power(obj, ax_hd); % This function updates the final data point average normalized power of the active lines in the figure;
    end
end