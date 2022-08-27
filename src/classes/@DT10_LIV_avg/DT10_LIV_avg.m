classdef DT10_LIV_avg <handle
    % This script will read in the average DT10 LIV file and process to
    % generate data plot.
    properties
        avg_data;
        current;
        ind = 10:19:162; % this defines test parameters [pw, vol, cent, FW90, pw_dis, wavelength, thermal_res, junT, eff, ]... start ind 
    end
    
     properties(Access = private)        
        marker_shape; % Define all the marker shape for plotting
        data_folder; % Data folder location to save the plot figure;
    end
    
    methods
        function obj = DT10_LIV_avg()
            % instance initilization function
            main_test_fld = 'D:\Trumpf_R&D\RD_TestData';
            obj.data_folder = uigetdir(main_test_fld,'Select the data folder');            
            [file, path]= uigetfile([obj.data_folder, '\*.xlsx']); 
            file_name = fullfile(path, file); 
            
            % Read test data
            loop_num_data = size(file_name,1);
            for j = 1:1:loop_num_data
                [LIV_data, ~] = rd_Data(file_name);
                obj.avg_data = LIV_data; % Assign all the tabular test data and condition to LIV_data structure;
            end
            
            % Extract the current value and assign to obj.current
            obj.current = current_extract(obj);            
            obj.marker_shape = {'+', 'o', '*', 'x', 's', 'd', '^', '<', '>', 'v', 'p', 'h'};
        end
        current = current_extract(obj); % To extract the current value. Function must be either not claimed or claimed correctly
        plot_current_junT(obj);
        plot_current_pw(obj);
        plot_current_V(obj);
        plot_current_eff(obj);
    end
end

% subfunctions


function [LIV_data, cond] = rd_Data(file_name)
    % This function receives the LIV test data file name
    % Read in the test data
    % Return the test LIV data to a table structure
    % Also retrun the name of the test condition
    ind = strfind(file_name, '_');
    ind = ind(end);
    cond = ['cnd', file_name(ind:end-5)]; % This returns the test condition
    
    opts = detectImportOptions(file_name);
    LIV_data = readtable(file_name, opts);
end

