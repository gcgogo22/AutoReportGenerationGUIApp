function ind = test_ind(obj)
    % This function find the starting ind at current 30A for each test
    fld_names = fieldnames(obj.LIV_data);
    tb_data = obj.LIV_data.(fld_names{1});
    
    % Go through each variable names
    names = tb_data.Properties.VariableNames;
    len = length(names);
    count = 0;
    for i = 1:len
        if iscell(tb_data{1, names{i}})
            temp = tb_data{1, names{i}}{:};
            if strcmp(temp, 'Current (A)')
                count = count + 1;
                ind(count) = i + 3; %#ok<AGROW>
            end
        end
    end
    ind = ind(1:end-1);
end