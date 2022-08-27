function [n,sizeX, sizeY] = implot(imIn, rel)
% IMPLOT takes imIn, sum in the x,y direction. Plot the lineout. Calculate
% the beam size in X, Y direction using 1/e^2.
% Count the total emitter number n;
% Replot the image in scale in a new figure;
% Write the emitter number and beam size in the new figure;
if nargin == 1
    rel = 10/933; %mm/pixel
end
% e = exp(1); % use for 1/e^2 plotting
x_int = sum(imIn,1); % sum in column
y_int = sum(imIn,2)';

x_int = x_int./(max(x_int));
y_int = y_int./(max(y_int)); % normalization

% Caculate the size of beam in um using 95% power content
% sizeX = (length(x_int(x_int >= 1/e^2)))*rel;
% sizeY = (length(y_int(y_int >= 1/e^2)))*rel;

percent = 0.95;
[x1, x2, disX]= area_per(x_int,percent); 
sizeX = disX*rel;
[y1, y2, disY]= area_per(y_int,percent);
sizeY = disY*rel;

% Count the emitter number
[Maxtab, ~]=peakdet(x_int, 0.095);
n = size(Maxtab,1);
% Make the new plot;
xcor = (1:length(x_int))*rel; % xcor in mm
ycor = (1:length(y_int))*rel; % ycor in mm
h = figure;
set(h, 'Position', [2134 41 1330 835]);

h1 = subplot(2,2,4);
[y,x] = size(imIn); y = [0, rel*y]; x = [0, rel*x];
imagesc(x,y,imIn);
set(gca,'FontSize', 16);
axis equal;
xlabel('X(mm)'); ylabel('Y(mm)');

h2 = subplot(2,2,2);
plot(xcor, x_int, 'b-', 'LineWidth', 2);
set(gca,'XLim', h1.XLim);
hold on;
plot(Maxtab(:,1)*rel, Maxtab(:,2),'ro', 'Linewidth',2);
plot([x1,x2]*rel, [x_int(x1), x_int(x1)], 'k--', 'LineWidth', 2);
hold off;
set(gca,'XTick',[], 'Position', [0.5703 0.4904 0.3347 0.0796]);
til = sprintf('Total emitter is %d', n);
title(til, 'FontSize', 12, 'Interpreter', 'none');

subplot(2,2,3);
hold on;
plot(ycor, y_int, 'b-', 'LineWidth', 2);
plot([y1,y2]*rel, [y_int(y1), y_int(y1)], 'k--', 'LineWidth', 2);
set(gca,'XLim', h1.YLim,'XDir', 'reverse');
set(gca, 'XTick',[],'Position', [0.4631 0.1100 0.0572 0.3412], 'View', [-90 90],'box','on');
hold off;


si_x = sprintf(['Beam Size X: %0.2f', ' mm'], sizeX);
si_y = sprintf(['Beam Size Y: %0.2f', ' mm'], sizeY);

subplot(h1);
hold on;
% Calculate and mark the centroid location.
x_cen = sum(x_int.*xcor)./sum(x_int);
y_cen = sum(y_int.*ycor)./sum(y_int);
plot(x_cen, y_cen, '.r', 'MarkerSize', 15);
text_str_cen = ['Centroid: ','[', num2str(x_cen,'%0.2f'),', ', num2str(y_cen,'%0.2f'),']', ' mm'];
% text(0.4055, 19.1532, {si_x,si_y,text_str_cen}, 'Color','w', 'FontSize',10, 'FontWeight','b');
text(0.5, 1.5, {si_x,si_y,text_str_cen}, 'Color','w', 'FontSize',10, 'FontWeight','b');
hold off;

end