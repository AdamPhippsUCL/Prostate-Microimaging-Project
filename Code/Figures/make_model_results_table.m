% Script to format modelling results into table

clear;
projectfolder = pwd;

%%

% Load model fitting results
RESULTS = load(fullfile(projectfolder, 'Outputs', 'Model Fitting', 'ESL signal profiles', 'Multi-sample', 'RESULTS.mat')).RESULTS;
N = length(RESULTS);

% Initialise table
T = table( ...
    'Size', ...
    [N, 4], ...
    'VariableTypes', {'string', 'string', 'string', 'string'}, ...
    'VariableNames', {'Component', 'Model Name', 'Estimated Parameters', 'AICc'});


% Number sig figs
nsf=4;

% Fill in table
for indx = 1:N

    component = RESULTS(indx).Component;
    modelname = RESULTS(indx).ModelName;
    params = RESULTS(indx).ModelParams;
    error = RESULTS(indx).ParamError;
    AIC = RESULTS(indx).AIC;
    AICc = RESULTS(indx).AICc;

    % Component
    switch component
        case 'E'
            T{indx, 'Component'} = {'Epithelium'};
        case 'S'
            T{indx, 'Component'} = {'Stroma'};
    end

    % Parameters and errors
    switch modelname
        case 'ADC'
            
            T{indx, 'Model Name'} = {modelname};
            
            T{indx, 'Estimated Parameters'} = {[...
                'S0 = ' num2str(round(params(1), nsf, 'significant')) ' (' num2str(round(params(1)-error(1), nsf, 'significant')) ', ' num2str(round(params(1)+error(1), nsf, 'significant')) '); ' ...
                'D = ' num2str(round(params(2), nsf, 'significant')) ' (' num2str(round(params(2)-error(2), nsf, 'significant')) ', ' num2str(round(params(2)+error(2), nsf, 'significant')) ') x1e-3 mm^2/s' ...
            ]};

        case 'DKI'
            T{indx, 'Model Name'} = {modelname};

            T{indx, 'Estimated Parameters'} = {[...
                    'S0 = ' num2str(round(params(1), nsf, 'significant')) ' (' num2str(round(params(1)-error(1), nsf, 'significant')) ', ' num2str(round(params(1)+error(1), nsf, 'significant')) '); ' ...
                    'D = ' num2str(round(params(2), nsf, 'significant')) ' (' num2str(round(params(2)-error(2), nsf, 'significant')) ', ' num2str(round(params(2)+error(2), nsf, 'significant')) ') x1e-3 mm^2/s; ' ...
                    'K = ' num2str(round(params(3), nsf, 'significant')) ' (' num2str(round(params(3)-error(3), nsf, 'significant')) ', ' num2str(round(params(3)+error(3), nsf, 'significant')) ')' ...
                ]};

            % disp('HERE')

        case 'Sphere'
            T{indx, 'Model Name'} = {'Sphere'};
            
            T{indx, 'Estimated Parameters'} = {[...
                'S0 = ' num2str(round(params(3), nsf, 'significant')) ' (' num2str(round(params(3)-error(3), nsf, 'significant')) ', ' num2str(round(params(3)+error(3), nsf, 'significant')) '); ' ...
                'D = ' num2str(round(params(2), nsf, 'significant')) ' (' num2str(round(params(2)-error(2), nsf, 'significant')) ', ' num2str(round(params(2)+error(2), nsf, 'significant')) ') x1e-3 mm^2/s; ' ...
                'R = ' num2str(round(params(1), nsf, 'significant')) ' (' num2str(round(params(1)-error(1), nsf, 'significant')) ', ' num2str(round(params(1)+error(1), nsf, 'significant')) ') µm' ...
            ]};


        case 'Ball+Sphere'
            T{indx, 'Model Name'} = {'Ball + Sphere'};
    
            T{indx, 'Estimated Parameters'} = {[...
                'S0 = ' num2str(round(params(5), nsf, 'significant')) ' (' num2str(round(params(5)-error(5), nsf, 'significant')) ', ' num2str(round(params(5)+error(5), nsf, 'significant')) '); ' ...
                'f_sphere = ' num2str(round(params(1), nsf, 'significant')) ' (' num2str(round(params(1)-error(1), nsf, 'significant')) ', ' num2str(round(params(1)+error(1), nsf, 'significant')) '); ' ...
                'D_sphere = ' num2str(round(params(3), nsf, 'significant')) ' (' num2str(round(params(3)-error(3), nsf, 'significant')) ', ' num2str(round(params(3)+error(3), nsf, 'significant')) ') x1e-3 mm^2/s; ' ...
                'R = ' num2str(round(params(2), nsf, 'significant')) ' (' num2str(round(params(2)-error(2), nsf, 'significant')) ', ' num2str(round(params(2)+error(2), nsf, 'significant')) ') µm; ' ...
                'D_ball = ' num2str(round(params(4), nsf, 'significant')) ' (' num2str(round(params(4)-error(4), nsf, 'significant')) ', ' num2str(round(params(4)+error(4), nsf, 'significant')) ') x1e-3 mm^2/s' ...
            ]};

    end

    % % AIC
    % T{indx, 'AIC'} = {sprintf('%.3f', AIC)};

    % AICc
    T{indx, 'AICc'} = {sprintf('%.1f', AICc)};
end

% Save as excel sheet
writetable(T, fullfile(projectfolder, 'Thesis Figures', 'modelling_results.xlsx'));

