% Script to make figure displaying DTI images

clear;
projectfolder = pwd;

%% Sample and image details

SampleName = '20250523_UQ8';

SeriesDescription = '40u_DtiSE_2012_SPOIL10%';


%% Load images

ImageArray = load(fullfile(projectfolder, 'Imaging Data', 'MAT', SampleName, SeriesDescription, 'axialImageArray.mat')).ImageArray;
ImageArrayDN = load(fullfile(projectfolder, 'Imaging Data', 'MAT DN', SampleName, SeriesDescription, 'axialImageArray.mat')).ImageArray;


%% Display

slice = 60;

% Direction
direction = 1;

f=figure;
f.Position = [680 458 560 240];
ax = axes;
imshow(squeeze(ImageArray(slice,:,:,direction+2)), [])
cb = colorbar;
cb.Label.String = 'Signal (a.u.)';
ax.Position = [0.02 0.02 0.82 0.98];
title([SampleName ' Direction ' num2str(direction) ' (Original)'], Interpreter="none")
saveas(f, fullfile(projectfolder, 'Figures', 'Supplementary', 'DTI_Original.png'))

f=figure;
f.Position = [680 458 560 240];
ax = axes;
imshow(squeeze(ImageArrayDN(slice,:,:,direction+2)), [])
cb = colorbar;
cb.Label.String = 'Signal (a.u.)';
ax.Position = [0.02 0.02 0.82 0.98];
title([SampleName ' Direction ' num2str(direction) ' (Denoised)'], Interpreter="none")
saveas(f, fullfile(projectfolder, 'Figures', 'Supplementary', 'DTI_Denoised.png'))
