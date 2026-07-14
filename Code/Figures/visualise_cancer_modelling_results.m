% Display modelling results in cancer over MGE image of sample

clear;
projectfolder=pwd;


%% Load modelling results

samplename = '20250522_UQ7';
%'20250224_UQ4'
%'20250414_UQ6'
% '20250522_UQ7'
% '20250523_UQ8'
% '20250524_UQ9
% '20260128_UQ10'
% '20260315_UQ11'
% '20260630_UQ12'
% '20260702_UQ13

% MGE
ImageFolder = fullfile(pwd, 'Imaging Data', 'MAT DN', samplename);
MGE = load(fullfile(ImageFolder, '3DMGE_20u', 'avgImageArray.mat')).avgImageArray;

% Segmentation
mask =

%% Load modelling results

sample_num = '7B';

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
measured_fs = load(fullfile(output_folder, 'Measured', samplename, ModelName, 'fs')).measured_fs;
measured_Db = load(fullfile(output_folder, 'Measured',  samplename, ModelName, 'Db')).measured_Db;

measured_fs = measured_fs(Bools);
measured_Db = measured_Db(Bools);


% Load parameter estimates from predicted signals
pred_fs = load(fullfile(output_folder, 'Predicted', samplename, ModelName, 'fs')).pred_fs;
pred_Db = load(fullfile(output_folder, 'Predicted', samplename, ModelName, 'Db')).pred_Db;

pred_fs = pred_fs(Bools);
pred_Db = pred_Db(Bools);


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



%% MGE individual figures

slices=6:10;

for sl=slices

    f=figure;
    fpos = f.Position;
    fpos(3)=(axh/axv)*fpos(3);
    f.Position = fpos;
    tiledlayout(1,1);
    nexttile;
    imshow(squeeze(MGE(16*(sl+0.5),MGE_disp_v1,MGE_disp_h)),[])
    title([sample_num ' slice ' num2str(sl)])
    cb=colorbar;
    cb.Label.String='MGE signal (A.U.)';   

    % exportgraphics(f, ...
    %     fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_MGE_sl' num2str(sl) '.png']) ...
    %     ,'BackgroundColor','none','Resolution',300)


end


%% MGE all in one figure

slices=6:9;


f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
% fpos(2)=0;
f.Position = fpos;
tiledlayout(numel(slices),1, 'TileSpacing','compact');

for sl=slices

    nexttile;
    imshow(squeeze(MGE(16*(sl+0.5),MGE_disp_v1,MGE_disp_h))*1e8,[])
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


exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_MGE.png']) ...
    ,'BackgroundColor','none','Resolution',300)



%% ADC 

pivot=0.462;
sigma=0.218;

ADC_Measured = NaN*ones(size(SampleMask));
ADC_Measured(SampleMask==1) = measured_ADC;


%% ADC Individual figures

slices=4:11;

for sl=slices
    this_cs = squeeze(ADC_Measured(sl,disp_v1,disp_h));
    
    f=figure;
    fpos = f.Position;
    fpos(3)=(axh/axv)*fpos(3);
    f.Position = fpos;
    tiledlayout(1,1);
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

    % exportgraphics(f, ...
    %     fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_ADC_sl' num2str(sl) '.png']) ...
    %     ,'BackgroundColor','none','Resolution',300)

end



%% ADC All in one figure

slices=6:9;

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
% fpos(2)=0;
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

exportgraphics(f, ...
    fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_ADC.png']) ...
    ,'BackgroundColor','none','Resolution',300)



%% fs 

% Display measured modelling results
pivot=0.254;
sigma=0.0629;

fs_Measured = NaN*ones(size(SampleMask));
fs_Measured(SampleMask==1) = measured_fs;


%% Individual figures

% First cross section
slices=5:8;

for sl=slices

    this_cs = squeeze(fs_Measured(sl,disp_v1,disp_h));
    
    f=figure;
    fpos = f.Position;
    fpos(3)=(axh/axv)*fpos(3);
    f.Position = fpos;
    tiledlayout(1,1);
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


    % exportgraphics(f, ...
    %     fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_fs_sl' num2str(sl) '.png']) ...
    %     ,'BackgroundColor','none','Resolution',300)

end


%% fs All in one figure

slices=6:9;

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
% fpos(2)=0;
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
    fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_fs.png']) ...
    ,'BackgroundColor','none','Resolution',300)


%% Db

% Display measured modelling results
pivot=0.657;
sigma=0.209;

Db_Measured = NaN*ones(size(SampleMask));
Db_Measured(SampleMask==1) = measured_Db;


%% Db individual figures

% First cross section
slices=6:10;

for sl=slices

    this_cs = squeeze(Db_Measured(sl,disp_v1,disp_h));
    
    f=figure;
    fpos = f.Position;
    fpos(3)=(axh/axv)*fpos(3);
    f.Position = fpos;
    tiledlayout(1,1);
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

    exportgraphics(f, ...
        fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_Db_sl' num2str(sl) '.png']) ...
        ,'BackgroundColor','none','Resolution',300)

end


%% Db All in one figure

slices=6:9;

f=figure;
fpos = f.Position;
fpos(3)=(axh/axv)*fpos(3);
fpos(4)=numel(slices)*fpos(4);
% fpos(2)=0;
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
    fullfile(projectfolder, 'Thesis Figures', 'Parameter Maps', [sample_num '_Db.png']) ...
    ,'BackgroundColor','none','Resolution',300)
