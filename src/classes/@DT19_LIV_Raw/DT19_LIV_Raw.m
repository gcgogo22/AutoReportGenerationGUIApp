classdef DT19_LIV_Raw <handle
    % This class is used to process the raw LIV data file in the pre or post test folder
    % This class enable you to select a single at initilization or you can
    % call flw_process to extract all file information on specific folder
    % refer fld strcutre on location 'D:\Trumpf_R&D\RD_TestData\test_folder\20191101_DT19_DataAnalysis\E15.4_4mm_Bar'
    % for more information.
    
    properties
        LIV_data = struct(); % The LIV data is used to save the read-in data matrix
        FlwData_ex = struct(); % This is the extracted flow rate data for specific variable
        current = [30:30:480, 500]; % Current information
        fld_add;
    end
    
    methods
        function obj = DT19_LIV_Raw(file_name)
            % This initilized function receives the file address and read
            % in the LIV data; otherwise, it opens a file dialog to ask
            % select a file.
            % If use input file_name, it should be a full path
            
            % Input the folder directory for fld_add property which is for
            % flw_process, add_box_plot and scatter_press_plot analysis
            
            DT19_test_dir = 'D:\Trumpf_R&D\RD_TestData\*.xlsx';
            if nargin ~= 1
                [file, path] = uigetfile(DT19_test_dir,'Select the data folder');
                file_name = fullfile(path, file);
                % Also assign the fld_add property based on the file
                % selection               
                temp_ind = strfind(path, '_Bar')+ 3;
                obj.fld_add = path(1:temp_ind);
            else
                temp_ind = strfind(file_name,'\');
                file = file_name(temp_ind+1:end);
            end
            % Extract the device SN number
            ind = strfind(file, 'autoreport');
            sn_num = file(1:(ind(1)-1)); % This extract the device sn_num
            % Extract the flow rate measurement condition
            opts_summary = spreadsheetImportOptions;
            opts_summary.Sheet = 'Summary';
            opts_summary.VariableNames = {'Flow_rate_lpm'};
            opts_summary.SelectedVariableNames = {'Flow_rate_lpm'};
            opts_summary.DataRange = 'C13:C13';
            
            T_summary = readtable(file_name, opts_summary);
            flw_rate = T_summary{1,1};
            flw_rate = str2double(flw_rate{:});
            
            % Extract the LIV data
            opts_summary = spreadsheetImportOptions;
            opts_summary.Sheet = 'LIV';
            opts_summary.VariableNames = {'I', 'P', 'V', 'Centroid', 'FW90', 'P_dissip', 'Chirp_nm',...
                'R_th', 'T_junct', 'Effic', 'Slope'};
            opts_summary.SelectedVariableNames = opts_summary.VariableNames;
            opts_summary.DataRange = 'A6:K22';
            temp_type = cell(1,11);
            temp_type(:) = {'double'};
            opts_summary.VariableTypes = temp_type;
            T_LIV = readtable(file_name, opts_summary);
            
            % Assign all the value to LIV_data
            obj.LIV_data.LIV = T_LIV;
            obj.LIV_data.flw_rate = flw_rate;
            obj.LIV_data.devSN = sn_num;
        end
        flw_process(obj, cooler_type, column_name); % method to extract mean, min, max information and save data in the properties
        ex_data_lin(obj, Y_label, i);
        add_box_plot(obj, parameter, current); % make box plot
        spectrum_plot(obj); % make spectrum plot.
        scatter_press_plot(obj); % make the scatter pressure and power plot.
        ff_saxis_div_plot(obj); % make the confident plot of the far field slow axis full divergence angle.
    end
end