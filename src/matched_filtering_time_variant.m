clc; clear; close all;

fs = 100;
c3_data = load('matched_filter/eeg2-c3.dat')';
template_range = [0.61, 0.83];
temp_idx = round(template_range(1)*fs):round(template_range(2)*fs);
template = c3_data(temp_idx);
h_t = fliplr(template);
threshold = 0.2;

channels = {'c3', 'c4', 'p4'};

% Energy of the Template
E_template = sum(template.^2);

for i = 1:length(channels)
    curr_chan = channels{i};
    signal = load(['matched_filter/eeg2-', curr_chan, '.dat'])';
    
    % Standard Matched Filter
    y_raw = filter(h_t, 1, signal);
    
    % Local Signal Energy
    ones_filter = ones(size(template));
    E_local = filter(ones_filter, 1, signal.^2);
    
    % Time-Variant K and Normalize
    E_local(E_local == 0) = eps; 
    
    normalization_factor = sqrt(E_template * E_local);
    y_normalized = y_raw ./ normalization_factor;
    
    % Peak Detection
    [pks, locs] = findpeaks(y_normalized, 'MinPeakHeight', threshold);
    
    % Plotting
    f = figure;
    
    subplot(2,1,1);
    plot(signal); 
    hold on;
    % Shift locations back by template length for visualization alignment
    plot(locs - length(template)/2, signal(max(1, round(locs - length(template)/2))), 'rv');
    title(['EEG ', curr_chan, ' with Detected SWCs']); axis tight;
    
    subplot(2,1,2);
    plot(y_normalized); 
    hold on;
    plot(locs, pks, 'r*');
    yline(threshold, '--k'); 
    ylim([-1.1 1.1]);
    title(['Normalized Matched Filter Output (-1 to 1) - ', curr_chan]); 
    grid on;
    
    saveas(f, ['report/img/sec3_matched_normalized_', curr_chan, '.png']);
end