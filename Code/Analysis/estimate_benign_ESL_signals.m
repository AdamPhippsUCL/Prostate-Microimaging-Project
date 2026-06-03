% Script to estimate ESL signal in benign tissue using linear model

clear;
projectfolder = pwd;

%% Sample and image details

% Sample
multisample = true;
SampleNames = {'20250224_UQ4', '20250407_UQ5', '20250414_UQ6', '20250522_UQ7', '20250523_UQ8', '20250524_UQ9'};

schemename = '20250224_UQ4 AllDELTA';
schemesfolder = fullfile(projectfolder, 'Schemes');
load(fullfile(schemesfolder, schemename));
nscheme = length(scheme);
Nimg = nscheme;


SeriesDescriptions = {
    'SE_b0_SPOIL5% (DS)',...
    'STEAM_ShortDELTA_15 (DS)',...
    'STEAM_ShortDELTA_20 (DS)',...
    'STEAM_ShortDELTA_30 (DS)',...
    'STEAM_ShortDELTA_40 (DS)',...
    'STEAM_ShortDELTA_50 (DS)',...
    'STEAM_LongDELTA_40 (DS)',...
    'STEAM_LongDELTA_60 (DS)',...
    'STEAM_LongDELTA_80 (DS)',...
    'STEAM_LongDELTA_100 (DS)',...
    'STEAM_LongDELTA_120 (DS)'...
};

% Use denoised data
UseDenoisedData = true;

% Imaging data folder 
switch UseDenoisedData
    case true
        ImagingDataFolder = fullfile(projectfolder, 'Imaging Data', 'MAT DN');     
    case false
        ImagingDataFolder = fullfile(projectfolder, 'Imaging Data', 'MAT');   
end


composition = [];
imgs = [];
samplenums = [];

for sindx = 1:length(SampleNames)

    samplename = SampleNames{sindx};

    % == Load masks

    baseseriesdescription = '3DMGE_20u';
    baseimg = load(fullfile(ImagingDataFolder, samplename, baseseriesdescription, 'avgImageArray.mat' )).avgImageArray;

    maskfolder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, baseseriesdescription);
    EPITHELIUM = load(fullfile(maskfolder, 'EPITHELIUM.mat')).EPITHELIUM;
    STROMA = load(fullfile(maskfolder, 'STROMA.mat')).STROMA;
    LUMEN = load(fullfile(maskfolder, 'LUMEN.mat')).LUMEN;
    szbase = size(EPITHELIUM);


    % ======= Load normalised images

    % b=0 image
    seriesindx = 1;
    SeriesDescription = SeriesDescriptions{seriesindx};
    thisfolder = fullfile(ImagingDataFolder, samplename, SeriesDescription);
    b0img = load(fullfile(thisfolder, 'axialImageArray.mat')).ImageArray;  
    szimg = size(b0img, 1:3);


    % Initialise array for normalised images
    IMGS = ones([Nimg, szimg]);

    for seriesindx = 2:length(SeriesDescriptions)

        SeriesDescription = SeriesDescriptions{seriesindx};
        thisfolder = fullfile(ImagingDataFolder, samplename, SeriesDescription);

        % Load normalised image array
        normimg = load(fullfile(thisfolder, 'normalisedImageArray.mat')).ImageArray;
        IMGS(seriesindx,:,:,:) =  normimg;

    end


    disp('')



    szmap = szimg;

    % LOAD COMPOSITION AND SAMPLE MASKS
    folder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, SeriesDescriptions{1});
    COMPOSITION = load(fullfile(folder, 'COMPOSITION.mat')).COMPOSITION;
    NMASK = load(fullfile(folder, 'NMASK.mat')).NMASK;
    MMASK = load(fullfile(folder, 'MMASK.mat')).MMASK;
    BMASK = load(fullfile(folder, 'BMASK.mat')).BMASK;


    
    % Select voxels IN BENIGN SAMPLES AND WITH NON-ZERO composition

    % Cancer samples = UQ4B, UQ4M, UQ6N
    switch samplename(end-2:end)
        case 'UQ4'
            % Only include sample N
            COMPOSITION = COMPOSITION.*double(NMASK);
        case 'UQ6'
            % Only include samples B and M
            COMPOSITION = COMPOSITION.*(double(BMASK)+double(MMASK));
    end

    % Select voxels with non-zero composition
    thiscomposition = reshape(COMPOSITION,[prod(szmap), 3]);
    bool =  sum(thiscomposition,2)>0;
    thiscomposition = thiscomposition(bool, :);

    thisimgs = reshape(IMGS, [Nimg, prod(szimg)]);
    thisimgs = thisimgs(:,bool);

    % Sample masks
    this_bmask = BMASK(:);
    this_bmask = this_bmask(bool);
    this_mmask = MMASK(:);
    this_mmask = this_mmask(bool);
    this_nmask = NMASK(:);
    this_nmask = this_nmask(bool);

    samplenums = [samplenums; (3*sindx-2)*this_bmask + (3*sindx-1)*this_mmask + (3*sindx)*this_nmask];
    composition = [composition; thiscomposition];
    imgs = [imgs, thisimgs];

    

