% This is v3 of the beam profile centroid calculation prgoram. After
% improving the experimental setup-put ND4 filter in front of the camera,
% the background noise of the captured bar image has been dramatically
% decreased. A more accurate way to calculate beam width and bar centroid
% is without setting up the threshold and flitering the image. v3. Use raw
% data input for bar centroid and emitter centroid calculation.

% Load in image
close all;
% Constant
rel = 6.7; % RD tester, camera pixel size 6.7um;
f_RD = 150; % RD tester, lens focal length 150mm;

% Original folder contains all the data folder
fld_or = 'C:\Trumpf_photonics\DM17_proj\DM17_data\20190410_highVisGlueTop\20190411_DM17_20_HighVis_PntMeas\2nd_expoFix';

current = 60:30:330;

cd(fld_or);
curr_fld = pwd;

fld_name = ls;
ind_len = size(fld_name,1);

for k = 3: ind_len

fld = [fld_or, '\', fld_name(k, :)];
cd(fld);

newfl = 'Processed';
mkdir(newfl);

files = ls('*.png'); % the file order is not correct;
ind_file_order = reorder(files);
len = size(files,1);

x_cen = zeros(1,len); %bar centroid in x mm
y_cen = zeros(1,len); %bar centroid in y mm

xc_emit = zeros(1,len); %center emitter centroid in bar in x mm
yc_emit = zeros(1,len); %center emitter centroidtin bar in y mm

sizeX = zeros(1,len); %95% power content x in mm
sizeY = zeros(1,len); %95% power content y in mm


for i = 1:len
    fld_return = pwd;
    file_na = strtrim(files(i,:));
    imData_raw = flipud(imread(file_na));    
    
    % Call function emit_cen and bar_centroid
    [x_cen(i), y_cen(i)] = bar_centroid(imData_raw, rel, file_na);
    [sizeX(i), sizeY(i), xc_emit(i), yc_emit(i)] = emit_cen(imData_raw,file_na, rel); % Return 95% power content in X, Y direction in mm
    cd(fld_return);
end

%% use bar centroid
cen_plot(x_cen, y_cen, f_RD, file_na, ind_file_order, current);
% use averge of emitter centroid
%  x_cen = cellfun(@mean, xc_emit);
%  y_cen = cellfun(@mean, yc_emit);
%  cen_plot(x_cen, y_cen, f_RD, file_na,curr_fld, ind_file_order);

% Neither bar centroid and emitter centroid are accurate
% use center emitter position shift.
% cen_plot(xc_emit, yc_emit, f_RD, file_na,curr_fld, ind_file_order);

%% Plot the 95% power content width
power_contPlot(sizeY, f_RD, file_na, ind_file_order, current);
close all;

end

cd(curr_fld);

function [sizeX, sizeY, cen_cEmitter_x, cen_cEmitter_y] = emit_cen(imData,file_na, rel)
imData_crop = imData; % assign raw data for future cropping

imData = im2double(imData);
    level = graythresh(imData);
    imData(imData<=level) = 0;
   

% Select the ROI and calculate the centrid of the image
x_st = 50; y_st = 200;
wid = (1270 - x_st);
heit = (800 - y_st);

x_st_mm = x_st*rel/1000; y_st_mm = y_st*rel/1000;
wid_mm = wid*rel/1000;
heit_mm = heit*rel/1000;

img_crop_raw = imData_crop(y_st:y_st+heit, x_st:x_st+wid);
img_crop = img_crop_raw;
thres = graythresh(img_crop);
im_bw = imbinarize(img_crop, thres);

SE = strel('rectangle',[26, 4]); % creat a rectangular mask;
im_bw_open = imopen(im_bw, SE);
im_bw_close = imclose(im_bw_open, SE);


% Calculate the centroid of connected components using regionprops
s = regionprops(im_bw_close,'centroid');
cen = cat(1, s.Centroid); %calculate the centroids
cen(:,1) = cen(:,1) + x_st; %change centroid to the orignal coordinates;
cen(:,2) = cen(:,2) + y_st; %change centroid to the orignal coordinates;
cen = cen_merg(cen); % call cen_merg to merge the splitted emitters

% Only find center emitter centroid to return;
ind_c = size(cen, 1); ind_c = round(ind_c/2); % center emitter position
cen_cEmitter_x = cen(ind_c,1)*rel/1000;
cen_cEmitter_y = cen(ind_c,2)*rel/1000; % return the position in mm

figure;
sub4 = subplot(2,2,4);
% Change imagesc to mm range
x_mm = [rel/1000, size(imData, 2)*rel/1000];
y_mm = [rel/1000, size(imData, 1)*rel/1000];
imagesc(x_mm,y_mm,imData_crop);

hold on;
plot(cen(1:end,1)*rel/1000, cen(1:end,2)*rel/1000, 'r.', 'MarkerSize', 15);
% plot the ROI box
plot([x_st_mm, x_st_mm+wid_mm], [y_st_mm, y_st_mm], 'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm, x_st_mm+wid_mm], [y_st_mm+heit_mm, y_st_mm+heit_mm], 'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm, x_st_mm],[y_st_mm, y_st_mm+heit_mm],  'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm+wid_mm, x_st_mm+wid_mm],[y_st_mm, y_st_mm+heit_mm],  'LineWidth', 2.5, 'Color', 'White');
% return emitter centroid position in mm
xc_emit = cen(1:end,1)*rel/1000;
yc_emit = cen(1:end,2)*rel/1000;

set(gca,'FontSize', 14, 'YDir', 'normal', 'TickDir', 'out', 'XMinorTick', 'on', ...
   'YMinorTick', 'on', 'Box', 'off');
sub4xlim = sub4.XLim;
sub4ylim = sub4.YLim;
xlabel('X(mm)');
ylabel('Y(mm)');
title(file_na, 'Interpreter', 'none');

hold on;

% plot horizontal lineout
sub2 = subplot(2,2,2);
im_data_clsum = zeros(1,size(imData, 2));
im_data_clsum(x_st: x_st + wid) = sum(img_crop,1)/max(sum(img_crop,1)); % sum in column of crop data

plot((1:size(imData,2))*rel/1000, im_data_clsum, 'k-', 'LineWidth', 1);
title(['Total emitter num: ', num2str(size(cen,1))], 'FontSize', 16);
% plot vertical lineout
sub3 = subplot(2,2,3);
im_data_rsum = zeros(1,size(imData, 1));
im_data_rsum(y_st: y_st+heit) = sum(img_crop,2)/max(sum(img_crop,2)); % sum in row

% !! return the peak positon of the vertical lineout for FA centroid
% positon
ind = find(im_data_rsum ==1);
if length(ind)>1
    ind = ind(round(length(ind)/2));
end

cen_cEmitter_y = ind*rel/1000;

%
plot((1:size(imData,1))*rel/1000, im_data_rsum, 'k-', 'LineWidth', 1);
% set up the axis
set(sub2, 'Position', [0.2715 0.7829 0.6 0.0882], 'Xtick', [], 'Xlim', sub4xlim);
set(sub3, 'XTick',[],'Position', [0.1339 0.0988 0.0676 0.6], 'View', [-90 90],'box','on', 'Xlim', sub4ylim...
    ,'XDir', 'normal');
set(sub4, 'Position', [0.2703 0.1 0.6 0.6]);
set(gcf,'Position',[1987 45 1031 773]);

% calculate the 95% power width
percent = 0.95;
[x1, x2, disX]= area_per(im_data_clsum,percent); 
sizeX = disX*rel/1000; %95% power content width in x direction mm
[y1, y2, disY]= area_per(im_data_rsum,percent);
sizeY = disY*rel/1000; %95% power content width in y direction mm

% plot the 95% line on the sub2 and sub3 plots
axes(sub2);
hold on;
plot([x1,x1]*rel/1000, [0,1], 'k--', 'LineWidth', 2);
plot([x2,x2]*rel/1000, [0,1], 'k--', 'LineWidth', 2); %95% power range
hold off;
axes(sub3);
hold on;
plot([y1,y1]*rel/1000, [0,1], 'k--', 'LineWidth', 2);
plot([y2,y2]*rel/1000, [0,1], 'k--', 'LineWidth', 2);
hold off;

ind = strfind(file_na, '.');
file_na_s = file_na(1:ind-1);
saveas(gcf, [file_na_s,'_emitter', '.png']);
saveas(gcf, [file_na_s,'_emitter', '.fig']);
end

function cen = cen_merg(cen)
% merge the emitters which are too close
cen_diff = diff(cen(:,1));
cen_m = mean(cen_diff);

ind = find(cen_diff< 0.7*cen_m);
ind_m = ind+1;

if ~isempty(ind)
cen(ind_m,:) = (cen(ind, :) + cen(ind_m,:))/2*size(cen(ind, :), 1);
cen(ind, :) = [];
end

end

%% Show image with bar centroid position.
% return the bar centroid in mm
function [x_cen, y_cen] = bar_centroid(imData, rel, file_na)
figure;
imData_crop = imData;
% Change imagesc to mm range
x_mm = [rel/1000, size(imData, 2)*rel/1000];
y_mm = [rel/1000, size(imData, 1)*rel/1000];
imagesc(x_mm,y_mm,imData);
% Select the ROI and calculate the centrid of the image
x_st = 50; y_st = 200;
wid = (1270 - x_st);
heit = (800 - y_st);

img_crop = imData_crop(y_st:y_st+heit, x_st:x_st+wid);
% plot a white box indicating the ROI
hold on;
x_st_mm = x_st*rel/1000; y_st_mm = y_st*rel/1000;
wid_mm = wid*rel/1000;
heit_mm = heit*rel/1000;

plot([x_st_mm, x_st_mm+wid_mm], [y_st_mm, y_st_mm], 'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm, x_st_mm+wid_mm], [y_st_mm+heit_mm, y_st_mm+heit_mm], 'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm, x_st_mm],[y_st_mm, y_st_mm+heit_mm],  'LineWidth', 2.5, 'Color', 'White');
plot([x_st_mm+wid_mm, x_st_mm+wid_mm],[y_st_mm, y_st_mm+heit_mm],  'LineWidth', 2.5, 'Color', 'White');
% calculate the centroid
sum_r = sum(img_crop, 1);
r_ind = (x_st-1) + (1:length(sum_r));
x_cen = (sum(sum_r.*r_ind)./sum(sum_r))*rel/1000;

