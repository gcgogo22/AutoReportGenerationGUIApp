function save_fig(obj)
    % This function is called last to save all the open figure in folder
    % directory 'Processed' based on the open figure titles
    fld_dir = fullfile(obj.data_folder, 'Processed');
    mkdir(fld_dir); % Make a processed folder to save all the open figures;
    open_figs = findobj('Type', 'figure');
    
    len = numel(open_figs);
    for i = 1:len
       file_name = open_figs(i).Name;
       saveas(open_figs(i), [fullfile(fld_dir, file_name), '.fig']);
       saveas(open_figs(i), [fullfile(fld_dir, file_name), '.png']);
    end
end