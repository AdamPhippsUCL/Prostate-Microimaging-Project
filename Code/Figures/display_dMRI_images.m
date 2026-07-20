% Script to display dMRI images

clear;
projectfolder = pwd;

%% Sample and image details

SampleName = '20250224_UQ4';

SeriesDescriptions = {...
    'SE_b0_SPOIL5%',...
    'STEAM_ShortDELTA_15',...
    'STEAM_LongDELTA_80',...
    'STEAM_LongDELTA_120',...
};

ImagingDataFolder = fullfile(projectfolder, 'Imaging Data', 'MAT DN');



%% b=0 

% SE b=0
sindx = 1;
SeriesDescription = SeriesDescriptions{sindx};

% Load Images
ImageArrayDS = load(fullfile(ImagingDataFolder, SampleName, [SeriesDescription ' (DS)'], 'axialImageArray')).ImageArray;
ImageArray = load(fullfile(ImagingDataFolder, SampleName, SeriesDescription, 'axialImageArray')).ImageArray;

% Mean signal
b0DS_MeanSignal = mean(ImageArrayDS(:));
b0_MeanSignal = mean(ImageArray(:));

% Average over 4th dimension
avgImageArray = mean(ImageArray,4);
avgImageArrayDS = mean(ImageArrayDS,4);

% == Display central slice

% Original
slice = round(size(avgImageArray,1)/2);
f1=figure;
f1.Position = [680   458   600   280];
ax = axes;
imshow(squeeze(avgImageArray(slice,:,:)), [0 6.2e-3]);
ax.Position = [0.025         0    0.95    1];
cb=colorbar;
cb.Label.String ='Signal (a.u.)';
title('b=0 (Original)')

% Downsampled
slice = round(size(avgImageArrayDS,1)/2);
f2=figure;
f2.Position = [680   458   600   280];
ax = axes;
imshow(squeeze(avgImageArrayDS(slice,:,:)), [0 6.2e-3]);
ax.Position = [0.025         0    0.95    1];
daspect([2,1,1])
cb=colorbar;
cb.Label.String ='Signal (a.u.)';
title('b=0 (Downsampled)')

folder = fullfile(projectfolder, 'Thesis Figures', 'dMRI Images', SampleName);
mkdir(folder)

saveas(f1, fullfile(folder, [SeriesDescription '.png']))
saveas(f2, fullfile(folder, [SeriesDescription ' (DS).png']))



%% b>0

for sindx = 2:length(SeriesDescriptions)

    SeriesDescription = SeriesDescriptions{sindx};

    switch SeriesDescription
        case {'SE_b0_SPOIL5%'}
            Sequence = 'b=0';
        case {'STEAM_ShortDELTA_15'}
            Sequence = 'b=1000 s/mm^2, \Delta=15 ms';
        case {'STEAM_LongDELTA_80'}
            Sequence = 'b=1500 s/mm^2, \Delta=80 ms';
        case {'STEAM_LongDELTA_120'}
            Sequence = 'b=2000 s/mm^2, \Delta=120 ms';
    end

    % == DOWNSAMPLED 

    % Load axial image
    ImageArrayDS = load(fullfile(ImagingDataFolder, SampleName, [SeriesDescription ' (DS)'], 'axialImageArray')).ImageArray;

    % Average over 4th dimension
    avgImageArrayDS = mean(ImageArrayDS(:,:,:,2:end),4);
    MeanSignalDS = mean(avgImageArrayDS(:));

    % Mean b=0 signal
    this_b0DS = ImageArrayDS(:,:,:,1);
    thisb0DS_MeanSignal = mean(this_b0DS(:));

    %  Rescaled Image (to make colorbars agree)
    RS_avgImageArray_DS = avgImageArrayDS*(b0DS_MeanSignal/thisb0DS_MeanSignal);
    
    % Display
    slice = round(size(RS_avgImageArray_DS,1)/2);
    f1=figure;
    f1.Position = [680   458   600   280];
    ax = axes;
    imshow(squeeze(RS_avgImageArray_DS(slice,:,:)), [0 2.8e-3]);
    ax.Position = [0.025         0    0.95    1];
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String = 'Signal (a.u.)';
    title([Sequence ' (Downsampled)'])

    % == Original 

    % Load axial image
    ImageArray = load(fullfile(ImagingDataFolder, SampleName, SeriesDescription, 'axialImageArray')).ImageArray;

    % Average over 4th dimension
    avgImageArray = mean(ImageArray(:,:,:,2:end),4);
    MeanSignal = mean(avgImageArray(:));

    % Mean b=0 signal
    this_b0 = ImageArray(:,:,:,1);
    thisb0_MeanSignal = mean(this_b0(:));

    %  Rescaled Image
    RS_avgImageArray = avgImageArray*(b0_MeanSignal/thisb0_MeanSignal);
    
    % Display
    slice = round(size(RS_avgImageArray,1)/2);
    f2=figure;
    f2.Position = [680   458   600   280];
    ax = axes;
    imshow(squeeze(RS_avgImageArray(slice,:,:)), [0 2.8e-3]);
    ax.Position = [0.025         0    0.95    1];
    daspect([1,1,1])
    cb=colorbar;
    cb.Label.String = 'Signal (a.u.)';
    title([Sequence ' (Original)'])

    saveas(f1, fullfile(folder, [SeriesDescription ' (DS).png']))
    saveas(f2, fullfile(folder, [SeriesDescription '.png']))

end