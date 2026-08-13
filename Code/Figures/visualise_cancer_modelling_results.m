% Display modelling results in cancer over MGE image of sample

clear;
projectfolder=pwd;


%% Load modelling results

samplename = '20260315_UQ11';
%'20250224_UQ4'
%'20250414_UQ6'
% '20260128_UQ10'
% '20260315_UQ11'
% '20260630_UQ12'
% '20260702_UQ13

% MGE
ImageFolder = fullfile(pwd, 'Imaging Data', 'MAT DN', samplename);
MGE = load(fullfile(ImageFolder, '3DMGE_20u', 'avgImageArray.mat')).avgImageArray;



% % Mask folder
% maskfolder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, '3DMGE_20u');
% 
% % LOAD ESL MASKs
% EPITHELIUM = load(fullfile(maskfolder, 'EPITHELIUM.mat')).EPITHELIUM;
% STROMA = load(fullfile(maskfolder, 'STROMA.mat')).STROMA;
% LUMEN = load(fullfile(maskfolder, 'LUMEN.mat')).LUMEN;
% 
% % Create 4D mask (color coded)
% displaymasks = zeros([size(EPITHELIUM), 3]);
% displaymasks(:,:,:,1) = logical(EPITHELIUM);
% displaymasks(:,:,:,2) = logical(STROMA);
% displaymasks(:,:,:,3) = logical(LUMEN);
% 
% clear EPITHELIUM STROMA LUMEN



%% Load modelling results

% ====== ESL modelling

RESULTS = load(fullfile(projectfolder, 'Outputs', 'Model FItting', 'ESL signal profiles', 'Multi-sample', 'RESULTS.mat')).RESULTS;
E_ADC = RESULTS(and(strcmp({RESULTS.ModelName},'ADC'), strcmp({RESULTS.Component},'E'))).ModelParams(2);
E_fs = RESULTS(and(strcmp({RESULTS.ModelName},'Ball+Sphere'), strcmp({RESULTS.Component},'E'))).ModelParams(1);
E_Db = RESULTS(and(strcmp({RESULTS.ModelName},'Ball+Sphere'), strcmp({RESULTS.Component},'E'))).ModelParams(4);


sample_num = '11B';

folder =  fullfile(projectfolder, 'Outputs', 'Signals', samplename);
SampleNums = load(fullfile(folder, "SampleNums.mat")).SampleNums;  
Bools = ismember(SampleNums, sample_num);


% =========== Ball+Sphere

ModelName = 'Ball+Sphere';
schemename = '20250224_UQ4 AllDELTA';
fittingtechnique = 'LSQ';

% Output folder
output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );


% Load parameter estimates from measured signals
measured_fs = load(fullfile(output_folder, samplename, ModelName, 'Measured', 'fs')).measured_fs;
measured_Db = load(fullfile(output_folder, samplename, ModelName, 'Measured', 'Db')).measured_Db;

measured_fs = measured_fs(Bools);
measured_Db = measured_Db(Bools);


% Load parameter estimates from predicted signals
pred_fs = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'fs')).pred_fs;
pred_Db = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'Db')).pred_Db;

pred_fs = pred_fs(Bools);
pred_Db = pred_Db(Bools);


% =========== ADC

ModelName = 'ADC';
schemename = '20250224_UQ4 AllDELTA';
fittingtechnique = 'LSQ';

% Output folder
output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );

% Load parameter estimates from measured signals
measured_ADC = load(fullfile(output_folder, samplename, ModelName, 'Measured', 'D')).measured_D;

measured_ADC = measured_ADC(Bools);

% Load parameter estimates from predicted signals
pred_ADC = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'D')).pred_D;

pred_ADC = pred_ADC(Bools);



%% Load sample mask

% Mask
MaskFolder = fullfile(pwd, 'Outputs', 'Masks', samplename, 'SE_b0_SPOIL5% (DS)');
SampleMask = load(fullfile(MaskFolder, [sample_num(end) 'MASK'])).([sample_num(end) 'MASK']);

disp_inds_h = find(sum(SampleMask , 1:2)>0);
disp_h = [min(disp_inds_h)-1:max(disp_inds_h)+1];
h = length(disp_h);

