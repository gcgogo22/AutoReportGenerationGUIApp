%% Read in the data file
% This update version works with the new lifetest template
% Directions: 
% 1. Change the folder directory.
% 2. Change the file name to the processed one.
% 3. After data is loaded, change to the 'Calculation' sheet to read in the
% data.
% 4. For data_num, input the row number for each carrier's ending time.
% 5. Pay attention to line 26, 46, 148. Some of the excel data missing one.
% Choose the correct line.
close all;
curr_folder = pwd;
folder = '\\SRV23DATA2\5_Engineering\Dev_Eng_global\Development\05_Reliability\05_Gen 5_Chip_Lifetesting\Final1\Data_Summary';
cd(folder);
new_folder = 'Processed_output'; % input the processed data folder name
mkdir(new_folder);
file = 'Summary_IV-VI_DM03.xlsx';
data = uiimport(file); %Use uiimport to read in data as cell array
header = data.textdata(1,:);
%% Calculate the ending row numbers of each projects.
fig_title = input('Please input project name with _:\n','s');
proj_num = size(data.data, 2)/2; % Divide by two to get rid of hrs.
proj_name = data.textdata(1, 2:2:end);
data_num = zeros(1,proj_num);
for i = 1:proj_num
    temp = data.data(:, 2*i);
    ind = find(~isnan(temp));
    data_num(i) = ind(end);
end

    if numel(data_num) == 1 % If just 1 column of hrs, expand it
        data_num = ones(1,proj_num)*data_num;
    end

lf_data_corr = life_testPl(data, data_num, new_folder, proj_name, fig_title);

%% Save the data into the excel file.
file_name = [fig_title, '.xlsx'];
xlswrite(file_name,header); % Write header into the file.
% Write data into the file.
temp_max = nan(max(data_num), numel(header)); % make a nan matrix filled with nan

try   
for i = 1: numel(header)
    ind = ceil(i/2);
    if rem(i,2) ~= 0
        temp_max(1:data_num(ind),i) = data.data(1:data_num(ind),i);
    else
        temp_max(1:data_num(ind),i) = lf_data_corr{ind};
    end
end
catch
end
xlswrite(file_name,temp_max,1,'A2');
% Change the sheet name

ex_sheet_name(fig_title); % save and change sheet name of corrected data

cd(curr_folder);
close all;

function lf_data = life_testPl(data ,data_num, new_folder, projectName, fig_title)
%% Extract project data
proj_num = numel(data_num);
lf_time = cell(proj_num,1);

for i = 1:proj_num
    lf_time{i} = data.data(1:data_num(i),2*i-1);
end
cd(new_folder);

