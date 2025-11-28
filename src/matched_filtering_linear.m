clc; clear; close all;

fs = 100;
c3_data = load('matched_filter/eeg2-c3.dat')';
template_range = [0.61, 0.83];
temp_idx = round(template_range(1)*fs):round(template_range(2)*fs);
template = c3_data(temp_idx);

% Derive Impulse Response h(t)
h_t = fliplr(template); 

% Compare Template and Impulse Response
f1 = figure;
subplot(2,1,1); plot(template); title('Template s(n)'); grid on;
subplot(2,1,2); plot(h_t); title('Impulse Response h(n) = s(-n)'); grid on;
saveas(f1, 'report/img/sec3_impulse_response.png');

% Filtering
channels = {'c3', 'c4', 'p4'};

for i = 1:length(channels)
    curr_chan = channels{i};
    signal = load(['matched_filter/eeg2-', curr_chan, '.dat'])';
    
    % Apply filter
    matched_output = filter(h_t, 1, signal);
    
    % Correct delay
    % The filter introduces a delay of (Length_Template - 1)/2 samples approx.
    delay = length(h_t); 
    
    f2 = figure;
    subplot(2,1,1);
    plot(signal); title(['Original EEG ', curr_chan]); axis tight;
    subplot(2,1,2);
    plot(matched_output); title(['Matched Filter Output (K=1) - ', curr_chan]); 
    axis tight;
    xlabel('Samples');
    
    saveas(f2, ['report/img/sec3_matched_linear_', curr_chan, '.png']);
end
