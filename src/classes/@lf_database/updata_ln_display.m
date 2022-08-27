function updata_ln_display(obj, value, drawer)
    % This function will be used to update the interested line display 
    % based on the value and drawer number.
    % value will be a cell array with all the active ilasco displayname
    % drawer number will be used to choose the plotted ax.
    
    % When there is value change, first turn on all the line visibility
   
    ax_hd = obj.app_hd.(drawer);
    ln_objs = findobj(ax_hd, 'Type', 'Line', 'LineStyle', '-');
    set(ln_objs, 'Visible', 'on');
    
    ln_objs_disName = {ln_objs.DisplayName};
    if ~any(contains(value, 'All')) % if not all selection, only turn on selected visibility
        
        % use strcmp to check if there is an exact match
        ind_int = zeros(1,numel(ln_objs_disName)); % set initial ind and update it during the loop 
        
        for i = 1:numel(value)  
            temp = strcmp(ln_objs_disName, value(i)); 
            ind_int(:) = any([ind_int; temp]);
        end
        final_ind = ~ind_int;
        ln_objs_off = ln_objs(logical(final_ind));
        % Turn off the visibility
        for i = 1: numel(ln_objs_off)
            ln_objs_off(i).Visible = 'off';
        end
    end
    % Every time after updating the display, call last_avg_power to update
    % the average end power
    
    % First delete the text obj
    ex_text_hd = findobj(ax_hd, 'Type', 'text');
    delete(ex_text_hd);
    % Call the last_avg_power to update
    last_avg_power(obj, ax_hd);
end