MGE_disp_h = (min(disp_inds_h)-2)*8+1:(max(disp_inds_h)+1)*8;

disp_inds_v1 = find(sum(SampleMask , [1,3])>0);
disp_v1 = [min(disp_inds_v1)-1:max(disp_inds_v1)+1];
v1=length(disp_v1);

MGE_disp_v1 = (min(disp_inds_v1)-2)*2*8+1:(max(disp_inds_v1)+1)*2*8;


disp_inds_v2 = find(sum(SampleMask , [2,3])>0);
disp_v2 = [min(disp_inds_v2)-1:max(disp_inds_v2)+1];
v2=length(disp_v2);

MGE_disp_v2 = (min(disp_inds_v2)-2)*2*8+1:(max(disp_inds_v2)+1)*2*8;

axv = 0.6;
axh = 0.5*(h/v1)*axv;


% Sagittal slices to show
slices = 8;



%% MGE axial slice

MGE_axial_slice = 195;

f=figure;
f.Position = [488   242   500   500];
ax=axes;
ax.Position = [0.1,0.1,0.8,0.8];

imshow(MGE(MGE_disp_v2, MGE_disp_v1, MGE_axial_slice)*1e8, [])

cb=colorbar;
cb.Label.String = 'Gradient echo signal (a.u.)';   

ax.FontSize=14;

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_MGE_ax_' num2str(MGE_axial_slice) '.png']), ...
    'BackgroundColor','none','Resolution',300)

%% MGE sagittal slices

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    nexttile;
    imshow(squeeze(MGE(16*(sl-0.5),MGE_disp_v1,MGE_disp_h))*1e8,[])
    % axis image
    title([sample_num ' slice ' num2str(sl)])
    cb=colorbar;
    cb.Label.String='MGE signal (A.U.)';   

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = 1;
    axis on
    set(gca, 'XTick', [], 'YTick', [])
end


% exportgraphics(f, ...
%     fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_MGE.png']) ...
%     ,'BackgroundColor','none','Resolution',300)



%% ADC 

ADC_mean_bias_highE = load(fullfile(output_folder, 'Benign RL', 'ADC', 'ADC_mean_bias_highE.mat')).ADC_bias_highE;
ADC_sigma_highE=load(fullfile(output_folder, 'Benign RL', 'ADC', 'ADC_sigma_highE.mat')).ADC_sigma_highE;

ADC_pivot=E_ADC+ADC_mean_bias_highE;
ADC_sigma=ADC_sigma_highE;

ADC_Measured = NaN*ones(size(SampleMask));
ADC_Measured(SampleMask==1) = measured_ADC;

ADC_Predicted = NaN*ones(size(SampleMask));
ADC_Predicted(SampleMask==1) = pred_ADC;


%% ADC Axial slice

% Find  slice
dMRI_axial_slice = ceil(MGE_axial_slice/8);

this_map = ADC_Measured(disp_v2, disp_v1, dMRI_axial_slice);


f=figure;
f.Position = [488   242   500   500];
ax=axes;
ax.Position = [0.1,0.1,0.8,0.8];

imshow(this_map, [ADC_pivot-3*ADC_sigma ADC_pivot+3*ADC_sigma])

cb=colorbar;
cb.Label.String='D \mum^2/ms';

set(gca, 'Color', [0 0 0])    % Black background
im = findobj(gca,'Type','image');
im.AlphaData = ~isnan(this_map);
axis on
set(gca, 'XTick', [], 'YTick', [])
crameri('-vik', 'pivot', ADC_pivot)

ax.FontSize=14;

exportgraphics(f, ...
     fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_ADC_ax_' num2str(dMRI_axial_slice) '.png']), ...
    'BackgroundColor','none','Resolution',300)



