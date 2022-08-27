function analyze_data(obj)
    % This function acquire the image data
    count = 0;
    obj.data.threshold = 6;
    for i = 1:obj.module_num
    cd(obj.img_fld);
    try 
        sub_fld_name = strip(obj.data.module_sn(i,:));
        cd(sub_fld_name);

        %% Read in the image from the sub_fld
        all_file_name = ls;
        obj.data.testData = all_file_name(3:end, :);

        test_num = size(obj.data.testData, 1);
        for j = 1:test_num
            count = count + 1;
            test_name = strip(obj.data.testData(j,:));
            info = strsplit(test_name, '_');
            obj.data.current = str2double(info{1}(1:end-1));

            im_data = imread(test_name);
            %% Mask to filter the image data
            % Grab and calculate average background value.
            bg = im_data(1:100, :); 
            bg_avg = mean(bg, 'All');
            % Also, create a mask to remove the double reflection part
            mask = zeros(size(im_data));
            mask(800:1200, :) = 1;
            % Filter the data with the mask and subtract the background
            im_data = double(im_data).*mask;
            im_data = double(im_data) - bg_avg;
            im_data(im_data<0) = 0; % set negative values to zero
            figure('Position',[2235 63 1111 799]);
            data_h = subplot(2,2,4);
            imagesc(im_data); % Show the raw image
            title([sub_fld_name, ': ', num2str(obj.data.current), ' [A]'], 'Interpreter', 'none');
            xlabel('SAxis [px]');
            ylabel('FAxis [px]');
            set(data_h,'FontSize', 16);
            %% Calculate horizontal and vertical lineout and beamwidth, plot in subplot top and left
            [norm_line_out_x, centroid_x, beam_x_pos_x, beam_wid_x]= line_out(im_data);
            [norm_line_out_y, centroid_y, beam_x_pos_y, beam_wid_y]= line_out(im_data');

            % plot the lineout, centroid and beamwidth on subplots
            lin_x_h = subplot(2,2,2);
            lin_x_h.XLim = data_h.XLim;
            hold on;
            plot(norm_line_out_x, 'LineWidth', 2);
            plot([centroid_x, centroid_x], [0 1], 'r-.', 'linewidth', 2, 'DisplayName', 'Centroid');
            title(['BeamWidth: ', num2str(beam_wid_x,'%.f'), '[px]'], 'FontWeight', 'normal');
            set(gca, 'FontSize', 16, 'XTickLabel', [], 'YTickLabel', []);
            plot([beam_x_pos_x(1), beam_x_pos_x(1)], [0, 1], 'k-', 'LineWidth', 1.5);
            plot([beam_x_pos_x(2), beam_x_pos_x(2)], [0, 1], 'k-', 'LineWidth', 1.5);
            hold off;

            lin_y_h = subplot(2,2,3);
            lin_y_h.XLim = data_h.YLim;
            hold on;
            plot(norm_line_out_y, 'LineWidth', 2);
            plot([centroid_y, centroid_y], [0 1], 'r-.', 'linewidth', 2, 'DisplayName', 'Centroid');
            plot([beam_x_pos_y(1), beam_x_pos_y(1)], [0, 1], 'k-', 'LineWidth', 1.5);
            plot([beam_x_pos_y(2), beam_x_pos_y(2)], [0, 1], 'k-', 'LineWidth', 1.5);
            
            title(['BeamWidth: ', num2str(beam_wid_y,'%.f'), '[px]'], 'FontWeight', 'normal', 'Rotation', 90, 'Position', [1000 1.1274 0]);
            view(90,90);
            set(gca, 'FontSize', 16, 'YDir', 'reverse', 'XAxisLocation', 'top', ...
                'XTickLabel', [], 'YTickLabel', []);
            hold off;

            data_h.Position = [0.2657, 0.0882, 0.6393, 0.6746];
            lin_x_h.Position = [0.2657, 0.8222, 0.6393, 0.1];
            lin_y_h.Position = [0.0742, 0.0882, 0.1, 0.6746];
            
            obj.bm_parameter(count).current = obj.data.current; %#ok<*AGROW>
            obj.bm_parameter(count).module = sub_fld_name;
            obj.bm_parameter(count).centroid_slow = centroid_x;
            obj.bm_parameter(count).centroid_fast = centroid_y;
            obj.bm_parameter(count).bmWid_slow = beam_wid_x;
            obj.bm_parameter(count).bmWid_fast = beam_wid_y;
            
            %% save the image
                         
            mkdir('Processed');
            
            curr_fld = pwd;
            cd('Processed');
            saveas(gcf, [sub_fld_name, '_', num2str(obj.data.current), 'A'], 'fig');
            saveas(gcf, [sub_fld_name, '_', num2str(obj.data.current), 'A'], 'png');
            close all;
            cd(curr_fld);
        end
    catch Ex
            display(Ex.message);
    end
    end
    cd(obj.img_fld);
    close all;
    end


%% Calculate the image lineout, centroid and 95% beam width in the x direction
function [norm_line_out, centroid, beam_x_pos, beam_wid]= line_out(image_data_in)
    % Change input from uint8 to double for calculation
    image_data_in = double(image_data_in);
    % Calculate normalized lineout
    norm_line_out = sum(image_data_in,1)./max(sum(image_data_in,1));
    % Calculate the centroid
    sum_image_data = sum(image_data_in,1);
    centroid = sum((1:length(sum_image_data)).*sum_image_data)./sum(sum_image_data);
    % Calculate the 95% beam width
    cumsum_image_data = cumsum(sum_image_data);
    [cumsum_image_data,ia,~] = unique(cumsum_image_data);
    
    
    y1 = 0.025*cumsum_image_data(end);
    y2 = 0.975*cumsum_image_data(end);
    beam_x_pos = interp1(cumsum_image_data, ia, [y1, y2]); % x1 x2 in [px]
    beam_wid = beam_x_pos(2)-beam_x_pos(1); % in px
end