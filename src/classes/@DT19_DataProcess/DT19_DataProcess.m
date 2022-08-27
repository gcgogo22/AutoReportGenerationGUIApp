classdef DT19_DataProcess
    % This class is used to process the DT19 test data in the average file.
    % You need to name the file in the format of 'DT19_1p1' etc. in order
    % to process it. 
    
    properties(Access = public)
        LIV_data; % This is a structure data, which contains LIV data at different test condtion.
        current;
        pressure;
    end
    
    properties(Access = private)
        ind; % Call the private function to initialize the test index
        marker_shape; % Define all the marker shape for plotting
        data_folder; % Data folder location to save the plot figure;
    end
    
    methods
        function obj = DT19_DataProcess()
            DT19_test_dir = 'D:\Trumpf_R&D\RD_TestData';
            obj.data_folder = uigetdir(DT19_test_dir,'Select the data folder');            
            file_name_cell = data_file_filter(obj.data_folder); 
            
            % Read test data
            loop_num_data = length(file_name_cell);
            for j = 1:1:loop_num_data
                [LIV_data, cond] = rd_Data(file_name_cell{j});
                obj.LIV_data.(cond) = LIV_data; % Assign all the tabular test data and condition to LIV_data structure;
            end
            
            % Extract the current value and assign to obj.current
            obj.current = current_extract(obj);
            obj.ind = test_ind(obj);
            obj.marker_shape = {'+', 'o', '*', 'x', 's', 'd', '^', '<', '>', 'v', 'p', 'h'};
            
            % Read in the pressure data            
            obj.pressure = pressure(obj.data_folder);
        end
        
        % Claim other functions to process data
        plot_current_pw(obj); % This function plot the power vs. current
        plot_current_vol(obj); % This function plot the voltage vs. current
        plot_current_junTemp(obj); % This function plot the junction temperature vs. current
        bplot_current_junTemp(obj, plt_current); % This function make the bar plots of the junction temperature vs. current
        plot_pw_efficiency(obj); % This function plot the power and efficiency combination
        plot_pw_juncTemp(obj); % This function plot the power and junction temperature combination
        plot_pressure(obj); % This function plot the pressure data
        plot_pw_eff_juncT(obj); % This prepares for the coming meeting with TLS to define the DT19 project goal
        plot_current_thermres(obj);
        plot_current_eff(obj); % This function plots the current and efficiency of the data.
        save_fig(obj); % Save all the open figures based on the figure title name
    end
    
    methods(Access = private)
        ind = test_ind(obj); % This function return the test starting ind at 'Current Value of 30A'
        current = current_extract(obj); % This function extract the current
    end
end

function file_name_cell = data_file_filter(data_folder)
    % This function will will filter out all the test data file name and
    % return them to a cell array
    
    file_name = ls(data_folder);
    loop_num = size(file_name, 1);
    count = 0;
    for i = 1:1:loop_num
        temp_name = file_name(i, :);
        ck_name = temp_name(1);
        if strcmp(ck_name, 'D')
            count = count + 1; % count gives the number of data file
            file_name_cell{count} = fullfile(data_folder, strip(temp_name)); %#ok<AGROW>
        end
    end

end

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

function pressure_data = pressure(folder)
    % This subfunction is called to read in the pressure data
    [file, path] = uigetfile([folder, '\*.xlsx'], 'Please select the pressure file'); % Find the excel file in the filter
    if file ~= 0 
        file_name = fullfile(path, file);
        opts = detectImportOptions(file_name);
        pressure_data = readtable(file_name, opts); % read in the pressure data
    else
        warning('Pressure file is not found');
        pressure_data = NaN;
    end
end