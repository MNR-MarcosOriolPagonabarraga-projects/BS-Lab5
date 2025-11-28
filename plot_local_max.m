function plot_local_max(signal, corr, time, local_max, thresh)
    figure;
    subplot(2,1,1);
    plot(time, signal, time(local_max), signal(local_max), 'r*');
    title('EEG C3')
    xlabel('Time (s)')
    grid on

    subplot(2,1,2);
    plot(time, corr, time(local_max), corr(local_max), 'r*')
    yline(thresh,'--k');
    title('Normalized Correlation');
    xlabel('Time (s)');
    legend('Signal', 'Local maxima', 'Threshold', 'Location', 'best');
    grid on;
end
