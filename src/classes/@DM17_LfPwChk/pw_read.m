function pw_read(obj)
    % This is the method to extract the power measurement at 330A from the
    % average data file.
    
    fl_add = obj.dm17_lf.AvgFile;
    sp_opt = spreadsheetImportOptions;
    % Define the spread opt obj
    sp_opt.Sheet = 'LIV_Data';
    sp_opt.VariableNames = {'SN_number'};
    sp_opt.VariableTypes = {'double'};
    sp_opt.DataRange = 'B5';
    
    dev_sn = readtable(fl_add, sp_opt);
    % Read in the device power measurement
    sp_opt.VariableNames = {'Power_330A'};
    sp_opt.DataRange = 'T5';
    dev_pw = readtable(fl_add, sp_opt);
    % Merge two tables
    obj.dev_tb = [dev_sn, dev_pw];
end