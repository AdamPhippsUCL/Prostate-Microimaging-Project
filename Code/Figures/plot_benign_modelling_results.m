% Script to compare model parameters from measured and predicted signal profiles in benign tissue

clear;
projectfolder = pwd;

%% Load modelling results

samplenames = {...
            '20250224_UQ4',...
            ...'20250407_UQ5',...
           '20250414_UQ6',...
           '20250522_UQ7',...
           '20250523_UQ8',...
           '20250524_UQ9',...
           };

% Sample groups
Cancer = {'4B', '4M', '6N'};

% Ball+Sphere
Measured_fs = [];
Pred_fs = [];
Measured_Db = [];
Pred_Db = [];

% ADC
Measured_ADC = [];
Pred_ADC = [];

% Comp
COMP = [];
SNums = [];

for samplename = samplenames

    samplename = samplename{:}

    folder =  fullfile(projectfolder, 'Outputs', 'Signals', samplename);
    COMPOSITION = load(fullfile(folder, "COMP.mat")).COMP;
    SampleNums = load(fullfile(folder, "SampleNums.mat")).SampleNums;
    
    % Only benign samples
    Bools = ~ismember(SampleNums, Cancer);
    COMP = [COMP; COMPOSITION(Bools, :)];
    SNums = [SNums; SampleNums(Bools)];
    
    
    % =========== Ball+Sphere
    
    ModelName = 'Ball+Sphere';
    schemename = '20250224_UQ4 AllDELTA';
    fittingtechnique = 'LSQ';
    
    % Output folder
    output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );
    
    % Load parameter estimates from measured signals
    measured_fs = load(fullfile(output_folder, samplename, ModelName, 'Measured', 'fs')).measured_fs;
    % measured_Ds = load(fullfile(output_folder,  samplename, ModelName, 'Measured', 'Ds')).measured_Ds;
    measured_Db = load(fullfile(output_folder,  samplename, ModelName, 'Measured', 'Db')).measured_Db;
    % measured_R = load(fullfile(output_folder,  samplename, ModelName, 'Measured', 'R')).measured_R;
    
    Measured_fs = [Measured_fs; measured_fs(Bools)];
    Measured_Db = [Measured_Db; measured_Db(Bools)];
    % measured_Ds = measured_Ds(Bools);
   
    % measured_R = measured_R(Bools);
    
    % Load parameter estimates from predicted signals
    pred_fs = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'fs')).pred_fs;
    % pred_Ds = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'Ds')).pred_Ds;
    pred_Db = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'Db')).pred_Db;
    % pred_R = load(fullfile(output_folder,  samplename, ModelName, 'Predicted', 'R')).pred_R;
    
    Pred_fs = [Pred_fs; pred_fs(Bools)];
    Pred_Db = [Pred_Db; pred_Db(Bools)];
    % pred_Ds = pred_Ds(Bools);
    
    % pred_R = pred_R(Bools);
    
    
    % =========== ADC
    
    ModelName = 'ADC';
    schemename = '20250224_UQ4 AllDELTA';
    fittingtechnique = 'LSQ';
    
    % Output folder
    output_folder = fullfile(projectfolder, 'Outputs', 'Model Fitting' );
    
    % Load parameter estimates from measured signals
    measured_ADC = load(fullfile(output_folder, samplename,  ModelName, 'Measured', 'D')).measured_D;
    
    Measured_ADC = [Measured_ADC; measured_ADC(Bools)];
    
    % Load parameter estimates from predicted signals
    pred_ADC = load(fullfile(output_folder, samplename, ModelName, 'Predicted', 'D')).pred_D;
    
    Pred_ADC = [Pred_ADC; pred_ADC(Bools)];

end


% Focus on high epithelium voxels for mean and sigma
highE = 0.8;
highE_bool = COMP(:,1)>highE;


%%  SPHERE FRACTION

fs_diff = (Measured_fs-Pred_fs);

% Bias
fs_bias = mean(fs_diff);
fs_bias_highE = mean(fs_diff(highE_bool));

% 95% residual limits
fs_sigma = std(fs_diff);
fs_sigma_highE = std(fs_diff(highE_bool));

