function flw_process(obj, cooler_type, column_name)
    % This function creates a structure data
    % with the cooler_type input. Ex. 'c6mm_fin, c200um_channel, c300um_AlN and std_cooler'
    % under the cooler type, there will be two fields _1p1 and _1p4,
    % represents the flow rate.
    % under each flow rate, it will give a matrix (col1: avg, min, max)
    % column_name is the column name you would like to extract the data.
    % Ex. I, P, V, Centroid, FW90, P_dissip, Chirp_nm, R_th, T_junct,
    % Effic, Slope
    % It will generate a matrix with mean, min and max values with your
    % selection and return this data mat to the FlwData_ex property to your
    % instance
    
    %% Create FlwData with cooler_type and two flow_rate field
    FlwData = struct(cooler_type, struct('f1p1',[], 'f1p4', []));
    %% Define the main folder and extract all the files based on the cooler_type (require modification)
    %mn_fld = 'D:\Trumpf_R&D\RD_TestData\test_folder\20191101_DT19_DataAnalysis';
    mn_fld = obj.fld_add; % Read the folder directory from the obj
    data_fld = fullfile(mn_fld,cooler_type);
    sub_fld_2 = {'_1.1lpm', '_1.4lpm'};
    % Call file name extraction function to read out all the file name
    flw_1p1_flname = fl_name_ex(fullfile(data_fld, sub_fld_2{1}));
    flw_1p4_flname = fl_name_ex(fullfile(data_fld, sub_fld_2{2}));
    
    %% Create obj and extract the data information
    %  Extract 1p1 lpm flow rate data
    len_1p1 = size(flw_1p1_flname,1);
    for i = 1:len_1p1
        temp_flname = fullfile(data_fld, sub_fld_2{1}, strip(flw_1p1_flname(i,:)));
        temp_obj = DT19_LIV_Raw(temp_flname);
        temp_data(:,:,i) = temp_obj.LIV_data.LIV.(column_name); %#ok<AGROW>
    end
    FlwData.(cooler_type).f1p1 = mean_min_max(temp_data);
    % with temp_data call the mean_min_max function to calcualte the mean
    % min and max values and then assign to FlwData
    
    %  Extract 1p4 lpm flow rate data
    len_1p4 = size(flw_1p4_flname,1);
    for i = 1:len_1p4
        temp_flname = fullfile(data_fld, sub_fld_2{2}, strip(flw_1p4_flname(i,:)));
        temp_obj = DT19_LIV_Raw(temp_flname);
        temp_data(:,:,i) = temp_obj.LIV_data.LIV.(column_name);
    end
    FlwData.(cooler_type).f1p4 = mean_min_max(temp_data);
    % with temp_data call the mean_min_max function to calcualte the mean
    % min and max values and then assign to FlwData
    
    %% Assign the value to the obj property
    obj.FlwData_ex.([cooler_type,'_', column_name]) = FlwData.(cooler_type); 
end

function fl_name_matx = fl_name_ex(fld_name)
    % This function extract all the file names in the folder and then
    % return
    fl_name = ls(fld_name);
    fl_name_matx = fl_name(3:end, :); 
end

function mean_min_max_mtrx = mean_min_max(data)
    % This function calculate the mean, min and max values in 3rd dimension
    mean_data = mean(data, 3); 
    min_data = min(data, [], 3);
    max_data = max(data, [], 3);
    
    mean_min_max_mtrx = [mean_data, min_data, max_data];
end