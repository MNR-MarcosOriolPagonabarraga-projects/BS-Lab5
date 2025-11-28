clc; clear; close all;

fs = 100;
c3_data = load('matched_filter/eeg2-c3.dat')';
template_range = [0.61, 0.83];
temp_idx = round(template_range(1)*fs):round(template_range(2)*fs);
template = c3_data(temp_idx);
h_t = fliplr(template);
E_template = sum(template.^2);
threshold = 0.2;

% SNRs to test
snr_values = [20, 15, 10, 5, 0, -5];

f_main = figure('Position', [100, 100, 1000, 1200]);

for k = 1:length(snr_values)
    current_snr = snr_values(k);
    
    % Add Noise
    noisy_signal = awgn(c3_data, current_snr, 'measured');
    
    % Apply Normalized Matched Filter
    y_raw = filter(h_t, 1, noisy_signal);
    ones_filter = ones(size(template));
    E_local = filter(ones_filter, 1, noisy_signal.^2);
    E_local(E_local <= 0) = eps;
    y_norm = y_raw ./ sqrt(E_template * E_local);
    
    % Plotting Subplots
    subplot(length(snr_values), 2, 2*k - 1);
    plot(noisy_signal); 
    title(['Noisy Input (SNR = ', num2str(current_snr), ' dB)']); 
    axis tight;
    
    subplot(length(snr_values), 2, 2*k);
    plot(y_norm);
    yline(threshold, '--r');
    ylim([-1 1]);
    title(['Filter Output (SNR = ', num2str(current_snr), ' dB)']);
    grid on;
end

saveas(f_main, 'report/img/sec3_noise_robustness.png');