end


%% ESL signal estimation (Linear model fitting)

% Predictors [fs, fg, fl]
X = composition;

% Linear regression function (at bottom of script)
func = @(b, X) signal_func(b, X);

% Initial guess and bounds [S_e, S_s, S_l]
beta0 = [0.5, 0.5, 0.5];
lb = [0,0,0];
ub=[1,1,1];

% Lumen diffusivity
Dl = 2.0e-3;
err = 0.001;

% Initialise array for signal measurements
signals = zeros(3, Nimg, 4);

% Initialise RESULTS structure
RESULTS = struct();

for imgindx = 1:Nimg

    if multisample
        RESULTS(imgindx).SampleName = SampleNames;
    else
        RESULTS(imgindx).SampleName = samplename;   
    end

    RESULTS(imgindx).bval = scheme(imgindx).bval;
    RESULTS(imgindx).DELTA = scheme(imgindx).DELTA;

    if imgindx == 1
        signals(:,imgindx,1)=1;
        signals(:,imgindx,2)=0;
        continue
    end

    y = transpose(imgs(imgindx, :));

    % Set lumen signal
    Sl = exp(-scheme(imgindx).bval*Dl);
    lb(3)=Sl-err;
    ub(3)=Sl+err;

    % Apply fitting
    y=y-X(:,3)*Sl;
    mdl = fitlm(X(:,1:2), y, 'Intercept', false);
    beta_fit = mdl.Coefficients.Estimate;

    % Test linear model assumption
    R2 = mdl.Rsquared.Ordinary;
    residuals = mdl.Residuals.Raw;

    signals(1:2,imgindx,1) = beta_fit;
    signals(3,imgindx,1) = Sl;
    

    % == BOOTSTRAPPING 

    % All data
    N=length(y);

    B=10000;
    bootstrap_indices = randi(N, N, B);
    BootFits = zeros(B,3);
    BootR2s = zeros(B,1);

    for bindx = 1:B

        thismdl = fitlm(X(bootstrap_indices(:,bindx), 1:2), y(bootstrap_indices(:,bindx)), 'Intercept', false);

        thisbeta_fit = thismdl.Coefficients.Estimate;
        BootFits(bindx, 1:2) = thisbeta_fit;
        BootFits(bindx, 3) = Sl;

        BootR2s(bindx)= thismdl.Rsquared.Ordinary;

    end

    signals(:,imgindx,2) = std(BootFits); % Standard error
    signals(:,imgindx,3) = prctile(BootFits,0.5); % 0.5th percentile
    signals(:,imgindx,4) = prctile(BootFits,99.5); % 99.5th percentile

    % RESULTS
    RESULTS(imgindx).E = [signals(1, imgindx, 1), signals(1, imgindx, 3), signals(1, imgindx, 4)];
    RESULTS(imgindx).S = [signals(2, imgindx, 1), signals(2, imgindx, 3), signals(2, imgindx, 4)];
    RESULTS(imgindx).L = [signals(3, imgindx, 1), signals(3, imgindx, 3), signals(3, imgindx, 4)];
    RESULTS(imgindx).R2 = [R2, prctile(BootR2s, 2.5), prctile(BootR2s, 97.5)];
    RESULTS(imgindx).Residuals = residuals;
    RESULTS(imgindx).y = y;

end

RESULTS(1).X = X;


%% Display estimated signals

f=figure;
bshift=5;

% Short Delta

indices = 2:6;
s = signals(:,indices,:);
bvals = [scheme(indices).bval];

