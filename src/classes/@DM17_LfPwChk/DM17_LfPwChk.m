classdef DM17_LfPwChk < handle
    % This class is used to check the power drop for DM17 life test devices.
    % The devices are taken out from life test measurement temporarily for
    % power drop measurements. 
    % The power drop percentage is calculated.
    % And dead emitter number is counted.
    % Method calling sequence-> 1. Create an object instance. 2. Read the
    % power values of 330A from the LIV average file. 3. Sort the power
    % data based on the power drop file chip ID sequence. 4. Write the
    % power into the power drop file.
    
    properties
        dm17_lf = struct(); % Struct data type to store all information
    end
    
    properties (Access = public)
        dev_tb; % This is the raw power data extracted from the raw LIV data file with device SN number.
        dev_tb_sort; % This is the device table sorted according to the chip ID in hte AuSn Bars file.
    end
    
    methods
        function obj = DM17_LfPwChk()
            % Initilization of dm17_lf with file and folder information. 
            obj.dm17_lf.AvgFile = 'D:\Trumpf_R&D\RD_TestData\20191203_DM17_AuSn_lfTest\sec_pw_TestData\Average_cmb.xlsx';
            obj.dm17_lf.PwDropFile = 'D:\Trumpf_R&D\RD_TestData\20191203_DM17_AuSn_lfTest\DM17-AuSn-Bars.xlsx';
        end
        
        % Define other function methods
        pw_read(obj); % This function read in the power at 330A from raw LIV data
        sort_pw(obj); % This function will sort the dev_tb based on the sequence of power drop file
        write_pw(obj); % This function will write the sorted power into the specified column of PwDropFile
    end
end