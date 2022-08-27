% This program load all the Dymax glue centroid measurement with varied
% current and combine all the plots.

close all; 
fld = 'C:\Trumpf_photonics\DM17_proj\DM17_data\20190410_highVisGlueTop\20190411_DM17_20_HighVis_PntMeas\2nd_expoFix';
cd(fld);
fld_name = ls;
num = size(fld_name, 1);
h = zeros(1,num);
line_obj = cell(1,num);

for i = 3: num
    fld_name_temp = [fld, '\', fld_name(i,:)];
    cd(fld_name_temp);
    cd('Processed');
    h(i) = open('_centroid.fig');
    line_obj{i} = findobj(h(i), 'Type', 'Line', 'Color', 'k');
end

h_all_lines = figure(1);
SA_obj = findobj(h(1), 'Type', 'Line', 'Color', 'r');
delete(SA_obj);

for j = 4:num
    figure(1);
    copyobj(line_obj{j}, gca);
end

%Calculate and plot the mean value 
all_lines = findobj(h_all_lines, 'Type', 'line');
len = numel(all_lines);
x_data = all_lines(1).XData;
y_data = 0;
for k = 1:len
    y_data = y_data + all_lines(k).YData;
end
y_data_mean = y_data/len;

hold on;
plot(x_data, y_data_mean, 'r<-', 'LineWidth', 2.5, 'DisplayName', 'Mean');
hold off;
