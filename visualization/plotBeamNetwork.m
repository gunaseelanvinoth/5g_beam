% visualization/plotBeamNetwork.m
function plotBeamNetwork(simData, cfg)
    fig = figure('Name', 'Physical Network Simulation', 'Color', 'w', 'Position', [150 150 800 600]);
    
    % Base Station
    plot(0, 0, '^', 'MarkerSize', 15, 'MarkerFaceColor', 'k');
    hold on;
    
    % UE path
    plot(simData.ue_x, simData.ue_y, 'k--', 'LineWidth', 1);
    
    % Plot beams
    for i = 1:cfg.num_beams
        angle = cfg.beam_angles(i);
        length_m = max(simData.ue_x); 
        x_beam = length_m * cosd(angle);
        y_beam = length_m * sind(angle);
        
        plot([0, x_beam], [0, y_beam], 'b:', 'LineWidth', 1.5);
        text(x_beam, y_beam, sprintf('Beam %d', i), 'FontSize', 10);
    end
    
    % Scatter points for outages
    outage_idx = find(simData.snr_vals < cfg.failure_threshold);
    scatter(simData.ue_x(outage_idx), simData.ue_y(outage_idx), 50, 'r', 'filled');
    
    title('5G mmWave Base Station and UE Mobility Path');
    xlabel('X Position (meters)');
    ylabel('Y Position (meters)');
    legend('Base Station', 'UE Path', 'Beam Directions', 'Location', 'Best');
    grid on;
    axis equal;
    
    saveas(fig, 'results/figures/Physical_Network.png');
end