% Display error bars with 95% confidence intervals from botstrapping
errorbar(bvals-1*bshift, s(1,:,1), s(1,:,1)-s(1,:,3), s(1,:,4)-s(1,:,1), '--*', LineWidth = 1, color='#EB0000', DisplayName='Epithelium');
hold on
errorbar(bvals-1*bshift, s(2,:,1), s(2,:,1)-s(2,:,3), s(2,:,4)-s(2,:,1), '--*', LineWidth = 1, color='#10DE00', DisplayName='Stroma');
% errorbar(bvals-1*bshift, s(3,:,1), s(3,:,1)-s(3,:,3), s(3,:,4)-s(3,:,1),'--*', color=[0 0.4470 0.7410], DisplayName = 'L (Short \Delta)');


% % Display error bars with STANDARD ERROR from botstrapping
% errorbar(bvals-1*bshift, s(1,:,1), s(1,:,2), '-*', color=[0.4660 0.6740 0.1880], DisplayName='S (Short \Delta)');
% hold on
% errorbar(bvals-1*bshift, s(2,:,1), s(2,:,2), '-*', color=[0.8500 0.3250 0.0980], DisplayName='G (Short \Delta)');
% errorbar(bvals-1*bshift, s(3,:,1), s(3,:,2),'-*', color=[0 0.4470 0.7410], DisplayName = 'L (Short \Delta)');


% Long Delta
indices = 7:11;
s = signals(:,indices,:);

% Display error bars with 95% confidence intervals from botstrapping
errorbar(bvals+1*bshift, s(1,:,1), s(1,:,1)-s(1,:,3), s(1,:,4)-s(1,:,1), '--*', LineWidth = 1, color='#EB0000', HandleVisibility='off');
errorbar(bvals+1*bshift, s(2,:,1), s(2,:,1)-s(2,:,3), s(2,:,4)-s(2,:,1),  '--*', LineWidth = 1, color='#10DE00', HandleVisibility='off');
% errorbar(bvals+1*bshift, s(3,:,1), s(3,:,1)-s(3,:,3), s(3,:,4)-s(3,:,1), '--*', color=[0 0.4470 0.7410], DisplayName = 'L (Long \Delta)');

% % Display error bars with STANDARD ERROR from botstrapping
% errorbar(bvals+1*bshift, s(1,:,1), s(1,:,2), '-.*', color=[0.4660 0.6740 0.1880], DisplayName='S (Long \Delta)');
% errorbar(bvals+1*bshift, s(2,:,1), s(2,:,2),  '-.*', color=[0.8500 0.3250 0.0980], DisplayName='G (Long \Delta)');
% errorbar(bvals+1*bshift, s(3,:,1), s(3,:,2), '-.*', color=[0 0.4470 0.7410], DisplayName = 'L (Long \Delta)');

xticks(bvals); 
xticklabels(bvals)
ylim([0.22,0.7])
ylabel('dMRI signal')
xlim([800,2200])
xlabel('b-value (s/mm^{2})')
xticks(bvals)
xticklabels(["1000", "1250", "1500", "1750", "2000"])
grid on
legend('NumColumns', 1);
ax=gca();
ax.FontSize=14;
f.Position = [488   242   720   480];


%% Save estimated signals

switch multisample
    case false
        samplename = SampleNames{1};
        savefolder = fullfile(projectfolder, "Outputs", "ESL Signal Estimation", samplename);
        mkdir(savefolder);
    case true
        savefolder = fullfile(projectfolder, "Outputs", "ESL Signal Estimation", 'Multi-sample');
        mkdir(savefolder);
end

% Meta info
Meta = struct();
Meta.SampleNames = SampleNames;
Meta.SeriesDescriptions = SeriesDescriptions;
Meta.Nboot = B;

save(fullfile(savefolder, 'signals.mat'), 'signals')
save(fullfile(savefolder, 'scheme.mat'), 'scheme')
save(fullfile(savefolder, 'Meta.mat'), 'Meta')
save(fullfile(savefolder, 'RESULTS.mat'), 'RESULTS')



%% Function (Linear ESL model)

function signals = signal_func(b,X)

% b = [S_e, S_S, Sl]
% X = [fe1, fs1, fl1; fe2, fs2, fl2; ... ]

Se = b(1);
Ss = b(2);
Sl = b(3);

N = size(X,1);
signals = zeros(N,1);

for indx = 1:N

    fe = X(indx,1);
    fs = X(indx,2);
    fl = X(indx,3);

    signals(indx) = fe*Se + fs*Ss + fl*Sl;
    
end


end