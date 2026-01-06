% Script to display distributions of ESL volume fractions across all
% low-res dMRI voxels.

clear;
projectfolder = pwd;

%% Load composition array

RESULTS = load(fullfile(projectfolder, 'Outputs', 'ESL Signal Estimation', 'Multi-sample', 'RESULTS.mat')).RESULTS;
X = RESULTS(1).X;


%% Display distributions

colors = get(gca,'ColorOrder');

% Epithelium
f=figure;
h=histogram(X(:,1),0:0.02:1, FaceColor='#EB0000', FaceAlpha=.6);
ylim([0, 1.1*max(h.Values)])
xlabel('Volume fraction')
ylabel('Number of voxels')
title('Epithelium')
saveas(f, fullfile(projectfolder, 'Figures', 'Supplementary', 'Epithelium_Volume_Frac_Dist.png'))

% Stroma
f=figure;
h=histogram(X(:,2),0:0.02:1, FaceColor=[colors(5,:)], FaceAlpha=.6);
ylim([0, 1.1*max(h.Values)])
xlabel('Volume fraction')
ylabel('Number of voxels')
title('Stroma')
saveas(f, fullfile(projectfolder, 'Figures', 'Supplementary', 'Stroma_Volume_Frac_Dist.png'))

% Lumen/Fluid
f=figure;
h=histogram(X(:,3),0:0.02:1, FaceColor=[colors(1,:)], FaceAlpha=.6);
ylim([0, 1.1*max(h.Values)])
xlabel('Volume fraction')
ylabel('Number of voxels')
title('Lumen/Fluid')
saveas(f, fullfile(projectfolder, 'Figures', 'Supplementary', 'Lumen_Volume_Frac_Dist.png'))