lf_data = cell(proj_num,1);
lf_data_raw = cell(proj_num,1);

    figure;
    %Extract the plot data
    for j = 1:proj_num
        data_ex = data.data(1:data_num(j), 2*j);        
        lf_data_raw{j,1} = data_ex;
        lf_data{j,1} = lf_corr_fun(data_ex); % correct data
    
        % Plot the original data in subplot
        h1 = subplot(1,2,1);
        hold on;
        plot(lf_time{j,1}', lf_data_raw{j,1}, 'LineWidth', 2); % plot multiple data in the same plot
        
        %set(gca,'FontSize', 16, 'YLim', [0.75,1.1]);
        hold off;
        
        
        h2 = subplot(1,2,2);
        hold on;
        plot(lf_time{j,1}', lf_data{j,1}, 'LineWidth', 2); % plot multiple data in the same plot
        hold off;
        
    end 
      axes(h1);grid on; grid minor;
      axes(h2);grid on; grid minor;
      set(gcf,'Position',[2090 39 1301 810]);
      set(h1,'Ylim', [0,1.2], 'FontSize', 14);
      h1.Title.String = 'Raw Data';
      h1.XLabel.String = 'Time(hrs)'; h1.YLabel.String = 'Normalized Power';
      h2.Title.String = 'Corrected Data';
      h2.XLabel.String = 'Time(hrs)'; h2.YLabel.String = 'Normalized Power';
      set(h2,'Ylim', [0,1.2], 'FontSize', 14);
      legend(projectName{:}, 'Interpreter', 'none', 'Location', 'northoutside', 'Box', 'off', ...
            'Orientation', 'horizontal','NumColumns', 2, 'FontSize', 8);
      hold on;
      
      plot(xlim, [0.94, 0.94], 'k--', 'LineWidth', 2, 'DisplayName', '94% Drop Line');
      hold off;       
      saveas(gcf,fig_title, 'fig');
      saveas(gcf,fig_title, 'png');
end
% Function ex_sheet_name is only used to change the excel sheet name
function ex_sheet_name(fig_title)

file_name = [fig_title, '.xlsx'];
ex_full = fullfile(pwd, file_name);
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(ex_full); % # open file (enter full path!)
ewb.Worksheets.Item(1).Name = fig_title; % # rename 1st sheet
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit

end

function lf_data_corr = lf_corr_fun(lf_data)
%% Life data signal spikes removed
% figure; 
% plot(hrs, lf_data, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Life Test Normalized Power');
lf_data = lf_data';
lf_data_m = sp_rm(lf_data);
% hold on;
%plot(lf_data_m, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Median Filtered');

%% Record the drop > 0.003;
%Calculate the dropping threshold based on observation, 
%Consider when emitter is gradually dying.
threshold = 0.003; % when 1 emitter fails 0.005 is threshold.
lf_data_md = [0, diff(lf_data_m)];
ind = find(lf_data_md <= -threshold); % dropped data indx
val = lf_data_md(ind);

%% Mean value filter to correct slow rolling
lfm_len = numel(lf_data_m);
lf_data_mm = zeros(1,lfm_len);
for i = 1: lfm_len-2
    lf_data_mm(i) = mean([lf_data_m(i),lf_data_m(i+1),lf_data_m(i+2)]);
end
lf_data_mm(end-1) = mean([lf_data_mm(end-2), lf_data_m(end-1), lf_data_m(end)]);
lf_data_mm(end) = mean([lf_data_mm(end-2), lf_data_mm(end-1), lf_data_m(end)]);
%plot(lf_data_mm, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Mean Value');

lf_data_corr_off = (lf_data_m - lf_data_mm) + lf_data(1);
%% Plot the corrected data
%plot(lf_data_corr_off, 'b-', 'LineWidth', 1.5, 'DisplayName', 'DC Corrected');

%% Clean the spikes of the corrected signal

lf_data_corr = sp_rm(lf_data_corr_off);
lf_data_corr(end) = lf_data_corr(end-2); % correct the last two data points which can't make spike correction. length 5 filter.
lf_data_corr(end-1) = lf_data_corr(end-2);
%plot(lf_data_corr, '-', 'LineWidth', 1.5, 'DisplayName', 'DC Corrected wo Spikes');

%% Add drops to the corrected signal
len = numel(ind); 
for m = 1:len
    lf_data_corr(ind(m):end) = lf_data_corr(ind(m):end) + val(m); 
end

lf_data_corr = lf_data_corr';
% plot(hrs,lf_data_corr, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Corrected Normalized Power');
% 
% %% Add legends and labels
% xlabel('Time (Hrs)'); 
% ylabel('Normalized Power');
% grid on; 
% grid minor;
% legend;
% set(gcf,'Position', [2168 34 1087 852]);
% set(gca,'FontSize', 16);
end

function data_rmsp = sp_rm(data_sp)
    
    win = 5; % Define filter window size
    len = numel(data_sp);
    data_sp = [ones(1,floor(win/2))*data_sp(1), data_sp, ones(1,floor(win/2))*data_sp(end)];
    data_rmsp = zeros(1, len);
    
    for i = 1:len
        data_rmsp(i) = median(data_sp(i:i+win-1));
    end   
end