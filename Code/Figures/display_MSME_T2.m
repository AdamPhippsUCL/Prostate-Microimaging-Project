% Script to display T2 distributions in samples

clear;
projectfolder = pwd;

%%

ImagingDataFolder = fullfile(projectfolder, 'Imaging Data');

samplename = '20250524_UQ9';
%'20250224_UQ4'
% '20250407_UQ5'
%'20250414_UQ6'
% '20250522_UQ7'
% '20250523_UQ8'
% '20250524_UQ9

% Sequence
seriesdescription = 'T2_MSME';


