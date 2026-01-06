% Script to calculate T2 values from initial MSME sequence

clear;
projectfolder = pwd;

%% Imaging data

SampleName = '20250524_UQ9';

SeriesDescription = 'T2_MSME';

% Imaging data folder 
ImagingDataFolder = fullfile(projectfolder, 'Imaging Data');

ImageArray = load(fullfile(ImagingDataFolder, 'MAT', SampleName, SeriesDescription, 'ImageArray.mat')).ImageArray;
dinfo = load(fullfile(ImagingDataFolder, 'MAT', SampleName, SeriesDescription, 'dinfo.mat')).dinfo;


%% Reformat

% Stack ImageArray by slices
Echos = unique([dinfo(:).EchoTime]);
NEcho = length(Echos);
Slices = unique([dinfo(:).sl]);
NSlices = length(Slices);

newImageArray = zeros([size(ImageArray, 1:2), NSlices, NEcho]);

for slindx = 1:NSlices

    newImageArray(:,:,slindx,:) = ImageArray(:,:,[dinfo(:).sl]==Slices(slindx));

end

ImageArray = newImageArray;
clear newImageArray;


%% T2 calculation (log fit)

logImageArray = log(ImageArray);

% Reshape
logImageArray_flat = reshape(logImageArray, [prod(size(logImageArray, 1:3)), NEcho]);


% Linear fit
X = [Echos', ones(size(Echos'))];
Y = logImageArray_flat';

coeffs = (X\Y)';

grads = coeffs(:,1);
intrcpts = coeffs(:,2);


T2s = -1./grads;


T2s = reshape(T2s, [size(ImageArray, 1:3), 1]);



%% Display slices

aspct = 1./dinfo(1).PixelSpacing;

samplesROI = zeros([size(T2s)]);

f=figure;
ax = axes;
imshow(T2s(:,:,1),[0 75])
daspect([flipud(aspct)', 1]);
ax.Position=[0.02, 0.02, 0.96, 0.92];
cb=colorbar;
cb.Label.String = 'T2 (ms)';
cb.Position = [0.65   0.02000    0.0250    0.960];
title([SampleName ' (1)'], Interpreter="none", FontSize=9);
saveas(f, fullfile(projectfolder, 'Figures', 'Reviewer Response', 'T2_slice_1.png'))

sampleROI = drawrectangle();
samplesROI(:,:,1) = createMask(sampleROI);


f=figure;
ax = axes;
imshow(T2s(:,:,2),[0 75])
daspect([flipud(aspct)', 1]);
ax.Position=[0.02, 0.02, 0.96, 0.92];
cb=colorbar;
cb.Label.String = 'T2 (ms)';
cb.Position = [0.65   0.02000    0.0250    0.960];
title([SampleName ' (2)'], Interpreter="none", FontSize=9);
saveas(f, fullfile(projectfolder, 'Figures', 'Reviewer Response', 'T2_slice_2.png'))

sampleROI = drawrectangle();
samplesROI(:,:,2) = createMask(sampleROI);



% T2 distribution
f=figure;
histogram(T2s(logical(samplesROI)), 0:1:100)
ylabel('Counts')
xlabel('T2 (ms)')
title(SampleName, Interpreter="none");
hold on
xline(14, '--')
saveas(f, fullfile(projectfolder, 'Figures', 'Reviewer Response', 'T2_dist.png'))