%% 
%% Part 1 Monetary Policy Analysis 
% 

%--------------------------------------------------------------------------
%% 1. PRELIMINARIES:
clear all; clear session; close all; clc
warning off all
% Add current folder and subfolders (for Toolbox) to path
addpath(genpath(pwd)); 
%--------------------------------------------------------------------------
%% 2. LOAD DATA
filename = '../data/UK_Data_86_19.xlsx'; % Load data from the data directory
[xlsdata, xlstext] = xlsread(filename, 'Quarterly'); %fetch data from xlsx file (title/dates and numbers) from sheet quaterly
X = xlsdata; % put that data inside of a matrix X (all the data in variable X so its a matrix)

% Extract labels
vnames_raw = xlstext(1, 2:end); % select part of the text after the 2nd column
dates_raw  = xlstext(2:end, 1); % ignore 2nd row to the end and only takes 1st column

% Handle potential date column (Simplified one-liner)
if size(X,2) > 3, X = X(:, 2:end); end
[nobs, nvar] = size(X); %gets the number of observations 

vnames = vnames_raw(1:nvar);

%Transform CPI (col 2) into Inflation
cpi_idx = 2; %cpi in the 2nd column
cpi = X(:, cpi_idx); %make a list "cpi" out of the cpi column 
pi_yoy = 100 * (log(cpi(5:end)) - log(cpi(1:end-4))); %get the percentage rate growth of cpi for later use in the model (comparison)

% Trim dataset
X_trim = X(5:end, :); %make a new list with data after year 1 
X_trim(:, cpi_idx) = pi_yoy; % replace the first year cpi with percentage change
dates = dates_raw(5:end); % set the dates to after year 1
vnames{cpi_idx} = 'Inflation (yoy)'; %show what the column represents (legende)
X = X_trim; %change data to new version
[nobs, nvar] = size(X); %get the dimension of the matrix (get rows and columns)
fprintf('Variables: %s\n', strjoin(vnames, ', ')); %print names of variables from X matrix
%--------------------------------------------------------------------------
%% 3. PLOT RAW SERIES (Beige/Blue Theme)
time_idx = 1:nobs;
% --- Color Palette ---
color_bg    = [0.96 0.96 0.86]; % Beige Background
color_line  = [0.00 0.45 0.74]; % Main Line Blue
color_text  = [0.00 0.10 0.40]; % Dark Blue (Text/Legends)
color_band  = [0.30 0.75 0.93]; % Light Blue (Bands) (Not used in raw plot but kept for IRF)

% Create Figure with Beige Background
figure('Name', 'Raw Data', 'Color', color_bg, 'Position', [100 100 800 600]); 

% GDP
ax1 = subplot(3, 1, 1); %position of the plot in the window (top)
plot(time_idx, X(:, 1), 'Color', color_line, 'LineWidth', 2); %put the data (time on x axis, and value (of X matrix) on the y axis)
title('Raw Data', 'Color', color_text);
ylabel('Output/GDP', 'Color', color_text); %label of the graph (legend)

% Inflation
ax2 = subplot(3, 1, 2);
plot(time_idx, X(:, 2), 'Color', color_line, 'LineWidth', 2);
ylabel('Inflation (yoy, %)', 'Color', color_text);

% Interest Rate
ax3 = subplot(3, 1, 3);
plot(time_idx, X(:, 3), 'Color', color_line, 'LineWidth', 2);
ylabel('Interest rate (%)', 'Color', color_text);
xlabel('Time (quarters)', 'Color', color_text);

% Apply Beige/Dark Blue Styling to all subplots
all_axes = [ax1, ax2, ax3];
set(all_axes, 'Color', color_bg, ...       % Plot background
              'XColor', color_text, ...    % X-axis text color
              'YColor', color_text, ...    % Y-axis text color
              'LineWidth', 1.1);           
linkaxes(all_axes, 'x');
for ax = all_axes
    axes(ax); grid on; axis tight;
