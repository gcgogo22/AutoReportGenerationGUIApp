classdef mod_beam_profileAly <handle
    % This program calculate the CW pointing and divergence of the DM17
    % module tester in high power R&D lab
    % Please create subfolders in data folder directory with module SN
    % In the module SN folder, save all the png raw data with current
    % values as name
    properties(GetAccess = private)
        cam_rel = 6.7; % camera resolution in um
        focal_dis = 100; % system focal distance in mm          
        data;
        module_num;
        img_fld; % Set img_fld to public, so analyze_data function can get access
    end
    
    properties
        bm_parameter;
    end

    methods
        function obj = mod_beam_profileAly()
            obj.img_fld =  uigetdir('D:\Trumpf_R&D\RD_TestData','Select Data Folder');
            cd(obj.img_fld);
            all_folder_name = ls;
            obj.data.module_sn = all_folder_name(3:end, :);
            obj.module_num = size(obj.data.module_sn, 1);
        end
        analyze_data(obj); % This function acquire the image data
        plot_bm_parameter(obj); % This function plot the beam parameter data
    end
end