%% ADC Sagittal slices

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(ADC_Measured(sl,disp_v1,disp_h));
    
    nexttile;
    % imshow(this_cs,[0 lim_max])
    imshow(this_cs,[pivot-3*sigma pivot+3*sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='ADC x1e-3 mm^2/s';
    
    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('-vik', 'pivot', pivot)
    
    title([sample_num ' slice ' num2str(sl)])


end

% exportgraphics(f, ...
%     fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_ADC.png']) ...
%     ,'BackgroundColor','none','Resolution',300)



%% fs 

fs_mean_bias_highE = load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'fs_mean_bias_highE.mat')).fs_bias_highE;
fs_sigma_highE=load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'fs_sigma_highE.mat')).fs_sigma_highE;

fs_pivot=E_fs+fs_mean_bias_highE;
fs_sigma=fs_sigma_highE;

fs_Measured = NaN*ones(size(SampleMask));
fs_Measured(SampleMask==1) = measured_fs;


%% fs Axial slice

% Find  slice
dMRI_axial_slice = ceil(MGE_axial_slice/8);

this_map = fs_Measured(disp_v2, disp_v1, dMRI_axial_slice);


f=figure;
f.Position = [488   242   500   500];
ax=axes;
ax.Position = [0.1,0.1,0.8,0.8];

imshow(this_map, [fs_pivot-3*fs_sigma fs_pivot+3*fs_sigma])

cb=colorbar;
cb.Label.String='Sphere Fraction';
cb.Ticks = 0.2:0.1:0.5;

set(gca, 'Color', [0 0 0])    % Black background
im = findobj(gca,'Type','image');
im.AlphaData = ~isnan(this_map);
axis on
set(gca, 'XTick', [], 'YTick', [])
crameri('vik', 'pivot', fs_pivot)

ax.FontSize=14;

exportgraphics(f, ...
     fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_fs_ax_' num2str(dMRI_axial_slice) '.png']), ...
    'BackgroundColor','none','Resolution',300)

%% fs All in one figure

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(fs_Measured(sl,disp_v1,disp_h));
    
    nexttile;
    % imshow(this_cs,[0 lim_max])
    imshow(this_cs,[pivot-3*sigma pivot+3*sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='Sphere Fraction';
    
    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('vik', 'pivot', pivot)
    
    title([sample_num ' slice ' num2str(sl)])


end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_fs.png']) ...
    ,'BackgroundColor','none','Resolution',300)



%% Db

Db_mean_bias_highE = load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'Db_mean_bias_highE.mat')).Db_bias_highE;
Db_sigma_highE=load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'Db_sigma_highE.mat')).Db_sigma_highE;

Db_pivot=E_Db+Db_mean_bias_highE;
Db_sigma=Db_sigma_highE;

Db_Measured = NaN*ones(size(SampleMask));
Db_Measured(SampleMask==1) = measured_Db;


%% Db Axial slice

% Find  slice
dMRI_axial_slice = ceil(MGE_axial_slice/8);

this_map = Db_Measured(disp_v2, disp_v1, dMRI_axial_slice);


f=figure;
f.Position = [488   242   500   500];
ax=axes;
ax.Position = [0.1,0.1,0.8,0.8];

imshow(this_map, [Db_pivot-3*Db_sigma Db_pivot+3*Db_sigma])

cb=colorbar;
cb.Label.String='D_{ball} \mum^2/ms';
cb.Ticks = 0.2:0.2:1;

set(gca, 'Color', [0 0 0])    % Black background
im = findobj(gca,'Type','image');
im.AlphaData = ~isnan(this_map);
axis on
set(gca, 'XTick', [], 'YTick', [])
crameri('-vik', 'pivot', Db_pivot)

ax.FontSize=14;

exportgraphics(f, ...
     fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_Db_ax_' num2str(dMRI_axial_slice) '.png']), ...
    'BackgroundColor','none','Resolution',300)


%% Db All in one figure

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(Db_Measured(sl,disp_v1,disp_h));
    
    nexttile;
    % imshow(this_cs,[0 lim_max])
    imshow(this_cs,[pivot-3*sigma pivot+3*sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='D_{ball} x1e-3 mm^2/s';
    
    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('-vik', 'pivot', pivot)
    
    title([sample_num ' slice ' num2str(sl)])


end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Cancer Parameter Maps', [sample_num '_Db.png']) ...
    ,'BackgroundColor','none','Resolution',300)
