%% Read in the data file
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
folder = 'C:\Trumpf_photonics\DM17_proj\DM17_data\20190118_LifeTest_DataProcessing\r4_34_alexsis\12';
cd(folder);
new_folder = 'Processed'; % input the processed data folder name
mkdir(new_folder);
file = 'Measurement_Rack 4_Drawer_12_9-27-2018.xlsm';
file_name = fullfile(folder, file);
data = uiimport(file_name); %Use uiimport to read in data as cell array


data_num = input('Please input the ending row number of each carrier:\n');
%data_num = [13895,13841,13841,13519];%input the ending row number of data, change this number based on data range plotting;
    if numel(data_num) == 1
        data_num = ones(1,4)*data_num;
    end
    
proj_colID = [3,28,53,78]; % This is the input column ID of the project.
% proj_colID = [3, 28, 53, 77]; % This is the input column ID with the non-corrected one.
fig_title = fg_crTitle(data); % Read in the figure title

lf_data_corr = life_testPl(data, data_num, proj_colID, new_folder, fig_title);

file_name_corr = 'LifeTest_Corrected_Data.xlsx';
ex_sheet_name(lf_data_corr, file_name_corr, fig_title); % save and change sheet name of corrected data

cd(curr_folder);

function lf_data = life_testPl(data ,data_num, proj_colID, new_folder,fig_title)

dc_num = numel(fig_title); % total drawer and carrier number to plot. 
slot_num = 12; % slot number in each carrier.

%% Extract plots name
proj_named1c1 = data.textdata(5, proj_colID(1):2:25); % project name in first drawer and first carrier
proj_named1c2 = data.textdata(5, proj_colID(2):2:50);
proj_named2c1 = data.textdata(5, proj_colID(3):2:75);
proj_named2c2 = data.textdata(5, proj_colID(4):2:100);
% proj_named2c2 = data.textdata(5, proj_colID(4):2:99); % this corresponds to the non-corrected project ID.
projectName = {proj_named1c1,proj_named1c2,proj_named2c1,proj_named2c2};% legend names

%% Extract project data
lf_time = cell(dc_num,1);
lf_time_colnum = [1, proj_colID(2:end)-1];

for m =1:dc_num
    if ~isnan(data.data(12, lf_time_colnum(m)))
        lf_time{m,1} = (data.data(12: data_num(m), lf_time_colnum(m)))';% X data, life time with hr unit 
    else
        lf_time{m,1} = (data.data(12: data_num(m), 1))';
    end
end

cd(new_folder);

lf_data = cell(1,dc_num);
lf_data_raw = cell(1,dc_num);
for i = 1: dc_num
    lf_data{1,i} = zeros(data_num(i)-11, slot_num);
    lf_data_raw{1,i} = zeros(data_num(i)-11, slot_num); 
    figure(i);
    %Extract the plot data
    for j = 1:slot_num
        data_ex = data.data(12:data_num(i), proj_colID(i)+ (j-1)*2);        
        lf_data_raw{1,i}(:,j) = data_ex;
        lf_data{1,i}(:,j) = lf_corr_fun(data_ex); % correct data
    end
    % Plot the original data in subplot
    subplot(1,2,1);
        plot(lf_time{i,1}', lf_data_raw{1,i}, 'LineWidth', 2); % plot multiple data in the same plot
        hold on;
        plot(lf_time{i,1}', 0.94*ones(length(lf_time{i,1}'),1), 'k--', 'LineWidth', 2, 'DisplayName', '94% Drop Line');
        hold off; 
        %set(gca,'FontSize', 16, 'YLim', [0.75,1.1]);
        title([fig_title{i},'-Raw']); xlabel('Time(Hrs)'), ylabel('Normalized Power');
        grid on; grid minor;
    subplot(1,2,2);
        plot(lf_time{i,1}', lf_data{1,i}, 'LineWidth', 2); % plot multiple data in the same plot
        hold on;
        plot(lf_time{i,1}', 0.94*ones(length(lf_time{i,1}'),1), 'k--', 'LineWidth', 2, 'DisplayName', '94% Drop Line');
        hold off;
        %set(gca,'FontSize', 16, 'YLim', [0.75,1.1]);
        legend(projectName{i}, 'Interpreter', 'none', 'Location', 'northoutside', 'Box', 'off', ...
            'Orientation', 'horizontal','NumColumns', 2, 'FontSize', 8);
        title(fig_title{i}); xlabel('Time(Hrs)'), ylabel('Normalized Power');
        grid on; grid minor;
        
    set(gcf,'Position',[2090 39 1301 810]); 
    saveas(gcf,fig_title{i}, 'fig');
    saveas(gcf,fig_title{i}, 'png');
% Save the data into the excel table
filename = 'LifeTest.xlsx';
header = {'Test Names', 'Overall Power Drop(%)','Overall Operation Time(Hrs)','6% Power Drop Time(Hrs)'};
sheet = i;
data_in = cell(j,numel(header));
    
    data_in(:,1) = projectName{i}'; % write in test cases
    data_in(:,2) = mat2cell(100-lf_data{1,i}(end,:)'*100, ones(1,j),1); % write in the total power drop, %
    data_in(:,3) = mat2cell(ones(j, 1)*lf_time{i}(end), ones(1,j),1); % write in the overall operation time(hrs).

    for k = 1:j % find 80% power drop hrs
        ind_94 = (find(lf_data{1,i}(:,k)<= 0.94));
        
        if ~isempty(ind_94) % There is data never cross 94% line
            data_in{k,4} = lf_time{i}(ind_94(1)); % find first data point drop below 94%
        end
    end

    % Combine the data
    data_exl = [header; data_in];
xlswrite(filename, data_exl, sheet);

ex_full = fullfile(pwd, filename);
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(ex_full); % # open file (enter full path!)
ewb.Worksheets.Item(i).Name = fig_title{i}; % # rename 1st sheet
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit
end
end

function fig_title = fg_crTitle(data)
    fig_title = cell(1,4);
    fig_title{1} = [data.textdata{3,3},'-' data.textdata{4,3}];
    fig_title{2} = [data.textdata{3,28},'-' data.textdata{4,28}];
    fig_title{3} = [data.textdata{3,53},'-' data.textdata{4,53}];
%     fig_title{4} = [data.textdata{3,77},'-' data.textdata{4,77}]; % the non-corrected data
    fig_title{4} = [data.textdata{3,78},'-' data.textdata{4,78}];
end

function ex_sheet_name(lf_data_corr, file_name_corr, fig_title)

for i = 1:numel(fig_title)
    xlswrite(file_name_corr,lf_data_corr{i},i);
    
ex_full = fullfile(pwd, file_name_corr);
e = actxserver('Excel.Application'); % # open Activex server
ewb = e.Workbooks.Open(ex_full); % # open file (enter full path!)
ewb.Worksheets.Item(i).Name = fig_title{i}; % # rename 1st sheet
ewb.Save % # save to the same file
ewb.Close(false)
e.Quit
end
end