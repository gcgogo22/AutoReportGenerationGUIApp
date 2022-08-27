% This program goes into the data folder and process the beam profile
% images
% File name need to contains '_' after the current to work properly
clear; close all;
%% Creat struct to store all the data information
cam_rel = 6.7; % camera resolution in um
%focal_dis = input('Input the focal distance [mm]:\n'); % distance between lens to camera in mm  
focal_dis = 100; % focal distance has been changed to 100mm
count = 0;
data = struct();
data.threshold = 6;
h_fig = figure('Position', [431 56 1016 839]);
bm_parameter = struct();
%% Read in the image
img_fld =  uigetdir('D:\Trumpf_R&D\RD_TestData','Select Data Folder');
cd(img_fld);
all_folder_name = ls;
data.module_sn = all_folder_name(3:end, :);
module_num = size(data.module_sn, 1);
%% Acquire data
for i = 1:module_num
    cd(img_fld);
    try 
        sub_fld_name = strip(data.module_sn(i,:));
        cd(sub_fld_name);

        %% Read in the image from the sub_fld
        all_file_name = ls;
        data.testData = all_file_name(3:end, :);

        test_num = size(data.testData, 1);
        for j = 1:test_num
            count = count + 1;
            test_name = strip(data.testData(j,:));
            info = strsplit(test_name, '_');
            data.current = str2double(info{1}(1:end-1));
            %data.expoTime = info{2};
            %data.power = str2double(info{3}(1:end-5));

            im_data = imread(test_name);
            %% Threshold to filter the image data
            im_data(im_data<data.threshold) = 0;
            data_h = subplot(2,2,4);
            imagesc(im_data); % Show the raw image
            title([sub_fld_name, ': ', num2str(data.current), ' [A]'], 'Interpreter', 'none');
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
            
            bm_parameter(count).current = data.current;
            bm_parameter(count).module = sub_fld_name;
            bm_parameter(count).centroid_slow = centroid_x;
            bm_parameter(count).centroid_fast = centroid_y;
            bm_parameter(count).bmWid_slow = beam_wid_x;
            bm_parameter(count).bmWid_fast = beam_wid_y;
            
            %% save the image                   
            mkdir('Processed');
            curr_fld = pwd;
            cd('Processed');
            saveas(h_fig, [sub_fld_name, '_', num2str(data.current), 'A'], 'fig');
            saveas(h_fig, [sub_fld_name, '_', num2str(data.current), 'A'], 'png');
            cd(curr_fld);
        end
    catch Ex
            display(Ex.message);
    end
end
cd(img_fld);
close all;
%% Plot the beam parameters
[h_centroid, h_bmwidth] = plot_bm_parameter(bm_parameter, cam_rel, focal_dis);
saveas(h_centroid, 'cen_shift', 'fig');
saveas(h_centroid, 'cen_shift', 'png');

saveas(h_bmwidth, 'bm_wid', 'fig');
saveas(h_bmwidth, 'bm_wid', 'png');
close all;
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

function [h_centroid, h_bmwidth] = plot_bm_parameter(bm_parameter, cam_rel, focal_dis)
    current = [bm_parameter.current];
    [current_sort, ia, ~] = unique(current);
    iter = length(current)/length(ia);
    color = linspecer(iter); % Create colors
    h_centroid = figure('Position', [2013 56 1016 839], 'Name', 'Centroid');
    h_bmwidth = figure('Position', [2013 56 1016 839], 'Name', 'Beam Width');
    try
        iter_step = length(current_sort)-1;
    for i = 1:iter
        % Plot the centroid
        temp = bm_parameter((i + (i-1)*iter_step) : (i + (i-1)*iter_step + iter_step));
        data = temp(ia);
        figure(h_centroid); hold on;
        centroid_slow = [data.centroid_slow];
        centroid_fast = [data.centroid_fast];
        plot(current_sort,(centroid_slow(1) - centroid_slow)*cam_rel/focal_dis, '-.o', ...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module, ' SAxis CenShift'], 'Color', color(i, :));
        plot(current_sort,(centroid_fast(1) - centroid_fast)*cam_rel/focal_dis , '-o', ...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module, ' FAxis CenShift'], 'Color', color(i, :));
        xlabel('Current [A]');
        ylabel('Centroid Shift [mrad]');
        legend('box', 'off', 'Location', 'northoutside', 'NumColumns', round(iter/2), 'fontsize', 12, 'interpreter', 'none');
        hold off;
        % Plot the beam width        
        data = temp(ia);
        figure(h_bmwidth); hold on;
        bmwid_slow = [data.bmWid_slow];
        bmwid_fast = [data.bmWid_fast];
        
        % Plot the beam width in yyaxis, in um
        yyaxis left;
        plot(current_sort,bmwid_slow*cam_rel, '-.s',...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module,' SAxis BmWid'], 'Color', color(i, :));
        ylabel('SAxis Beam Width [\mum]');
        set(gca, 'YColor', 'k');
        yyaxis right;
        plot(current_sort,bmwid_fast*cam_rel, '-s',...
            'linewidth', 3, 'DisplayName', ['M:',data(1).module,' FAxis BmWid'], 'Color', color(i, :));
        xlabel('Current [A]');
        ylabel('FAxis Beam Width [\mum]');
        set(gca, 'YColor', 'k');
        legend('box', 'off', 'Location', 'northoutside', 'NumColumns', 2, 'fontsize', 12, 'interpreter', 'none');
        hold off;
    end
    catch ex
        disp(ex.message);
    end
    figure(h_centroid), set(gca,'FontSize', 16);
    grid on; grid minor;
    figure(h_bmwidth), set(gca,'FontSize', 16);
    grid on; grid minor; 
end