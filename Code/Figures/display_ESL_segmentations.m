% Script to show example ESL masks

clear;
projectfolder = pwd;

% Sample
samplename = '20250524_UQ9';
%'20250224_UQ4'
%'20250407_UQ5'
%'20250414_UQ6'
%'20250522_UQ7'
%'20250523_UQ8'
%'20250524_UQ9'

% MGE image
MGE_seriesdescription = '3DMGE_20u';
MGE = load(fullfile(projectfolder, 'Imaging Data', 'MAT DN', samplename, MGE_seriesdescription, 'avgImageArray.mat')).avgImageArray;

% dwFA
dwFA = load(fullfile(projectfolder, 'Outputs', 'Model Fitting', samplename, 'DTI', '40u_DtiSE_2012_SPOIL10% (20 micron)', 'dwFA.mat')).dwFA;

% Mask folder
maskfolder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, MGE_seriesdescription);

% LOAD ESL MASKs
EPITHELIUM = load(fullfile(maskfolder, 'EPITHELIUM.mat')).EPITHELIUM;
STROMA = load(fullfile(maskfolder, 'STROMA.mat')).STROMA;
LUMEN = load(fullfile(maskfolder, 'LUMEN.mat')).LUMEN;

% Create 4D mask (color coded)
displaymasks = zeros([size(EPITHELIUM), 3]);
displaymasks(:,:,:,1) = logical(EPITHELIUM);
displaymasks(:,:,:,2) = logical(STROMA);
displaymasks(:,:,:,3) = logical(LUMEN);


%% Define slice and region to present

% Good for figure: 9N, 9B, 8M

% SAMPLE NUMBER
snum = 'UQ9N';

sl=120;
switch snum
    case 'UQ4B'
        xs = 40:220;
        ys = 1:240;
    case 'UQ4M'
        xs = 48:228;
        ys = 200:420;        
    case 'UQ4N'
        xs = 40:218;
        ys = 410:630;
    case 'UQ6B'
        xs = 40:220;
        ys = 40:260;
    case 'UQ6M'
        xs = 30:210;
        ys = 284:504;
    case 'UQ7B'
        xs = 40:220;
        ys = 10:240;
    case 'UQ7M'
        xs = 40:220;
        ys = 240:480;
    case 'UQ7N'
        xs = 40:220;
        ys = 380:620;
    case 'UQ8B'
        xs = 30:210;
        ys = 17:220;
    case 'UQ8M'
        xs = 30:210;
        ys = 195:435;
        rotdirec=-1;
    case 'UQ8N'
        xs = 30:210;
        ys = 440:620;
    case 'UQ9B'
        xs = 30:210;
        ys = 80:320;
        rotdirec=1;
    case 'UQ9N'
        xs = 30:210;
        ys = 325:565;
        rotdirec=1;
end





f1=figure;
tiledlayout(1,1, "TileSpacing","tight")
nexttile;
img=rot90(squeeze(MGE(sl,xs,ys)), rotdirec)*1e8;
imshow(img,[0 1e8*prctile(squeeze(MGE(sl,xs,ys)), 99.9, 'all')]);
cb=colorbar;
cb.Label.String = 'MGE signal (A.U.)';
cb.Ticks = 2:2:20;

f2=figure;
tiledlayout(1,1, "TileSpacing","tight")
nexttile;
img = 1e3*rot90(squeeze(dwFA(sl,xs,ys)), rotdirec);
imshow(img,[0, 0.55]);%1e4*[0 5.5e-4]);
cb=colorbar;
cb.Label.String='MD \times FA (\mum^2/ms)';
cb.Ticks = 0.1:0.1:1;

f3=figure;
tiledlayout(1,1, "TileSpacing","tight")
nexttile;
img = rot90(squeeze(MGE(sl,xs,ys)), rotdirec);
imshow(img,[0 prctile(squeeze(MGE(sl,xs,ys)), 99.9, 'all')]);
hold on
dispmask = rot90(squeeze(displaymasks(sl,xs,ys,:)), rotdirec);
mask = imshow(dispmask);
set(mask, 'AlphaData', 0.2)


%% Save

folder = fullfile(projectfolder, 'Thesis Figures', 'Benign Segmentations', snum);
mkdir(folder);

exportgraphics(f1, ...
    fullfile(folder, 'MGE.png'), ...
   'BackgroundColor','none','Resolution',300)

exportgraphics(f2, ...
    fullfile(folder, 'dwFA.png'), ...
   'BackgroundColor','none','Resolution',300)

exportgraphics(f3, ...
    fullfile(folder, 'segmentation.png'), ...
   'BackgroundColor','none','Resolution',300)

% saveas(f1, fullfile(folder, 'MGE.png'));
% saveas(f2, fullfile(folder, 'dwFA.png'));
% saveas(f3, fullfile(folder, 'segmentation.png'));