function write_pw(obj)
    % This function will write the sorted power into the specified column
    % of PwDropFile
    
    % Define the name and value pairs
    name_value = {'WriteVariableNames', false, 'Sheet', 'AuSn-2nd', 'Range', 'E2'};
    % Write the table data to the PwDropFile
    writetable(obj.dev_tb_sort(:,'Power_330A'), obj.dm17_lf.PwDropFile, name_value{:});
end