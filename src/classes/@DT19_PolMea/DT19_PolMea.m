classdef DT19_PolMea < handle
    % This is the class data to process DT19 project polarization
    % measurement
    
    properties
        % Define the polarization properties
        E15p4_pol = struct();
        E16p9_pol = struct();
    end
    
    methods
        function obj = DT19_PolMea()
            int_fun(obj);
        end
    end
    
    % Function claim
    methods
        int_fun(obj); % This is to initilize the obj function
        bar_plt(obj); % Make the bar plots of the polarizationd data at different current
    end
end


function int_fun(obj)
    % Call this function to initialize the obj and assign values to
    % properties
    test_folder = 'D:\Trumpf_R&D\RD_TestData';
    sub_folder = '20200117_DT19_DevPolarization\u500A_SpeCooler';
    E15p4_folder = 'DT19_E15-4';
    E16p9_folder = 'DT19_F16-9';
    % Device polarization folder
    E15p4_pol_fld = fullfile(test_folder, sub_folder, E15p4_folder);
    E16p9_pol_fld = fullfile(test_folder, sub_folder, E16p9_folder);
    %% Extract all E15.4 subfolder data
    E15p4_subfld_1p1 = subfld_filter(E15p4_pol_fld, '1.1L');
    E15p4_subfld_1p4 = subfld_filter(E15p4_pol_fld, '1.4L');
    % Extract all E15.4 polarization data
    E15p4_pol_1p1 = PolDataEx(E15p4_pol_fld, E15p4_subfld_1p1);
    E15p4_pol_1p4 = PolDataEx(E15p4_pol_fld, E15p4_subfld_1p4);
    % Assign to the object properties
    obj.E15p4_pol.flw_1p1 = E15p4_pol_1p1;
    obj.E15p4_pol.flw_1p4 = E15p4_pol_1p4;
    %% Extract all E16.9 subfolder data
    E16p9_subfld_1p1 = subfld_filter(E16p9_pol_fld, '1.1L');
    E16p9_subfld_1p4 = subfld_filter(E16p9_pol_fld, '1.4L');
    % Extract all E16.9 polarization data
    E16p9_pol_1p1 = PolDataEx(E16p9_pol_fld, E16p9_subfld_1p1);
    E16p9_pol_1p4 = PolDataEx(E16p9_pol_fld, E16p9_subfld_1p4);
    % Assign to the object properties
    obj.E16p9_pol.flw_1p1 = E16p9_pol_1p1;
    obj.E16p9_pol.flw_1p4 = E16p9_pol_1p4;
end

function sub_fld = subfld_filter(in_fld, sel_crita)
    % in_fld defines the input folder directory
    % sel_crita defines the selection criteria '1.1L' or '1.4L'
    fl_name = string(ls(in_fld));
    temp = strfind(fl_name, sel_crita);
    fcn_hd = @(x) isempty(x);
    rw_ind = cellfun(fcn_hd, temp); % find out row indice of fl_name
    sub_fld = fl_name(~rw_ind);
end

function pol_struct = PolDataEx(main_fld, sub_fld)
    % main_fld is the main folder directory
    % sub_fld is a str vector with sub folder directory.
    sub_fld_name = 'Polarization'; % final level subfolder directory
    n = numel(sub_fld);
    pol_struct.current = [150 325 500]; % constant test current value
    for i = 1:n
        % iterrate through all the subfolders
        data_fld = fullfile(main_fld, sub_fld(i), sub_fld_name);
        file_name = ls(data_fld);
        data_fl = fullfile(data_fld, file_name(3,:));
        pol_data = readtable(data_fl);
        % replace the '.' to '_'
        temp_str = char(sub_fld(i));
        new_str = regexprep(temp_str, {'\.', '\-'}, {'p', '_'});
        pol_struct.(['sn_',new_str]) = pol_data.Polarization;
    end
end