% Save bias and sigma
RLfolder = fullfile(projectfolder, 'Outputs', 'Model Fitting', 'Benign RL', 'Ball+Sphere');
mkdir(RLfolder)
save(fullfile(RLfolder, 'fs_mean_bias.mat'), 'fs_bias');
save(fullfile(RLfolder, 'fs_sigma.mat'), 'fs_sigma');
save(fullfile(RLfolder, 'fs_mean_bias_highE.mat'), 'fs_bias_highE');
save(fullfile(RLfolder, 'fs_sigma_highE.mat'), 'fs_sigma_highE');


% FIGURE FOR ALL VOXELS

f1=figure;
ax1=axes;
scatter(Pred_fs, fs_diff ,  6, 'filled', 'MarkerFaceAlpha', 0.3, CData=COMP, HandleVisibility='off');
hold on

yline(fs_bias, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(fs_bias-1*fs_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(fs_bias+1*fs_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(fs_bias-2*fs_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(fs_bias+2*fs_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northwest")
grid on
ylim([-0.3, 0.3])
yticks(-0.2:0.1:0.2)
xlim([-0.05, 0.35])
xticks([0:0.1:0.3])
xlabel('Predicted Sphere Fraction')
ylabel('Measured - Predicted Sphere Fraction')

ax1.FontSize = 12;
title('All voxels')

f1.Position = [680   400   600   380];

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals Sphere Fraction.png']))


% FIGURE High E voxels

f1=figure;
ax1=axes;
scatter(Pred_fs(highE_bool), fs_diff(highE_bool) ,  12, 'filled', 'MarkerFaceAlpha', 0.5, CData=COMP(highE_bool,:), HandleVisibility='off');
hold on

yline(fs_bias_highE, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(fs_bias_highE-1*fs_sigma_highE, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(fs_bias_highE+1*fs_sigma_highE, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(fs_bias_highE-2*fs_sigma_highE, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(fs_bias_highE+2*fs_sigma_highE, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northwest")
grid on
ylim([-0.3, 0.3])
yticks(-0.2:0.1:0.2)
% xlim([-0.05, 0.35])
xticks([0:0.01:0.4])
xlabel('Predicted Sphere Fraction')
ylabel('Measured - Predicted Sphere Fraction')

ax1.FontSize = 12;

title(['High E > ' num2str(highE)])

f1.Position = [680   400   600   380];

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals Sphere Fraction High E.png']))



% % == Per sample plot
% 
% f2=figure;
% f2.Position = [680   400   600   380];
% ax2=axes;
% 
% sdiffs = [];
% sindxs = [];
% scolors = [];
% 
% for sindx = 1:length(Benign)
% 
%     snum = Benign{sindx};
%     sbool = ismember(SNums, snum);
%     sindxs = [sindxs; sindx*ones(sum(sbool), 1)];
% 
%     sdiff = fs_diff(sbool);
%     scomp = COMP(sbool, :);
% 
%     sdiffs = [sdiffs; sdiff];
%     scolors = [scolors; mean(scomp)];
% 
% end
% 
% % % yline(fs_bias, '-', DisplayName='Bias', LineWidth=1.1, Alpha=0.4)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % hold on
% % yline(fs_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(fs_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% 
% % yline(fs_bias, '-', DisplayName= '\mu', LineWidth=0.8)
% 
% 
% % Add more sigma lines..
% yline(fs_bias-1*fs_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1)
% hold on
% yline(fs_bias+1*fs_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% % Add more sigma lines..
% yline(fs_bias-2*fs_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1)
% yline(fs_bias+2*fs_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% 
% 
% for sindx = 1:length(Benign)
%     boxchart(sindxs(sindxs==sindx), sdiffs(sindxs==sindx), 'BoxFaceColor', scolors(sindx,:), 'HandleVisibility','off', MarkerStyle='.', MarkerColor=[.1, .1, .1])
%     hold on
% end
% 
% ylim([ax1.YLim])
% yticks([ax1.YTick])
% xlim([0.2, 14.8])
% xticks(1:20)
% 
% % Find box objects 
% h = findobj(ax2,'Tag','Box');
% set(h, 'LineWidth', 1.2)
% % Loop and assign colours
% for j = 1:length(h)
%     set(h(j), 'Color', scolors(length(h)-j+1,:));
% end
% 
% % Find outlier objects
% hOut = findobj(ax2,'Tag','Outliers');
% set(hOut, 'MarkerEdgeColor',[0.4 0.4 0.4], 'Marker','.')
% 
% legend(Location="northwest");
% ylabel('Measured - Predicted Sphere Fraction')
% xlabel('Sample Number')
% % title(['Sphere Fraction'])
% ax2.FontSize = 12;
% ax2.YGrid = 'on';
% ax2.Box = 'off';
% 
% % saveas(f2, fullfile(projectfolder, 'Thesis Figures', ['Benign Samples Residuals Sphere Fraction.png']))
% 



%% BALL-COMPARTMENT DIFFUSIVITY 

Db_diff = (Measured_Db-Pred_Db);

% Bias
Db_bias = mean(Db_diff);
Db_bias_highE = mean(Db_diff(highE_bool));

% sigma
Db_sigma = std(Db_diff);
Db_sigma_highE = std(Db_diff(highE_bool));

% Save residual limits
RLfolder = fullfile(projectfolder, 'Outputs', 'Model Fitting', 'Benign RL', 'Ball+Sphere');
mkdir(RLfolder)
save(fullfile(RLfolder, 'Db_mean_bias.mat'), 'Db_bias');
save(fullfile(RLfolder, 'Db_sigma.mat'), 'Db_sigma');
save(fullfile(RLfolder, 'Db_mean_bias_highE.mat'), 'Db_bias_highE');
save(fullfile(RLfolder, 'Db_sigma_highE.mat'), 'Db_sigma_highE');


% FIGURE for all voxels

f1=figure;
f1.Position = [680   400   600   380];
ax1 = axes;

scatter(Pred_Db, Db_diff ,  6, 'filled', 'MarkerFaceAlpha', 0.3, CData=COMP, HandleVisibility='off');
hold on

% % yline(Db_bias, '-', DisplayName='Bias', LineWidth=1.2)
% yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% yline(Db_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% yline(Db_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

yline(Db_bias, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(Db_bias-1*Db_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(Db_bias+1*Db_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(Db_bias-2*Db_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(Db_bias+2*Db_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northeast")
grid on
ylim([-0.82, 1.12])
yticks(-1:0.2:1)
xlim([0.56, 2.04])
xticks([0.6:0.2:2])
xlabel('Predicted D_{ball} (µm^2/ms)')
ylabel('Measured - Predicted D_{ball} (µm^2/ms)')

ax1.FontSize = 12;

title('All voxels')

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals Db.png']))


% FIGURE for high E voxels

f1=figure;
f1.Position = [680   400   600   380];
ax1 = axes;

scatter(Pred_Db(highE_bool), Db_diff(highE_bool) ,  12, 'filled', 'MarkerFaceAlpha', 0.5, CData=COMP(highE_bool,:), HandleVisibility='off');
hold on

yline(Db_bias_highE, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(Db_bias_highE-1*Db_sigma_highE, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(Db_bias_highE+1*Db_sigma_highE, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(Db_bias_highE-2*Db_sigma_highE, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(Db_bias_highE+2*Db_sigma_highE, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northeast")
grid on
ylim([-0.82, 1.12])
yticks(-1:0.2:1)
% xlim([0.56, 2.04])
xticks([0.5:0.1:2])
xlabel('Predicted D_{ball} (µm^2/ms)')
ylabel('Measured - Predicted D_{ball} (µm^2/ms)')

ax1.FontSize = 12;

title(['High E > ' num2str(highE)])

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals Db High E.png']))

% % Per sample plot
% 
% f2=figure;
% f2.Position = [680   400   600   380];
% ax2=axes;
% 
% sdiffs = [];
% sindxs = [];
% scolors = [];
% 
% for sindx = 1:length(Benign)
% 
%     snum = Benign{sindx};
%     sbool = ismember(SNums, snum);
%     sindxs = [sindxs; sindx*ones(sum(sbool), 1)];
% 
%     sdiff = Db_diff(sbool);
%     scomp = COMP(sbool, :);
% 
%     sdiffs = [sdiffs; sdiff];
%     scolors = [scolors; mean(scomp)];
% 
% end
% 
% % % yline(Db_bias, '-', DisplayName='Bias', LineWidth=1.1, Alpha=0.4)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % hold on
% % yline(Db_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(Db_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% % % boxplot(sdiffs, sindxs,'Colors','k')
% 
% % Add more sigma lines..
% yline(Db_bias-1*Db_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1)
% hold on
% yline(Db_bias+1*Db_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% % Add more sigma lines..
% yline(Db_bias-2*Db_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1)
% yline(Db_bias+2*Db_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% 
% for sindx = 1:length(Benign)
%     boxchart(sindxs(sindxs==sindx), sdiffs(sindxs==sindx), 'BoxFaceColor', scolors(sindx,:), 'HandleVisibility','off', MarkerStyle='.', MarkerColor=[.1, .1, .1])
%     hold on
% end
% 
% ylim([ax1.YLim])
% yticks([ax1.YTick])
% xlim([0.2, 14.8])
% xticks(1:20)
% 
% % Find box objects 
% h = findobj(ax2,'Tag','Box');
% set(h, 'LineWidth', 1.2)
% % Loop and assign colours
% for j = 1:length(h)
%     set(h(j), 'Color', scolors(length(h)-j+1,:));
% end
% 
% % Find outlier objects
% hOut = findobj(ax2,'Tag','Outliers');
% set(hOut, 'MarkerEdgeColor',[0.4 0.4 0.4], 'Marker','.')
% 
% legend(Location='northeast');
% ylabel('Measured - Predicted D_{ball} (µm^2/ms)')
% xlabel('Sample Number')
% % title(['Sphere Fraction'])
% ax2.FontSize = 12;
% ax2.YGrid = 'on';
% ax2.Box = 'off';
% 
% saveas(f2, fullfile(projectfolder, 'Thesis Figures', ['Benign Samples Residuals Db.png']))
% 





%% ADC

ADC_diff = (Measured_ADC-Pred_ADC);

% Bias
ADC_bias = mean(ADC_diff);
ADC_bias_highE = mean(ADC_diff(highE_bool));

ADC_sigma = std(ADC_diff);
ADC_sigma_highE = std(ADC_diff(highE_bool));

% Save
RLfolder = fullfile(projectfolder, 'Outputs', 'Model Fitting', 'Benign RL', 'ADC');
mkdir(RLfolder)
save(fullfile(RLfolder, 'ADC_mean_bias.mat'), 'ADC_bias');
save(fullfile(RLfolder, 'ADC_sigma.mat'), 'ADC_sigma');
save(fullfile(RLfolder, 'ADC_mean_bias_highE.mat'), 'ADC_bias_highE');
save(fullfile(RLfolder, 'ADC_sigma_highE.mat'), 'ADC_sigma_highE');


% FIGURE for all voxels

f1=figure;
f1.Position = [680   400   600   380];
ax1=axes;

scatter(Pred_ADC, ADC_diff ,  6, 'filled', 'MarkerFaceAlpha', 0.3, CData=COMP, HandleVisibility='off');
hold on

yline(ADC_bias, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(ADC_bias-1*ADC_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(ADC_bias+1*ADC_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(ADC_bias-2*ADC_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(ADC_bias+2*ADC_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northeast")
grid on
ylim([-0.88, 1.22])
yticks(-1:0.2:1)
xlim([0.36, 2.1])
xticks([0.4:0.2:2])
xlabel('Predicted ADC (µm^2/ms)')
ylabel('Measured - Predicted ADC (µm^2/ms)')

ax1.FontSize = 12;

title('All voxels')

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals ADC.png']))



% FIGURE for high E voxels

f1=figure;
f1.Position = [680   400   600   380];
ax1=axes;

scatter(Pred_ADC(highE_bool), ADC_diff(highE_bool) , 12, 'filled', 'MarkerFaceAlpha', 0.5, CData=COMP(highE_bool,:), HandleVisibility='off');
hold on

yline(ADC_bias_highE, '-', DisplayName= '\mu', LineWidth=1.2)

% Add more sigma lines..
yline(ADC_bias_highE-1*ADC_sigma_highE, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(ADC_bias_highE+1*ADC_sigma_highE, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

% Add more sigma lines..
yline(ADC_bias_highE-2*ADC_sigma_highE, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
yline(ADC_bias_highE+2*ADC_sigma_highE, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)

legend(Location="northeast")
grid on
ylim([-0.62, 0.82])
yticks(-1:0.2:1)
% xlim([0.36, 2.1])
xticks([0.3:0.05:2])
xlabel('Predicted ADC (µm^2/ms)')
ylabel('Measured - Predicted ADC (µm^2/ms)')

ax1.FontSize = 12;

title(['High E > ' num2str(highE)])

saveas(f1, fullfile(projectfolder, 'Thesis Figures', 'Benign Residuals Plots', ['Benign Residuals ADC High E.png']))


% % Per sample plot
% 
% f2=figure;
% f2.Position = [680   400   600   380];
% ax2=axes;
% 
% sdiffs = [];
% sindxs = [];
% scolors = [];
% 
% for sindx = 1:length(Benign)
% 
%     snum = Benign{sindx};
%     sbool = ismember(SNums, snum);
%     sindxs = [sindxs; sindx*ones(sum(sbool), 1)];
% 
%     sdiff = ADC_diff(sbool);
%     scomp = COMP(sbool, :);
% 
%     sdiffs = [sdiffs; sdiff];
%     scolors = [scolors; mean(scomp)];
% 
% end
% 
% % % yline(ADC_bias, '-', DisplayName='Bias', LineWidth=1.1, Alpha=0.4)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % hold on
% % yline(ADC_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(ADC_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% % % boxplot(sdiffs, sindxs,'Colors','k')
% 
% 
% % Add more sigma lines..
% yline(ADC_bias-1*ADC_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1)
% hold on
% yline(ADC_bias+1*ADC_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% % Add more sigma lines..
% yline(ADC_bias-2*ADC_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1)
% yline(ADC_bias+2*ADC_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% 
% for sindx = 1:length(Benign)
%     boxchart(sindxs(sindxs==sindx), sdiffs(sindxs==sindx), 'BoxFaceColor', scolors(sindx,:), 'HandleVisibility','off', MarkerStyle='.', MarkerColor=[.1, .1, .1])
%     hold on
% end
% 
% ylim([ax1.YLim])
% yticks([ax1.YTick])
% xlim([0.2, 14.8])
% xticks(1:20)
% 
% 
% % Find box objects 
% h = findobj(ax2,'Tag','Box');
% set(h, 'LineWidth', 1.2)
% % Loop and assign colours
% for j = 1:length(h)
%     set(h(j), 'Color', scolors(length(h)-j+1,:));
% end
% 
% % Find outlier objects
% hOut = findobj(ax2,'Tag','Outliers');
% set(hOut, 'MarkerEdgeColor',[0.4 0.4 0.4], 'Marker','.')
% 
% legend(Location='southeast');
% ylabel('Measured - Predicted ADC (µm^2/ms)')
% xlabel('Sample Number')
% % title(['Sphere Fraction'])
% ax.FontSize = 12;
% ax.YGrid = 'on';
% ax.Box = 'off';
% 
% saveas(f2, fullfile(projectfolder, 'Thesis Figures', ['Benign Samples Residuals ADC.png']))
% 
% 

%% SPHERE RADIUS
% 
% RL_BOOL = (COMP(:,3)<1.0);
% 
% 
% R_diff = (measured_R-pred_R);
% 
% % Bias
% R_bias = mean(R_diff(RL_BOOL));
% 
% % 95% residual limits
% R_sigma = std(R_diff(RL_BOOL));
% R_upperRL = R_bias+1.96*R_sigma;
% R_lowerRL = R_bias-1.96*R_sigma;
% 
% % Save residual limits
% R_RL = [R_bias, R_lowerRL, R_upperRL];
% RLfolder = fullfile(projectfolder, 'Outputs', 'Model Fitting', 'Benign RL', 'Ball+Sphere');
% mkdir(RLfolder)
% save(fullfile(RLfolder, 'R_BenignRL.mat'), 'R_RL');
% save(fullfile(RLfolder, 'R_mean_bias.mat'), 'R_bias');
% save(fullfile(RLfolder, 'R_sigma.mat'), 'R_sigma');
% 
% f=figure;
% scatter(pred_R, R_diff ,  6, 'filled', 'MarkerFaceAlpha', 0.3, CData=COMP, HandleVisibility='off');
% hold on
% 
% % % yline(R_bias, '-', DisplayName='Bias', LineWidth=1.2)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % yline(R_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(R_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% yline(R_bias, '-', DisplayName= '\mu', LineWidth=1.2)
% 
% % Add more sigma lines..
% yline(R_bias-1*R_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
% yline(R_bias+1*R_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% % Add more sigma lines..
% yline(R_bias-2*R_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
% yline(R_bias+2*Db_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% 
% legend(Location="northwest")
% grid on
% xlim([3.8, 6.8])
% xticks(2:8)
% ylim([-4.9,4.2])
% xlabel('Predicted R (µm)')
% ylabel('Measured - Predicted R (µm)')
% 
% ax = gca();
% ax.FontSize = 12;
% 
% f.Position = [680   400   600   380];
% 
% % saveas(f, fullfile(projectfolder, 'Figures', ['Benign Residuals R.png']))
% 
% 
% % Per sample plot
% 
% f=figure;
% f.Position = [680   400   600   380];
% 
% sdiffs = [];
% sindxs = [];
% scolors = [];
% 
% for sindx = 1:length(Benign)
% 
%     snum = Benign{sindx};
%     sbool = ismember(SNums, snum);
%     sindxs = [sindxs; sindx*ones(sum(sbool), 1)];
% 
%     sdiff = R_diff(sbool);
%     scomp = COMP(sbool, :);
% 
%     sdiffs = [sdiffs; sdiff];
%     scolors = [scolors; mean(scomp)];
% 
% end
% 
% % % yline(R_bias, '-', DisplayName='Bias', LineWidth=1.1, Alpha=0.4)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % hold on
% % yline(R_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(R_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% % % boxplot(sdiffs, sindxs,'Colors','k')
% 
% 
% % Add more sigma lines..
% yline(R_bias-1*R_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1)
% hold on
% yline(R_bias+1*R_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% % Add more sigma lines..
% yline(R_bias-2*R_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1)
% yline(R_bias+2*R_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% 
% for sindx = 1:length(Benign)
%     boxchart(sindxs(sindxs==sindx), sdiffs(sindxs==sindx), 'BoxFaceColor', scolors(sindx,:), 'HandleVisibility','off', MarkerStyle='.', MarkerColor=[.1, .1, .1])
%     hold on
% end
% 
% ylim([-4.9,4.2])
% xlim([0.2, 14.8])
% xticks(1:20)
% 
% % Find box objects 
% ax = gca();
% h = findobj(ax,'Tag','Box');
% set(h, 'LineWidth', 1.2)
% % Loop and assign colours
% for j = 1:length(h)
%     set(h(j), 'Color', scolors(length(h)-j+1,:));
% end
% 
% % Find outlier objects
% hOut = findobj(gca,'Tag','Outliers');
% set(hOut, 'MarkerEdgeColor',[0.4 0.4 0.4], 'Marker','.')
% 
% lgd = legend(Location='northeast');
% % lgd.Position = [0.58    0.87    0.2033    0.0118];
% ylabel('Measured - Predicted R (µm)')
% xlabel('Sample Number')
% % title(['Sphere Fraction'])
% ax.FontSize = 12;
% ax.YGrid = 'on';
% ax.Box = 'off';
% 
% % saveas(f, fullfile(projectfolder, 'Figures', ['Samples Residuals R.png']))
% 



%% SPHERE-COMPARTMENT DIFFUSIVITY 
% 
% Ds_diff = (measured_Ds-pred_Ds);
% 
% % Bias
% Ds_bias = mean(Ds_diff);
% 
% % 95% residual limits
% Ds_sigma = std(Ds_diff);
% Ds_upperRL = mean(Ds_diff)+1.96*Ds_sigma;
% Ds_lowerRL = mean(Ds_diff)-1.96*Ds_sigma;
% 
% % Save residual limits
% Ds_RL = [Ds_bias, Ds_lowerRL, Ds_upperRL];
% RLfolder = fullfile(projectfolder, 'Outputs', 'Model Fitting', 'Benign RL', 'Ball+Sphere');
% mkdir(RLfolder)
% save(fullfile(RLfolder, 'Ds_BenignRL.mat'), 'Ds_RL');
% save(fullfile(RLfolder, 'Ds_mean_bias.mat'), 'Ds_bias');
% save(fullfile(RLfolder, 'Ds_sigma.mat'), 'Ds_sigma');
% 
% 
% f1=figure;
% f1.Position = [680   400   600   380];
% ax1 = axes;
% 
% scatter(pred_Ds, Ds_diff ,  6, 'filled', 'MarkerFaceAlpha', 0.3, CData=COMP, HandleVisibility='off');
% hold on
% 
% % % yline(Db_bias, '-', DisplayName='Bias', LineWidth=1.2)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % yline(Db_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(Db_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% yline(Ds_bias, '-', DisplayName= '\mu', LineWidth=1.2)
% 
% % Add more sigma lines..
% yline(Ds_bias-1*Ds_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1.2)
% yline(Ds_bias+1*Ds_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% % Add more sigma lines..
% yline(Ds_bias-2*Ds_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1.2)
% yline(Ds_bias+2*Ds_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% 
% legend(Location="northeast")
% grid on
% ylim([-0.82, 1.12])
% yticks(-1:0.2:1)
% xlim([0.56, 2.04])
% xticks([0.6:0.2:2])
% xlabel('Predicted D_{sphere} (µm^2/ms)')
% ylabel('Measured - Predicted D_{sphere} (µm^2/ms)')
% 
% ax1.FontSize = 12;
% 
% % saveas(f1, fullfile(projectfolder, 'Thesis Figures', ['Benign Residuals Ds.png']))
% 
% 
% % Per sample plot
% 
% f2=figure;
% f2.Position = [680   400   600   380];
% ax2=axes;
% 
% sdiffs = [];
% sindxs = [];
% scolors = [];
% 
% for sindx = 1:length(Benign)
% 
%     snum = Benign{sindx};
%     sbool = ismember(SNums, snum);
%     sindxs = [sindxs; sindx*ones(sum(sbool), 1)];
% 
%     sdiff = Ds_diff(sbool);
%     scomp = COMP(sbool, :);
% 
%     sdiffs = [sdiffs; sdiff];
%     scolors = [scolors; mean(scomp)];
% 
% end
% 
% % % yline(Db_bias, '-', DisplayName='Bias', LineWidth=1.1, Alpha=0.4)
% % yline(0, '-', HandleVisibility = 'off', LineWidth=1.1, Alpha=0.4)
% % hold on
% % yline(Db_lowerRL, '--', DisplayName='95% Limits',  color = [.1 .1 .1], LineWidth=1.2)
% % yline(Db_upperRL, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1.2)
% % % boxplot(sdiffs, sindxs,'Colors','k')
% 
% % Add more sigma lines..
% yline(Ds_bias-1*Ds_sigma, '-.', DisplayName='\mu \pm \sigma',  color = [.1 .1 .1], LineWidth=1)
% hold on
% yline(Ds_bias+1*Ds_sigma, '-.', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% % Add more sigma lines..
% yline(Ds_bias-2*Ds_sigma, '--', DisplayName='\mu \pm 2\sigma',  color = [.1 .1 .1], LineWidth=1)
% yline(Ds_bias+2*Ds_sigma, '--', HandleVisibility="off",  color = [.1 .1 .1], LineWidth=1)
% 
% 
% for sindx = 1:length(Benign)
%     boxchart(sindxs(sindxs==sindx), sdiffs(sindxs==sindx), 'BoxFaceColor', scolors(sindx,:), 'HandleVisibility','off', MarkerStyle='.', MarkerColor=[.1, .1, .1])
%     hold on
% end
% 
% ylim([ax1.YLim])
% yticks([ax1.YTick])
% xlim([0.2, 14.8])
% xticks(1:20)
% 
% % Find box objects 
% h = findobj(ax2,'Tag','Box');
% set(h, 'LineWidth', 1.2)
% % Loop and assign colours
% for j = 1:length(h)
%     set(h(j), 'Color', scolors(length(h)-j+1,:));
% end
% 
% % Find outlier objects
% hOut = findobj(ax2,'Tag','Outliers');
% set(hOut, 'MarkerEdgeColor',[0.4 0.4 0.4], 'Marker','.')
% 
% legend(Location='northeast');
% ylabel('Measured - Predicted D_{sphere} (µm^2/ms)')
% xlabel('Sample Number')
% ax2.FontSize = 12;
% ax2.YGrid = 'on';
% ax2.Box = 'off';
% 
% % saveas(f2, fullfile(projectfolder, 'Thesis Figures', ['Benign Samples Residuals Ds.png']))
