% Script to generate figures displaying denoising results

clear;
projectfolder = pwd;

%%

ImagingDataFolder = fullfile(projectfolder, 'Imaging Data');

samplename = '20250524_UQ9';
%'20250224_UQ4'
% '20250407_UQ5'
%'20250414_UQ6'
% '20250522_UQ7'
% '20250523_UQ8'
% '20250524_UQ9

% Sequence
seriesdescription = 'STEAM_ShortDELTA_40';

% '40u_DtiSE_2012_SPOIL10%'
% 'STEAM_ShortDELTA_40'

% Directions
directions = [1,6];



%% Load original and denoised images

ImageArray = load(fullfile(ImagingDataFolder, 'MAT', samplename, seriesdescription, 'axialImageArray.mat')).ImageArray;
ImageArrayDN = load(fullfile(ImagingDataFolder, 'MAT DN', samplename, seriesdescription, 'axialImageArray.mat')).ImageArray;

slice = round(0.5*size(ImageArray, 1));


%% Display

folder = fullfile(projectfolder, 'Thesis Figures', 'Denoising examples', samplename, seriesdescription);
mkdir(folder);

for direc = directions

    f1=figure;
    tiledlayout(1,1);
    nexttile;
    switch seriesdescription
        case '40u_DtiSE_2012_SPOIL10%'
            imshow(1e8*squeeze(ImageArray(slice,:,:, direc+2)), []);
        case 'STEAM_ShortDELTA_40'
            imshow(5e4*squeeze(ImageArray(slice,:,:, direc+1)), []);
    end
    cb=colorbar;
    cb.Label.String = 'Signal (a.u.)';
    cb.Ticks = 5:5:100;
    title([samplename(10:end) ' - Original - direction ' num2str(direc)])

    f2=figure;
    tiledlayout(1,1);
    nexttile;
    switch seriesdescription
        case '40u_DtiSE_2012_SPOIL10%'
            imshow(1e8*squeeze(ImageArray(slice,:,:, direc+2)), []);
        case 'STEAM_ShortDELTA_40'
            imshow(5e4*squeeze(ImageArray(slice,:,:, direc+1)), []);
    end
    cb=colorbar;
    cb.Label.String = 'Signal (a.u.)';
    cb.Ticks = 5:5:100;
    title([samplename(10:end) ' - Denoised - direction ' num2str(direc)])


    exportgraphics(f1, ...
        fullfile(folder, ['Direction_' num2str(direc) '_original.png']) ...
        ,'BackgroundColor','none','Resolution',300)

    exportgraphics(f2, ...
        fullfile(folder, ['Direction_' num2str(direc) '_denoised.png']) ...
        ,'BackgroundColor','none','Resolution',300)


end