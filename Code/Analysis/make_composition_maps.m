% Script to make composition masks for sample sets

clear;
projectfolder = pwd;

%%

% Sample name
samplename = '20260128_UQ10';

% Imaging data
ImagingDataFolder = fullfile(projectfolder, 'Imaging Data', 'MAT DN'); 


%% Load data

baseseriesdescription = '3DMGE_20u';
baseimg = load(fullfile(ImagingDataFolder, samplename, baseseriesdescription, 'avgImageArray.mat' )).avgImageArray;

maskfolder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, baseseriesdescription);
EPITHELIUM = load(fullfile(maskfolder, 'EPITHELIUM.mat')).EPITHELIUM;
STROMA = load(fullfile(maskfolder, 'STROMA.mat')).STROMA;
LUMEN = load(fullfile(maskfolder, 'LUMEN.mat')).LUMEN;
szbase = size(EPITHELIUM);


% Load b0 image
b0_SeriesDescription = 'SE_b0_SPOIL5% (DS)';
b0img = load(fullfile(ImagingDataFolder, samplename, b0_SeriesDescription, "axialImageArray.mat")).ImageArray;


%% Make sample mask

[Ys, Xs, Zs] = ndgrid( ...
    1:szbase(2),...
    1:szbase(1),...
    1:szbase(3)...
    );

switch samplename

    case '20250224_UQ4'

        % Cylinder centred at (128, 114), radius 75 (1.5mm)

        samplemask = (Xs-128).^2 + (Ys-114).^2 <75^2 ;

        % Remove ends
        % samplemask(:,:,1:10)=false;
        samplemask(:,:,end-10:end)=false;

        % === Define masks for individual samples

        Bmask = samplemask.*and(Zs>=1, Zs<208);
        Mmask = samplemask.*and(Zs>=208, Zs<398);
        Nmask = samplemask.*and(Zs>=398, Zs<640);


    case '20250407_UQ5'

        % Cylinder centred at (123, 119), radius 75 (1.5mm)

        samplemask = (Xs-123).^2 + (Ys-119).^2 <75^2 ; 

        % Remove ends
        samplemask(:,:,1:10)=false;
        samplemask(:,:,600:end)=false;

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=1, Zs<136);
        Mmask = samplemask.*and(Zs>=136, Zs<344);
        Nmask = samplemask.*and(Zs>=344, Zs<641);


    case '20250414_UQ6'

        % Cylinder centred at (122, 117), radius 76 (1.52mm)

        samplemask = (Xs-122).^2 + (Ys-117).^2 <76^2;

        % Remove ends
        samplemask(:,:,1:20)=false;
        % samplemask(:,:,end-10:end)=false;

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=15, Zs<285);
        Mmask = samplemask.*and(Zs>=285, Zs<552);
        Nmask = samplemask.*and(Zs>=552, Zs<641);


    case '20250522_UQ7'

        % Cylinder centred at (124, 117)

        samplemask = (Xs-124).^2 + (Ys-117).^2 <75^2;

        % Remove ends
        samplemask(:,:,1:10)=false;
        samplemask(:,:,end-10:end)=false;

        % EXCLUDE REGION DUE TO BUBBLES
        rows = 1:90;
        cols = 46:198;
        slices = 225:510;
        samplemask(rows, cols, slices)=false;

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=1, Zs<228);
        Mmask = samplemask.*and(Zs>=228, Zs<506);
        Nmask = samplemask.*and(Zs>=506, Zs<641);            


    case '20250523_UQ8'

        % Cylinder centred at (123, 119)

        samplemask = (Xs-123).^2 + (Ys-119).^2 <75^2;

        % Remove ends
        samplemask(:,:,1:10)=false;
        samplemask(:,:,end-10:end)=false;            

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=1, Zs<198);
        Mmask = samplemask.*and(Zs>=198, Zs<458);
        Nmask = samplemask.*and(Zs>=458, Zs<641);   

    case '20250524_UQ9'

        % Cylinder centred at (118, 127), radius 80 (1.6mm)

        samplemask = (Xs-118).^2 + (Ys-127).^2 <80^2;

        % REMOVE TOP AND BOTTOM REGIONS OF MEDIUM
        samplemask(:,:,1:40)=false;
        samplemask(:,:,570:end)=false;   

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=48, Zs<330);
        Mmask = samplemask.*and(Zs>=330, Zs<330);
        Nmask = samplemask.*and(Zs>=330, Zs<562);   


    case '20260128_UQ10'

        % Cylinder centred at (125, 113.5), radius 70 (1.4mm)
        samplemask = (Xs-125).^2 + (Ys-113.5).^2 <70^2;

        % == Define masks for individual samples

        Bmask = samplemask.*and(Zs>=6, Zs<164);
        Mmask = samplemask.*and(Zs>=174, Zs<464);
        Nmask = samplemask.*and(Zs>=464, Zs<624);



end


%% Construct composition map

% Map size
szmap = size(b0img, 1:3);
COMPOSITION = zeros([szmap, 3]);
ResFactor = szbase./szmap;
Nvoxel = prod(ResFactor);

NMASK = zeros(szmap);
MMASK = zeros(szmap);
BMASK = zeros(szmap);

for rindx = 1:szmap(1)
    for cindx = 1:szmap(2)
        for slindx = 1:szmap(3)

            baserows = ((rindx-1)*ResFactor(1)+1:rindx*ResFactor(1));
            basecols = ((cindx-1)*ResFactor(2)+1:cindx*ResFactor(2));
            baseslices = ((slindx-1)*ResFactor(3)+1:slindx*ResFactor(3));

            % Test in sample
            if ~all(logical(samplemask(baserows, basecols, baseslices)), "all")
                continue
            end

            % COMPOSITION         
            COMPOSITION(rindx, cindx, slindx, 1) = sum(double(EPITHELIUM(baserows, basecols, baseslices)), "all")/Nvoxel;
            COMPOSITION(rindx, cindx, slindx, 2) = sum(double(STROMA(baserows, basecols, baseslices)), "all")/Nvoxel;
            COMPOSITION(rindx, cindx, slindx, 3) = sum(double(LUMEN(baserows, basecols, baseslices)), "all")/Nvoxel; 

            % MASKs for B, M, N samples
            thisNmask = Nmask(baserows, basecols, baseslices);
            thisMmask = Mmask(baserows, basecols, baseslices);
            thisBmask = Bmask(baserows, basecols, baseslices);

            if sum(thisNmask(:)) > 0.5*Nvoxel
                NMASK(rindx, cindx, slindx) = 1;
            elseif sum(thisMmask(:)) > 0.5*Nvoxel
                MMASK(rindx, cindx, slindx) = 1;
            elseif sum(thisBmask(:)) > 0.5*Nvoxel
                BMASK(rindx, cindx, slindx) = 1;
            end

        end
    end
end


%% Save masks

% COMPOSITION
folder = fullfile(projectfolder, 'Outputs', 'Masks', samplename, b0_SeriesDescription);

mkdir(folder)
save(fullfile(folder, 'COMPOSITION.mat'), 'COMPOSITION');

% Save individual sample masks
save(fullfile(folder, 'NMASK.mat'), 'NMASK');
save(fullfile(folder, 'MMASK.mat'), 'MMASK');
save(fullfile(folder, 'BMASK.mat'), 'BMASK');

