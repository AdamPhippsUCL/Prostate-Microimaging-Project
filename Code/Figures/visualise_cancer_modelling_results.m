% Display modelling results in cancer over MGE image of sample

clear;
projectfolder=pwd;


%% Load modelling results

samplename = '20260128_UQ10';
%'20250224_UQ4'
%'20250414_UQ6'
% '20260128_UQ10'
% '20260315_UQ11'

sample_num = '10M';

folder =  fullfile(projectfolder, 'Outputs', 'Signals', samplename);
COMP = load(fullfile(folder, "COMP.mat")).COMP;
SampleNums = load(fullfile(folder, "SampleNums.mat")).SampleNums;
    
% Cancer samples    
Bools = ismember(SampleNums, sample_num);
COMP = COMP(Bools, :);
    


% =========== Ball+Sphere

ModelName = 'Ball+Sphere';
schemename = '20250224_UQ4 AllDELTA';
fittingtechnique = 'LSQ';

% Output folder
output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );

% Load parameter estimates from measured signals
measured_fs = load(fullfile(output_folder, 'Measured', samplename, ModelName, 'fs')).measured_fs;
measured_Db = load(fullfile(output_folder, 'Measured',  samplename, ModelName, 'Db')).measured_Db;
measured_R = load(fullfile(output_folder, 'Measured',  samplename,  ModelName, 'R')).measured_R;

measured_fs = measured_fs(Bools);
measured_Db = measured_Db(Bools);
measured_R = measured_R(Bools);

% Load parameter estimates from predicted signals
pred_fs = load(fullfile(output_folder, 'Predicted', samplename, ModelName, 'fs')).pred_fs;
pred_Db = load(fullfile(output_folder, 'Predicted', samplename, ModelName, 'Db')).pred_Db;
pred_R = load(fullfile(output_folder, 'Predicted',  samplename, ModelName, 'R')).pred_R;

pred_fs = pred_fs(Bools);
pred_Db = pred_Db(Bools);
pred_R = pred_R(Bools);



% =========== ADC

ModelName = 'ADC';
schemename = '20250224_UQ4 AllDELTA';
fittingtechnique = 'LSQ';

% Output folder
output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );

% Load parameter estimates from measured signals
measured_ADC = load(fullfile(output_folder, 'Measured',  samplename, ModelName, 'D')).measured_D;

measured_ADC = measured_ADC(Bools);

% Load parameter estimates from predicted signals
pred_ADC = load(fullfile(output_folder, 'Predicted', samplename, ModelName, 'D')).pred_D;

pred_ADC = pred_ADC(Bools);


%% Load MGE image and sample mask

% MGE
ImageFolder = fullfile(pwd, 'Imaging Data', 'MAT DN', samplename);
MGE = load(fullfile(ImageFolder, '3DMGE_20u', 'avgImageArray.mat')).avgImageArray;

% Mask
MaskFolder = fullfile(pwd, 'Outputs', 'Masks', samplename, 'SE_b0_SPOIL5% (DS)');
SampleMask = load(fullfile(MaskFolder, [sample_num(end) 'MASK'])).([sample_num(end) 'MASK']);



%% ADC

[Xs, Ys] = meshgrid( ...
    linspace(1,size(SampleMask,3),size(MGE,3)), ...
    linspace(1,size(SampleMask,2),size(MGE,2)) ...
    );

xs=1:240;
ys=1:640;


ADC_Diffs = zeros(size(SampleMask));
ADC_Diffs(SampleMask==1) = measured_ADC-pred_ADC;

Diffs_high = imresize3(ADC_Diffs, size(MGE), Method="nearest");


% Central slice of MGE
sl = 120;

figure
ax1=axes;
imshow(squeeze(MGE(sl,xs,ys)), [])
hold on

Diffs_high_slice = squeeze(Diffs_high(sl,:,:));

% Create RGB overlay
overlay = zeros([size(Diffs_high_slice) 3]);

% Positive mask (red)
overlay(:,:,1) = Diffs_high_slice > 0;
% Negative mask (blue)
overlay(:,:,3) = Diffs_high_slice < 0;

% Display overlay
h = imshow(overlay);

% Transparency only where mask is non-zero
alpha = abs(Diffs_high_slice) > 0;

% Scale transparency by magnitude
alpha = mat2gray(abs(Diffs_high_slice));

set(h, 'AlphaData', 0.3 * alpha)


% caxis([-max(abs(Diffs_high_slice(:))) max(abs(Diffs_high_slice(:)))])
% colormap(gca, [linspace(0,1,256)' zeros(256,1) linspace(1,0,256)'])










% 
% pcolor(ax1, Xs(xs, ys), Ys(xs, ys), rescale(squeeze(MGE(sl,xs,ys)), 0,1))
% hold on
% shading flat; % Remove grid-like shading
% grid off;
% colormap(ax1,gray);
% xticks([])
% yticks([])
% daspect([8/3, 1, 1])

% ax2 = axes;
% m=pcolor(ax2, Xs(xs, ys), Ys(xs, ys), squeeze(Diffs_high(sl,xs,ys)) );
% caxis([-1, 1])
% shading flat; % Remove grid-like shading
% grid off;
% set(m, 'FaceAlpha', 0.3);
% linkaxes([ax1, ax2]);
% 
% imshow(squeeze(MGE(sl,:,:)), [])
% hold on
% 
% % Central slice of diffs
% sl=8;
% Diffs_slice = squeeze(ADC_Diffs(sl,:,:));
% 
% % upsample
% Diffs_slice_high = imresize(Diffs_slice, size(MGE, 2:3), Method="nearest");
% 
% ax2=axes;
% h=imshow(Diffs_slice_high); 
% clim([-1 1])
% colormap(gca, jet)
% 
% alpha = abs(Diffs_slice_high) > 0;
% set(h, 'AlphaData', 0.1 * alpha)
% 
% % set(h, 'AlphaData', 0.1)


%%

function c = redblue(m)
%REDBLUE    Shades of red and blue color map
%   REDBLUE(M), is an M-by-3 matrix that defines a colormap.
%   The colors begin with bright blue, range through shades of
%   blue to white, and then through shades of red to bright red.
%   REDBLUE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(redblue)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.
%   Adam Auton, 9th October 2009
if nargin < 1, m = size(get(gcf,'colormap'),1); end
if (mod(m,2) == 0)
    % From [0 0 1] to [1 1 1], then [1 1 1] to [1 0 0];
    m1 = m*0.5;
    r = (0:m1-1)'/max(m1-1,1);
    g = r;
    r = [r; ones(m1,1)];
    g = [g; flipud(g)];
    b = flipud(r);
else
    % From [0 0 1] to [1 1 1] to [1 0 0];
    m1 = floor(m*0.5);
    r = (0:m1-1)'/max(m1,1);
    g = r;
    r = [r; ones(m1+1,1)];
    g = [g; 1; flipud(g)];
    b = flipud(r);
end
c = [r g b]; 


end