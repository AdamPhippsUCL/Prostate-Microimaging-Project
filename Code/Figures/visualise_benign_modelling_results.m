% Display modelling results in benign tissue

clear;
projectfolder=pwd;


%% Sample

samplename = '20250524_UQ9';
%'20250224_UQ4'
% '20250407_UQ5'
%'20250414_UQ6'
% '20250522_UQ7'
% '20250523_UQ8'
% '20250524_UQ9

% MGE
ImageFolder = fullfile(pwd, 'Imaging Data', 'MAT DN', samplename);
MGE = load(fullfile(ImageFolder, '3DMGE_20u', 'avgImageArray.mat')).avgImageArray;


% % Displace MGE is needed (same as in ESL masks script)
% switch samplename
%     case '20250407_UQ5'
%         dx =-0;
%         dy = -10;
%         newMGE = zeros(size(MGE));
%         newMGE(:,1:240+dx,1:640+dy)=MGE(:,1-dx:240,1-dy:640);
%         MGE=newMGE;
% end


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

clear EPITHELIUM STROMA LUMEN


%% Load modelling results

sample_num = '9B';

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
measured_Db = load(fullfile(output_folder,  samplename, ModelName,  'Measured', 'Db')).measured_Db;

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
measured_ADC = load(fullfile(output_folder,  samplename, ModelName, 'Measured', 'D')).measured_D;

measured_ADC = measured_ADC(Bools);

% Load parameter estimates from predicted signals
pred_ADC = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'D')).pred_D;

pred_ADC = pred_ADC(Bools);




%% Load sample mask and set figure size

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


slices=7;

%% MGE + segmentations all in one figure


f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    nexttile;
    imshow(squeeze(MGE(16*(sl+0.5),MGE_disp_v1,MGE_disp_h))*1e8,[])
    % axis image
    % title([sample_num ' slice ' num2str(sl)])
    % cb=colorbar;
    % cb.Label.String='MGE signal (A.U.)';  


    hold on
    mask = imshow(squeeze(displaymasks(16*(sl+0.5),MGE_disp_v1,MGE_disp_h,:)));
    set(mask, 'AlphaData', 0.2)

    % set(gca, 'Color', [0 0 0])    % Black background
    % im = findobj(gca,'Type','image');
    % im(1).AlphaData = 1;
    axis on
    set(gca, 'XTick', [], 'YTick', [])
end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_MGE_Segmentation.png']) ...
    ,'BackgroundColor','none','Resolution',300)





%% ADC

ADC_mean_bias = load(fullfile(output_folder, 'Benign RL', 'ADC', 'ADC_mean_bias.mat')).ADC_bias;
ADC_sigma=load(fullfile(output_folder, 'Benign RL', 'ADC', 'ADC_sigma.mat')).ADC_sigma;
% sigma=0.218;

ADC_Measured = NaN*ones(size(SampleMask));
ADC_Measured(SampleMask==1) = measured_ADC;

ADC_Predicted = NaN*ones(size(SampleMask));
ADC_Predicted(SampleMask==1) = pred_ADC;


%% ADC map

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
    imshow(this_cs,[0.15 1.05])
    daspect([2,1,1])
    crameri('-bilbao')
    cb=colorbar;
    cb.Label.String='ADC x1e-3 mm^2/s';
    % title([sample_num ' slice ' num2str(sl)])

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    
    ax=gca();
    ax.FontSize=14;


end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_ADC.png']) ...
    ,'BackgroundColor','none','Resolution',300)


%% ADC difference

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(ADC_Measured(sl,disp_v1,disp_h)-ADC_Predicted(sl,disp_v1,disp_h));

    nexttile;
    imshow(this_cs,[ADC_mean_bias-3*ADC_sigma ADC_mean_bias+3*ADC_sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='ADC difference x1e-3 mm^2/s';

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('-vik', 'pivot', 0)

    % title([sample_num ' slice ' num2str(sl)])
    
    ax=gca();
    ax.FontSize=14;

end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_ADC_diff.png']) ...
    ,'BackgroundColor','none','Resolution',300)



%% fs

% Bias and sigma
fs_mean_bias = load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'fs_mean_bias.mat')).fs_bias;
fs_sigma=load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'fs_sigma.mat')).fs_sigma;

fs_Measured = NaN*ones(size(SampleMask));
fs_Measured(SampleMask==1) = measured_fs;

fs_Predicted = NaN*ones(size(SampleMask));
fs_Predicted(SampleMask==1) = pred_fs;



%% fs map

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
    imshow(this_cs,[-0.02 0.42])
    daspect([2,1,1])
    crameri('-bilbao')
    cb=colorbar;
    cb.Label.String='Sphere Fraction';
    % title([sample_num ' slice ' num2str(sl)])

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    
    ax=gca();
    ax.FontSize=14;

end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_fs.png']) ...
    ,'BackgroundColor','none','Resolution',300)


%% fs difference

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(fs_Measured(sl,disp_v1,disp_h)-fs_Predicted(sl,disp_v1,disp_h));

    nexttile;
    imshow(this_cs,[fs_mean_bias-3*fs_sigma fs_mean_bias+3*fs_sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='Sphere Fraction difference';
    cb.Ticks = [-0.2:0.1:0.2];

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('vik', 'pivot', fs_mean_bias)

    % title([sample_num ' slice ' num2str(sl)])

    
    ax=gca();
    ax.FontSize=14;
end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_fs_diff.png']) ...
    ,'BackgroundColor','none','Resolution',300)




%% Db

% Bias and sigma
Db_mean_bias = load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'Db_mean_bias.mat')).Db_bias;
Db_sigma=load(fullfile(output_folder, 'Benign RL', 'Ball+Sphere', 'Db_sigma.mat')).Db_sigma;


Db_Measured = NaN*ones(size(SampleMask));
Db_Measured(SampleMask==1) = measured_Db;

Db_Predicted = NaN*ones(size(SampleMask));
Db_Predicted(SampleMask==1) = pred_Db;




%% Db map

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
    imshow(this_cs,[0.52 1.48])
    daspect([2,1,1])
    crameri('-bilbao')
    cb=colorbar;
    cb.Label.String='D_{ball} x1e-3 mm^2/s';
    % title([sample_num ' slice ' num2str(sl)])

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])

    
    ax=gca();
    ax.FontSize=14;

end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_Db.png']) ...
    ,'BackgroundColor','none','Resolution',300)


%% Db difference

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    this_cs = squeeze(Db_Measured(sl,disp_v1,disp_h)-Db_Predicted(sl,disp_v1,disp_h));

    nexttile;
    imshow(this_cs,[Db_mean_bias-3*Db_sigma Db_mean_bias+3*Db_sigma])
    daspect([2,1,1])
    cb=colorbar;
    cb.Label.String='D_{ball} difference x1e-3 mm^2/s';
    cb.Ticks = [-0.4:0.2:0.4];

    set(gca, 'Color', [0 0 0])    % Black background
    im = findobj(gca,'Type','image');
    im.AlphaData = ~isnan(this_cs);
    axis on
    set(gca, 'XTick', [], 'YTick', [])
    crameri('-vik', 'pivot', 0)

    % title([sample_num ' slice ' num2str(sl)])
    
    ax=gca();
    ax.FontSize=14;
end

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Benign Parameter Maps', [sample_num '_Db_diff.png']) ...
    ,'BackgroundColor','none','Resolution',300)
