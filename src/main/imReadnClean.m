function imOut = imReadnClean(file_na,thred)
% The IMREADNCLEAN read in image and clean up the background.
% Then crop the image to the interest.
% Return the filtered image to imOut;
% Return the cropped image handle in h_crop
% Thred is thresold to clean up the image. intensity <= thred will be assignaed to 0

% file_fd = 'C:\Trumpf_photonics\DM03_proj\DM03_Data\DM03 FA-Beam Diamter';
% file_na = 'Low_50A_filtered.jpg';

imData = imread(file_na);
imData(imData <= thred) = 0;
figure; imagesc(imData);
title('Filtered image');

% disp('Cropping the image:');
% imOut = imcrop(imData, [416 24 1702 1971]);
% h_crop = figure; imagesc(imOut);
% title('Cropped image');

imOut = imData; % no image cropping
end
