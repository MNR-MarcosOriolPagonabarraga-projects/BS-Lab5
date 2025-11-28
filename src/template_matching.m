clc; clear; close all;

fs = 100;
channels = {'c3', 'c4', 'p4'};
template_range = [0.61, 0.83]; % Seconds

% Load C3 to extract template first
c3_data = load('matched_filter/eeg2-c3.dat')';
time_axis = 0:1/fs:(length(c3_data)-1)/fs;

% Extract Template
temp_idx = round(template_range(1)*fs):round(template_range(2)*fs);
template = c3_data(temp_idx);
t_template = (0:length(template)-1)/fs;

% --- Plot 1: Template and Signal ---
f1 = figure; 
subplot(2,1,1); 
plot(time_axis, c3_data); 
title('EEG Channel C3'); 
xlabel('Time (s)'); 

subplot(2,1,2); 
plot(t_template, template); 
title('Extracted SWC Template'); 
xlabel('Time (s)');

saveas(f1, 'report/img/sec2_template_extraction.png');

% --- Loop through channels [cite: 30] ---
for i = 1:length(channels)
    curr_chan = channels{i};
    signal = load(['matched_filter/eeg2-', curr_chan, '.dat'])';
    
    % Cross Correlation
    [corr_raw, lags] = xcorr(signal, template);
    positive_indexes = lags >= 0;
    lags = lags(positive_indexes);
    corr_raw = corr_raw(positive_indexes);
    
    % Normalize
    corr_norm = corr_raw / max(abs(corr_raw));
    
    lag_time = lags/fs;
    
    % 4. Peak Detection
    threshold = 0.2;
    [pks, locs] = findpeaks(corr_norm, 'MinPeakHeight', threshold);
    peak_times = lag_time(locs);
    
    % --- Plotting ---
    f = figure;
    subplot(2,1,1);
    plot(time_axis, signal); 
    hold on;
    plot(peak_times, signal(round(peak_times*fs) + 1), 'rv', 'MarkerFaceColor','r');
    title(['EEG Signal: ', curr_chan]); xlabel('Time (s)'); axis tight;
    
    subplot(2,1,2);
    plot(lag_time, corr_norm); 
    hold on;
    plot(peak_times, pks, 'r*');
    yline(threshold, '--k', 'Threshold');
    title(['Normalized Cross-Correlation (', curr_chan, ')']); 
    xlabel('Lag Time (s)'); axis tight;
    
    saveas(f, ['report/img/sec2_ccf_', curr_chan, '.png']);
end
disp('Section 2 (Template Matching) complete. Images saved.');