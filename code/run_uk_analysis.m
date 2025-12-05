%% Part 1 Monetary Policy Analysis

%--------------------------------------------------------------------------
%% 1. PRELIMINARIES:
clear all; clear session; close all; clc
warning off all
addpath(genpath(pwd)); 

%--------------------------------------------------------------------------
%% 2. LOAD DATA
filename = '../data/UK_Data.xlsx';
[xlsdata, xlstext] = xlsread(filename, 'Quarterly');
X = xlsdata;

% Extract labels
vnames_raw = xlstext(1, 2:end);
dates_raw  = xlstext(2:end, 1);

% Handle potential date column
if size(X,2) > 3, X = X(:, 2:end); end
[nobs, nvar] = size(X);

vnames = vnames_raw(1:nvar);

% Transform CPI (col 2) into Inflation
cpi_idx = 2;
cpi = X(:, cpi_idx);
pi_yoy = 100 * (log(cpi(5:end)) - log(cpi(1:end-4)));

% Trim dataset
X_trim = X(5:end, :);
X_trim(:, cpi_idx) = pi_yoy;
dates = dates_raw(5:end);
vnames{cpi_idx} = 'Inflation (yoy)';
X = X_trim;
[nobs, nvar] = size(X);
fprintf('Variables: %s\n', strjoin(vnames, ', '));

%--------------------------------------------------------------------------
%% 3. PLOT RAW SERIES
time_idx = 1:nobs;

% Color Palette
color_bg    = [0.96 0.96 0.86];
color_line  = [0.00 0.45 0.74];
color_text  = [0.00 0.10 0.40];
color_band  = [0.30 0.75 0.93];

% Date labels setup
label_step = 4;
all_ticks  = 1:nobs;
year_label = cellfun(@(s) s(end-3:end), dates, 'UniformOutput', false);
all_labels = repmat({''}, nobs, 1);
all_labels(1:label_step:end) = year_label(1:label_step:end);

figure('Name', 'Raw Data', 'Color', color_bg, 'Position', [100 100 800 600]); 

% GDP
ax1 = subplot(3, 1, 1);
plot(time_idx, X(:, 1), 'Color', color_line, 'LineWidth', 2);
title('Raw Data', 'Color', color_text);
ylabel('Output/GDP', 'Color', color_text);
xticks(all_ticks);
xticklabels(all_labels);
xtickangle(45);

% Inflation
ax2 = subplot(3, 1, 2);
plot(time_idx, X(:, 2), 'Color', color_line, 'LineWidth', 2);
ylabel('Inflation (yoy, %)', 'Color', color_text);
xticks(all_ticks);
xticklabels(all_labels);
xtickangle(45);

% Interest Rate
ax3 = subplot(3, 1, 3);
plot(time_idx, X(:, 3), 'Color', color_line, 'LineWidth', 2);
ylabel('Interest rate (%)', 'Color', color_text);
xlabel('Time (quarters)', 'Color', color_text);
xticks(all_ticks);
xticklabels(all_labels);
xtickangle(45);

% Apply styling to all subplots
all_axes = [ax1, ax2, ax3];
set(all_axes, 'Color', color_bg, 'XColor', color_text, 'YColor', color_text, 'LineWidth', 1.1);           
linkaxes(all_axes, 'x');
for ax = all_axes
    axes(ax); grid on; axis tight;
end

%--------------------------------------------------------------------------
%% 4. VAR SETUP AND LAG SELECTION
log_y = log(X(:, 1));
X_VAR = [log_y, X(:, 2), X(:, 3)];
vnames_VAR = {'log GDP', 'Inflation', 'Interest Rate'}; 

maxlags = 8;
detvar = 2;

% Preallocate information criteria arrays
AIC = zeros(maxlags, 1);
BIC = zeros(maxlags, 1);
HQC = zeros(maxlags, 1);

% Loop over lag lengths and compute information criteria
for p = 1:maxlags
    VAR_temp = VARmodel(X_VAR, p, detvar); 
    k = VAR_temp.nvar;
    T = VAR_temp.nobs;
    m = k*p + detvar;
    logdetSigma = log(det(VAR_temp.sigma));
    
    AIC(p) = logdetSigma + (2*m)/T;
    BIC(p) = logdetSigma + (log(T)*m)/T;
    HQC(p) = logdetSigma + (2*log(log(T))*m)/T;
end

% Choose lag that minimizes each criterion
[minAIC, lag_AIC] = min(AIC);
[minBIC, lag_BIC] = min(BIC);
[minHQC, lag_HQC] = min(HQC);

% Select best method
crit_values    = [minAIC, minBIC, minHQC];
crit_names     = {'AIC', 'BIC', 'HQC'};
lag_candidates = [lag_AIC, lag_BIC, lag_HQC];

[~, idx_best] = min(crit_values);
nlags = lag_candidates(idx_best);
chosen_crit = crit_names{idx_best};

fprintf('AIC: min = %.4f at lag %d\n', minAIC, lag_AIC);
fprintf('BIC: min = %.4f at lag %d\n', minBIC, lag_BIC);
fprintf('HQC: min = %.4f at lag %d\n', minHQC, lag_HQC);
fprintf('---> Chosen lag: %d (criterion: %s)\n', nlags, chosen_crit);

%--------------------------------------------------------------------------
%% 5. ESTIMATE VAR
[VAR, VARopt] = VARmodel(X_VAR, nlags, detvar);
VARopt.vnames = vnames_VAR;

% Stationarity check
fprintf('Max eigenvalue of companion matrix: %.4f\n', VAR.maxEig);

if VAR.maxEig < 1
    disp('---> VAR is stationary (all roots inside unit circle).');
else
    warning('*** VAR is NOT stationary (at least one root on/outside unit circle).');
end

%--------------------------------------------------------------------------
%% 6. CALCULATE IRFS
VARopt.nsteps = 24;
VARopt.ident = 'oir';
VARopt.pctg  = 68;
[IRF, VAR] = VARir(VAR, VARopt);
[IRFINF, IRFSUP, IRFMED] = VARirband(VAR, VARopt);

%--------------------------------------------------------------------------
%% 7. PLOT IRFS
horizons = 0:(VARopt.nsteps-1);
shock_names  = {'Shock to Output/GDP', 'Shock to Price', 'Shock to Interest Rate'};

figure('Name', 'Impulse Response Functions', 'Color', color_bg, 'Position', [100 100 800 600]);

for j = 1:3 
    for k = 1:3 
        ax = subplot(3, 3, (j-1)*3 + k);
        
        % Confidence Bands
        plot(horizons, IRFINF(:, j, k), '--', 'Color', color_band, 'LineWidth', 1.5); hold on;
        plot(horizons, IRFSUP(:, j, k), '--', 'Color', color_band, 'LineWidth', 1.5);
        
        % Median
        plot(horizons, IRFMED(:, j, k), '-', 'Color', color_line, 'LineWidth', 2); 
        
        % Zero line
        yline(0, 'Color', color_text, 'LineStyle', ':'); 
        
        xlim([0 VARopt.nsteps-1]);
        
        set(ax, 'Color', color_bg, 'XColor', color_text, 'YColor', color_text); 
        grid on;
        
        if j == 1, title(shock_names{k}, 'Color', color_text, 'FontWeight','bold'); end
        if k == 1, ylabel(vnames_VAR{j}, 'Color', color_text, 'FontWeight','bold'); end
        if j == 3, xlabel('Quarters', 'Color', color_text); end
    end
end
sgtitle('Impulse Responses with Cholesky', 'Color', color_text);

% Save plot to output directory
saveas(gcf, '../output/IRF_Plots.png');