function current  = current_extract(obj)
    % This function will extract the current value
    tb_data = obj.avg_data;
    
    ind = 10; % Starting current 30A
    count = 0; % Current count;
    while isfloat(tb_data{1,ind})
        count = count + 1; 
        current(count) = tb_data{1,ind}; %#ok<AGROW>
        ind = ind + 1;
    end
    
end