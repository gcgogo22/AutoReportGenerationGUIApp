classdef cp_save_report
    % This class is simply copy the report to the destination folder.
    % Destination folder is Chao's report and DT19 folder
    properties(Constant, Access = private)
       % Define the source folder directory
       src_fld = 'C:\Trumpf_photonics\weekly_report'
       % Define the destination folder directory 
       des_dt19_report = '\\srv23data6\departmental\PT_Projects\DT19\08_Results\08-10_Project_presentations';
       des_chao_report = 'G:\Dev_Eng_global\Development\89_GongCh\03.Project_report';
    end
    
    methods(Static)
        function cp_file(file_name)
            full_file_name = fullfile(cp_save_report.src_fld, [file_name, '.pptx']);
            dt19_report_name = fullfile(cp_save_report.des_dt19_report, [file_name, '_GongCh.pptx']);
            chao_report_name = fullfile(cp_save_report.des_chao_report, [file_name, '_GongCh.pptx']);
            
            copyfile(full_file_name, dt19_report_name);
            copyfile(full_file_name, chao_report_name);
        end
    end
end