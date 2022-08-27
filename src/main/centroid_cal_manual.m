% manually calcualte centroid and beam width.
% Constant
rel = 6.7; % RD tester, camera pixel size 6.7um;
f_RD = 150; % RD tester, lens focal length 150mm;

%11 tab
cen_y_11tab = [420 417 421 421 422 426 429 433]; % in px
wid_y_11tab = [108 105.33 113.33 110.67 104 105.33 118.67 120];

%11 tabless
cen_y_11tabless = [425 426 429 430 430 436 444 454]; % in px
wid_y_11tabless = [65.33 62.67 74.67 78.67 89.33 97.33 92.00 96];

%12.5 tabless
cen_y_12p5tabless = [386 388 381 381 382 388 392 397]; % in px
wid_y_12p5tabless = [101.33 104 106.67 104 105.33 116 121.33 112];

close all;
cen_plot(cen_y_12p5tabless,rel,f_RD)
power_contPlot(wid_y_12p5tabless,rel,f_RD)


%% plot the centroid shift in FA in mrad
function cen_plot(y_cen,rel,f_RD)
    
    figure;    
    current = [30, 50:50:300, 330];
    
    FA_shift = -((y_cen-y_cen(1))*rel/1000)/f_RD*1000;
    plot(current, FA_shift,'-ks', 'MarkerSize',10, 'linewidth', 2.5);
    
    legend boxoff;
    xlabel('Current(A)');
    ylabel('Pointing Shift (mrad)');
    set(gca, 'FontSize', 16);
    set(gcf,'Position',[1987 45 1031 773]);
    grid on; grid minor;
  
end

%% Plot the 95% power content width into mrad
function power_contPlot(sizeY,rel, f_RD)
    
    figure;    
    current = [30, 50:50:300, 330];
    sizeY = (sizeY*rel/1000)/f_RD*1000;
    plot(current,sizeY,'-ro','MarkerSize', 10, 'linewidth', 2.5);
    legend('interpreter', 'non', 'box', 'off');
    xlabel('Current(A)');
    ylabel('95% Power Content Width (mrad)');
    set(gca, 'FontSize', 16);
    set(gcf,'Position',[1987 45 1031 773]);
    grid on; grid minor;
    
end 