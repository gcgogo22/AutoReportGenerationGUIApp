% Test the dynamic range enhancement idea.
close all;
fld_cur =pwd;
fld = 'H:\PT_Projects\DT18\57_Testing\LifeTester_Proj\20190402_testdata';
fl_name = '040219_113313_BarNum_15.png';
cd(fld);
im_data = rgb2gray(imread(fl_name));
figure; imshow(im_data);
im_data = imcrop();


im_data_log = log(1+im2double(im_data));
im_data_log = im2uint8(mat2gray(im_data_log));
m = 0.5; E = 2;
im_data_log_enhce = 1./(1+ (m./(im2double(im_data) + eps)).^E);
im_data_log_enhce = im2uint8(mat2gray(im_data_log_enhce));


h1 = figure; imshow(im_data); h1.Position  = [2041 494 914 119];
h2 = figure; imshow(im_data_log); h2.Position  = [2041 494 914 119];
h3 = figure; imshow(im_data_log_enhce); h3.Position = [2041 494 914 119];
h4 = figure; h4.Position = [2997 250 679 561];
plot(sum(im_data), 'k-', 'LineWidth',1.5); % before enhancement
hold on;
plot(sum(im_data_log), 'r-', 'LineWidth', 1.5); % after enhancement
plot(sum(im_data_log_enhce), 'g-', 'LineWidth', 1.5);
cd(fld_cur);