classdef NF_FF_bmWid_Analysis
    % This program is to analyze NF and FF bmWid data based on Mike's
    % automatic tester in Yihan's group.
    properties
        data_NF;
        data_FF_1p1;
        data_FF_1p4;
    end
    properties(Access = private)
        water_temp;
        test_date;
        emitter_num_70 = [1,8,16,24,32];
        emitter_num_60 = [1,9, 18, 27];
        current = 50:50:500; % Test current
    end
    
    methods
        function obj = NF_FF_bmWid_Analysis(water_temp)
            num = nargin; % Check the number of argument input
            if num == 0
                obj.water_temp = 25; % Water temperature set as 25 degree.
            else
                obj.water_temp = water_temp; % Otherwise assign the water temperature to the input value.
            end
            [NF_file,Path_NF] = uigetfile('G:\Dev_Eng_global\Development\R&D Testing Data\*', 'Please select the NF data file');
            [FF_file_1p1,Path_FF_1p1] = uigetfile('G:\Dev_Eng_global\Development\R&D Testing Data\*', 'Please select the FF data file 1.1lpm');
            [FF_file_1p4,Path_FF_1p4] = uigetfile('G:\Dev_Eng_global\Development\R&D Testing Data\*', 'Please select the FF data file 1.4lpm');
            if NF_file ~= 0 
                obj.data_NF = readtable(fullfile(Path_NF,NF_file)); % Read in the near field data into variable
            end
            obj.data_FF_1p1 = readtable(fullfile(Path_FF_1p1,FF_file_1p1));
            obj.data_FF_1p4 = readtable(fullfile(Path_FF_1p4,FF_file_1p4));
            
            % Assign the test date string to test_date string
            if ~isempty(obj.data_NF)
                obj.test_date = obj.data_NF(1,1);
            else
                obj.test_date = '';
            end
        end
        % Define 3 functions to generate plots in the near field and far
        % fields
        NF_plot(obj); % This function plot the near field data;
        FF_plot(obj); % This function plot the far field data;
    end
end