%% Life data signal spikes removed
close all;
figure(1);
plot(hrs, lf_data, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Life Test Normalized Power');

lf_data_m = sp_rm(lf_data);
hold on;
%plot(lf_data_m, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Median Filtered');

%% Record the drop > 0.019;
lf_data_md = [0, diff(lf_data_m)];
ind = find(lf_data_md <= -0.019); % dropped data indx
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

plot(hrs,lf_data_corr, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Corrected Normalized Power');

%% Add legends and labels
xlabel('Time (Hrs)'); 
ylabel('Normalized Power');
grid on; 
grid minor;
legend;
set(gcf,'Position', [2168 34 1087 852]);
set(gca,'FontSize', 16);

function data_rmsp = sp_rm(data_sp)
    
    win = 5; % Define filter window size
    len = numel(data_sp);
    data_sp = [ones(1,floor(win/2))*data_sp(1), data_sp, ones(1,floor(win/2))*data_sp(end)];
    data_rmsp = zeros(1, len);
    
    for i = 1:len
        data_rmsp(i) = median(data_sp(i:i+win-1));
    end   
end