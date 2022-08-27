%% Read image and do column sum
close all;
% main_folder = 'D:\Matlab_program';
% im_folder = '\\srv23data6\user$\GongCh\Desktop\Trumpf Photonics\weekly_report\life_test_sampleImg';
% cd(im_folder);
% image_name = 'Life_Test_Pulser';
% lf_img_raw = imread(image_name, 'png');
figure;
imshow(lf_img_raw);
im_crop = imcrop;
figure;
imshow(im_crop);
im_csum = sum(im_crop);
im_csum_max = max(im_csum);
im_csum_nor = im_csum/im_csum_max;
figure; 
plot(im_csum_nor, 'Linewidth',2);
%% Use peakdet to analyze the image
[Maxtab, Mintab] = peakdet(im_csum_nor,0.095);
hold on;
plot(Maxtab(:,1), Maxtab(:,2),'ro', 'Linewidth',2);
%plot(Mintab(:,1), Mintab(:,2),'g*');
hold off; close figure 1;
%% Create analysis folder
mkdir('analysis');
cd('analysis');
%% Name bar emitter figure
h2 = figure(2);
barImName  = [image_name, '_BarEmit'];
title('Bar emitters','Fontsize', 16, 'Fontweight', 'b');
saveas(h2, barImName, 'png');
%% Label emitter coutning window
h3 = figure(3);
xlabel('Lateral position [px]');
ylabel('Normalized intensity');
set(gca, 'Fontsize', 16, 'Fontweight', 'b', 'YGrid', 'on');
legend('Intensity lineout', 'Emitters');
legend boxoff;
text(500, 0.8, ['Emitter #:', num2str(size(Maxtab,1))],'Fontsize', 16, 'Fontweight', 'b');
saveas(h3, image_name, 'png');
disp(['Total emitter number is ', num2str(size(Maxtab,1)), '.']);
%cd(main_folder);