end
%---------------------------------------------------------------------------
%% 4. VAR SETUP
log_y = log(X(:, 1)); %log the list of gdp values
X_VAR = [log_y, X(:, 2), X(:, 3)]; % new matrix with 1st column = gdp and 2nd+3rd are raw data
vnames_VAR = {'log GDP', 'Inflation', 'Interest Rate'}; 

% Lag Selection (Calculates best lag automatically)
maxlags = 8; %set lag to 8
detvar = 2; %get constant and trend for model 
AIC = zeros(maxlags, 1); %store akaike information (max lag calculations)
for p = 1:maxlags %for loop with number of lags (test different versions of var model by using different no of lags)
    VAR_temp = VARmodel(X_VAR, p, detvar); 
    k = VAR_temp.nvar; T = VAR_temp.nobs; m = k*p + detvar; 
    logdetSigma = log(det(VAR_temp.sigma));
    AIC(p) = logdetSigma + (2*m)/T;
end
[~, nlags] = min(AIC); %find the best lag that balances accuracy and complexity
fprintf('Selected Lag: %d\n', nlags);
%--------------------------------------------------------------------------
%% 5. ESTIMATE VAR and stationarity check
[VAR, VARopt] = VARmodel(X_VAR, nlags, detvar); %creates the version of var model with all the data we treated above (get both outputs in VAT, VARopt)
VARopt.vnames = vnames_VAR; %store names of variables in another variable

% Stationarity check
fprintf('Max eigenvalue of companion matrix: %.4f\n', VAR.maxEig);

if VAR.maxEig < 1
    disp('--> VAR is stationary (all roots inside unit circle).');
else
    warning('*** VAR is NOT stationary (at least one root on/ outside unit circle).');
end



%--------------------------------------------------------------------------
%% 6. CALCULATE IRFS
VARopt.nsteps = 24; %setting the timeline for
VARopt.ident = 'oir'; %Cholesky
VARopt.impact = 1; % 0 = 1 std shock / 1 = unit shock
VARopt.pctg  = 68; % Lower bound = (100 - pctg ) /2 / Upper bound = 100 - (100 - pctg ) /2
[IRF, VAR] = VARir(VAR, VARopt); %Computer IRF
[IRFINF, IRFSUP, IRFMED] = VARirband(VAR, VARopt); %Computer error bands
%---------------------------------------------------------------------------

%% 7. PLOT IRFS and added color theme
horizons = 0:(VARopt.nsteps-1);
shock_names  = {'Shock to Output/GDP', 'Shock to Price', 'Shock to Interest Rate'};

figure('Name', 'Impulse Response Functions', 'Color', color_bg, 'Position', [100 100 800 600]);

for j = 1:3 
    for k = 1:3 
        ax = subplot(3, 3, (j-1)*3 + k);
        
        %Plot Confidence Bands (Light Bleu)
        plot(horizons, IRFINF(:, j, k), '--', 'Color', color_band, 'LineWidth', 1.5); hold on;
        plot(horizons, IRFSUP(:, j, k), '--', 'Color', color_band, 'LineWidth', 1.5);
        
        %Plot Median (Main Blue Solid)
        plot(horizons, IRFMED(:, j, k), '-', 'Color', color_line, 'LineWidth', 2); 
        
        %zero line (Dark Blue Dotted)
        yline(0, 'Color', color_text, 'LineStyle', ':'); 
        
        xlim([0 VARopt.nsteps-1]);
        
        %Apply Beige/Dark Blue Styling
        set(ax, 'Color', color_bg, 'XColor', color_text, 'YColor', color_text); 
        grid on;
        
        % Titles
        if j == 1, title(shock_names{k}, 'Color', color_text, 'FontWeight','bold'); end
        if k == 1, ylabel(vnames_VAR{j}, 'Color', color_text, 'FontWeight','bold'); end
        if j == 3, xlabel('Quarters', 'Color', color_text); end
    end
end
sgtitle('Impulse Responses with Cholesky', 'Color', color_text);