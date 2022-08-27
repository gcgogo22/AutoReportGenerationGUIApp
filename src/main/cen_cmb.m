% Combine all the FA centroid plots
% Combine all the FA beam width

% Create a centroid/pw width folder and move all the individual ilasco centroid
% plotting into this folder. Analyze the data in this folder 

close all; clear all;
cd('D:\Trumpf_R&D\RD_TestData\20190905_DM17_ilascoPnt\module32730\FA_wid_cmb');
files = ls;
color =linspecer(size(files, 1)-2);

main_fig = open(files(3, :));
line = findobj(main_fig, 'Type', 'line');
line.Color = color(1,:);
line.DisplayName = files(3, 1:end-4);

for i = 4: size(files,1)
    h_fig = open(files(i, :));
    line = findobj(h_fig, 'Type', 'line');
    line.Color = color(i-2, :);
    line.DisplayName = files(i, 1:end-4);
    copyobj(line, main_fig.Children(2));
    close(h_fig);
end

title('');