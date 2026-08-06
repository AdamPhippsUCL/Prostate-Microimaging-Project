% Finding slice matches to histo

clear;
projectfolder = pwd;

samplename = '20250522_UQ7';

%'20250224_UQ4'
%'20250407_UQ5'
%'20250414_UQ6'
%'20250522_UQ7'
%'20250523_UQ8'
%'20250524_UQ9'
%'20260128_UQ10'
% '20260315_UQ11'
% '20260630_UQ12'
% '20260702_UQ13

% MGE image
MGE_seriesdescription = '3DMGE_20u';
MGE = load(fullfile(projectfolder, 'Imaging Data', 'MAT DN', samplename, '3DMGE_20u' , 'avgImageArray.mat')).avgImageArray;

figure
imshow(squeeze(MGE(120,:,:)), [])

figure;
sv1 = sliceViewer(MGE); 
sv1.DisplayRange = [0 2e-7]; 


%% High-res diffusion

% % Load FA maps
% FA = load(fullfile(projectfolder,'Outputs', 'Model Fitting', samplename, 'DTI', '40u_DtiSE_2012_SPOIL10% (20 micron)', 'dwFA.mat')).dwFA;
% D = load(fullfile(projectfolder,'Outputs', 'Model Fitting', samplename, 'DTI', '40u_DtiSE_2012_SPOIL10% (20 micron)', 'D.mat')).D;
% 
% figure;
% sv2 = sliceViewer(FA); 
% sv2.DisplayRange = [0 0.8]; 
% 
% figure;
% sv2 = sliceViewer(D); 
% sv2.DisplayRange = [0 2e-3]; 


%% Segmentation

% Mask folder
maskfolder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, '3DMGE_20u');

% LOAD ESL MASKs
EPITHELIUM = load(fullfile(maskfolder, 'EPITHELIUM.mat')).EPITHELIUM;
STROMA = load(fullfile(maskfolder, 'STROMA.mat')).STROMA;
LUMEN = load(fullfile(maskfolder, 'LUMEN.mat')).LUMEN;

% Create 4D mask (color coded)
displaymasks = zeros([size(EPITHELIUM), 3]);
displaymasks(:,:,:,1) = logical(EPITHELIUM);
displaymasks(:,:,:,2) = logical(STROMA);
displaymasks(:,:,:,3) = logical(LUMEN);


%% Save slice

sl=546;
MGE_slice = MGE(:,:,sl);

f=figure;
imshow(MGE_slice, [])

% Add segmentation
hold on
mask = imshow(squeeze(displaymasks(:,:,sl,:)));
set(mask, 'AlphaData', 0.2)

exportgraphics(f, 'test.png')
% D_slice = D(:,:,125);
% 
% f=figure;
% imshow(D_slice, [0 2e-3])
% exportgraphics(f, 'test.png')
% 
% 
% FA_slice = FA(:,:,95);
% 
% f=figure;
% imshow(FA_slice, [])
% exportgraphics(f, 'test.png')


%% Save segmentation

sl = 412;

f=figure;
imshow(squeeze(MGE(:,:,sl)),[]);
hold on
mask = imshow(squeeze(displaymasks(:,:,sl,:)));
set(mask, 'AlphaData', 0.2)




%% GOOD MATCHES

% ========== BENIGN SAMPLES

% === UQ6M

% MGE slice 460 with UQ6M 5

% MGE slice 534 with UQ6M 1


% === UQ7N

% MGE slice 546 with UQ7N 13


% === UQ8N

% MGE slice 614 with UQ8N 6


% === UQ9N

% MGE slice 412 with UQ9N 7


% ========== CANCER SAMPLES

% === UQ4B

% MGE slice 18 with UQ4B 8

% MGE slice 34 with UQ4B 7

% MGE slice 54 with UQ4B 6

% MGE slice 124 with UQ4B 4


% === UQ6N

% MGE slice 592 with UQ6N 2

% MGE slice 625 with UQ6N 4

% MGE slice 635 with UQ6N 5


% === UQ10B

% MGE slice 110 with UQ10B 1 (more visible on FA)

% MGE slice 95 with UQ10B 2

% MGE slice 40 with UQ10B 5


% == UQ10M

% MGE slice 282 and UQ10M 7

% === UQ10N

% MGE slice 504 with UQ10N 1

% MGE slice 547 with UQ10N 4

% MGE slice 566 with UQ10N 5


% === UQ11B

% MGE slice 233 with UQ11B 1

% MGE slice 195 with UQ11B 4

% MGE slice 153 with UQ11B 7

% MGE slice 125 with UQ11 8



% ==== UQ11N

% MGE slice 459 with 11N9
