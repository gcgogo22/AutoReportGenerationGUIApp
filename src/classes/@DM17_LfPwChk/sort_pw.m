function sort_pw(obj)
    % This function will sort the dev_tb in the obj private property based
    % on the SN sequence of the power drop file.
    pw_drp_file = obj.dm17_lf.PwDropFile;
    % Read in the chip ID
    sp_opt = spreadsheetImportOptions;
    sp_opt.Sheet = 'AuSn-2nd';
    sp_opt.VariableNames = {'Chip_ID'};
    sp_opt.VariableTypes = {'double'};
    sp_opt.DataRange = 'A2';
    
    chip_id = readtable(pw_drp_file, sp_opt);
    dev_tb = obj.dev_tb;
    temp = dev_tb(:,'SN_number');
    temp.Properties.VariableNames = chip_id.Properties.VariableNames;
    [~, sort_ind] = ismember(chip_id, temp);
    % sort dev_tb according to the chip ID and assign it to dev_tb_sort
    obj.dev_tb_sort = dev_tb(sort_ind, :);
end