classdef LIV_avg < handle
    % This class defines the general LIV average file processing and data
    % plotting. 
    % Plots the average data with 1st std dev error bar.
    % Plots the average data with min and max error bar. 
    
    properties       
        fld_dir;
        avg_data;
        current;
        test_order;
        ind; % this defines test parameters [pw, vol, cent, FW90, pw_dis, wavelength, thermal_res, junT, eff, ]... start ind 
    end
    
    methods
        function obj = LIV_avg(fld_dir)            
            % instance initilization function
            % fld_dir is the input folder directory where the avg file is
            % located
            obj.fld_dir = fld_dir;      
            fl_name = ls([fld_dir,'\Averaging*.xlsx']);  
            % check exsitence of file
            if isempty(fl_name)
                error('File doesn''t exist');
            else
                file_name = fullfile(fld_dir, fl_name); 
            end
            
            % Read test data
            loop_num_data = size(file_name,1);
            % Check if multiple avgerage file exist. If so, throw error
            % message
            if loop_num_data >1
                error('Multiple Avg file exists.');
            else
            % Read in the LIV data
                [LIV_data, test_order] = rd_Data(file_name);
                obj.avg_data = LIV_data; % Assign all the tabular test data and condition to LIV_data structure;
                obj.test_order = test_order;
            end
            
            % Extract the current value and assign to obj.current
            obj.current = current_extract(obj);
            
            % Calculate the ind of data category
            obj.ind = 10:(numel(obj.current)-1 + 7): 162; 
        end
        plot_current_pw_errStd(obj);
        plot_current_vol_errStd(obj);
        plot_current_junT_errStd(obj);
        plot_current_eff_errStd(obj);      
    end
    
    methods (Static)
        % define a static method for plotting the SAxis 95% divergence
        % angle.
        plot_current_saxis_95div(file_name, leg);
    end
end

% Subfunctions
function [LIV_data, test_order] = rd_Data(file_name)
    % This function receives the LIV test data file name
    % Read in the test data
    % Return the test LIV data to a table structure
    % Also retrun the name of the test condition
    ind = strfind(file_name, '_');
    ind = ind(end);
    test_order = file_name(ind+1:end-5); % This returns the test condition. -5 is to remove .xlsx
    
    opts = detectImportOptions(file_name);
    LIV_data = readtable(file_name, opts);
end