sum_c = sum(img_crop, 2);
c_ind = (y_st-1) + (1:length(sum_c));
y_cen = (sum(sum_c.*c_ind')./sum(sum_c))*rel/1000;

% plot centroid 
plot(x_cen, y_cen, 'r.', 'MarkerSize', 15);
text(x_cen, y_cen-90*rel/1000, ['[', num2str(x_cen,3),', ', num2str(y_cen,3), ']'], 'FontSize', 14, ...
    'FontWeight', 'bold', 'Color', 'white'); % add the centroid position

set(gca,'FontSize', 14, 'YDir', 'normal', 'TickDir', 'out', 'XMinorTick', 'on', ...
   'YMinorTick', 'on', 'Box', 'off');
set(gcf,'Position',[1987 45 1031 773]);
xlabel('x(mm)'); 
ylabel('y(mm)');
title(file_na, 'Interpreter', 'none');
hold off;

cd('Processed');
ind = strfind(file_na, '.');
file_na_s = file_na(1:ind-1);
saveas(gcf, [file_na_s, '_bar', '.png']);
saveas(gcf, [file_na_s, '_bar','.fig']);
end

function [x1, x2, dis]= area_per(x,percent)
%AREA_PER calculate the starting and ending points symmetric around the
%beam center and return the distance. 
%percent is the percentage of the total area.

%x(x<0.04) =0; % set the threshold to clean up the noise

x_area = sum(x)*percent;
x_ind = find(x~=0); % find x2 within the box range

x_len = length(x);
x_cor = 1:x_len; 
x_cen = sum(x.*x_cor)./sum(x); % calculate x centroid

x1 = floor(x_cen)-1; % index of <x_cen
x2 = ceil(x_cen)+1; % index of >x_cen

try
chk = true;
while chk
    if sum(x(x1:x2))/x_area >=1 
        chk = false;
    else
        if x1 >= x_ind(1)
            x1 = x1 -1;
        end
        if x2 <= x_ind(end)
            x2 = x2 +1;
        end
    end

end

dis = x2 -x1; 
catch
end
end


function cen_plot(x_cen, y_cen, f, file_na, ind_file_order, current)
    cd('Processed');
    figure;    
    
    x_cen = x_cen(ind_file_order);
    y_cen = y_cen(ind_file_order);
    
    SA_shift = (x_cen-x_cen(1))/f*1000; %SA shift in mrad;
    plot(current,-SA_shift,'-ro','MarkerSize', 10, 'linewidth', 2.5, 'displayname', 'SA centroid');
    hold on;
    FA_shift = (y_cen-y_cen(1))/f*1000;
    plot(current, FA_shift,'-ks', 'MarkerSize',10, 'linewidth', 2.5, 'displayname', 'FA centroid');
    hold off;
    legend boxoff;
    xlabel('Current(A)');
    ylabel('Pointing Shift (mrad)');
    set(gca, 'FontSize', 16);
    set(gcf,'Position',[1987 45 1031 773]);
    grid on; grid minor;
    
    ind = strfind(file_na, 'r');
    file_na_s = file_na(1:ind-1);
    saveas(gcf,['_centroid','.png']);
    saveas(gcf,['_centroid','.fig']);
    
end

function ind_file_order = reorder(files)
%This function reorder the file from small current to large current
    len = size(files,1);
    for i = 1:len
%         ind_st = strfind(files(i, :), 'w');
          ind_st = 1;
          ind_end = strfind(files(i, :), '.');
          temp = files(i, :);
        current(i) = str2double(temp((ind_st):(ind_end-1)));
    end
    [~, ind_file_order] = sort(current);
end

% Plot the 95% power content width into mrad
function power_contPlot(sizeY, f_RD, file_na, ind_file_order, current)
    
    figure;    
    
    sizeY = sizeY(ind_file_order)/f_RD*1000;
    ind = strfind(file_na, 'r');
    file_na_s = file_na(1:ind-1);
    
    plot(current,sizeY,'-ro','MarkerSize', 10, 'linewidth', 2.5, 'displayname', '_FA 95% Power Width');
    legend('interpreter', 'non', 'box', 'off');
    xlabel('Current(A)');
    ylabel('95% Power Content Width (mrad)');
    set(gca, 'FontSize', 16);
    set(gcf,'Position',[1987 45 1031 773]);
    grid on; grid minor;
    
    
    saveas(gcf,['_powerWid','.png']);
    saveas(gcf,['_powerWid','.fig']);
    
end


