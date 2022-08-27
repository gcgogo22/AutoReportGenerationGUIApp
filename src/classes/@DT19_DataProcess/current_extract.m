function current  = current_extract(obj)
    % This function will extract the current value
    fld_names = fieldnames(obj.LIV_data);
    tb_data = obj.LIV_data.(fld_names{1});
    
    ind = 10; % Starting current 30A
    count = 0; % Current count;
    while isfloat(tb_data{1,ind})
        count = count + 1; 
        current(count) = tb_data{1,ind}; %#ok<AGROW>
        ind = ind + 1;
    end
    
end