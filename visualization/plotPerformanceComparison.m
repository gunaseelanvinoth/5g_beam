% visualization/plotPerformanceComparison.m
function plotPerformanceComparison(simData, conv_log, pro_log)
    fig = figure('Name', 'Performance Comparison', 'Color', 'w', 'Position', [100 100 1000 600]);
    
    % Outages
    subplot(2,1,1);
    plot(simData.time, conv_log.is_outage, 'r', 'LineWidth', 1.5);
    hold on;
    plot(simData.time, pro_log.is_outage + 1.1, 'b', 'LineWidth', 1.5); % Offset for visibility
    ylim([-0.5 2.5]);
    yticks([0 1 1.1 2.1]);
    yticklabels({'No Outage (Conv)', 'Outage (Conv)', 'No Outage (Pro)', 'Outage (Pro)'});
    title('Outage Events Over Time');
    xlabel('Time (s)');
    legend('Conventional', 'Proactive (ML)');
    grid on;
    
    % Switching Events
    subplot(2,1,2);
    stem(simData.time, conv_log.switched, 'r', 'Marker', 'x');
    hold on;
    stem(simData.time, pro_log.switched, 'b', 'Marker', 'o');
    title('Beam Switching Events');
    xlabel('Time (s)');
    ylabel('Switch Triggered');
    legend('Conventional', 'Proactive (ML)');
    grid on;
    
    saveas(fig, 'results/figures/Performance_Comparison.png');
end
