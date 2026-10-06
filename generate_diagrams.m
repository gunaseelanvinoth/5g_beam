cd('C:\Users\ELCOT\.gemini\antigravity\scratch\5G_BeamFailure_Project');
addpath('app','simulation','dataset','ml','recovery','visualization','reports');

% 1. Dashboard
cfg = config();
[simData, ~] = simulateCommunication(cfg);
dataset = generateDataset(simData, cfg);
mdl = trainModel(dataset);
[conv_log, ~, ~] = conventionalRecovery(simData, cfg);
[pro_log, ~, ~] = proactiveRecovery(simData, cfg, mdl);
launchDashboard(simData, conv_log, pro_log, cfg);
f1 = gcf;
exportgraphics(f1, 'results/reports/Dashboard.png', 'Resolution', 150);
close(f1);

% 2. System Architecture Block Diagram
f2 = figure('Position', [100 100 800 300], 'Color', 'w'); axis off;
rectangle('Position', [0.05 0.3 0.25 0.4], 'Curvature', 0.1, 'FaceColor', [0.8 0.9 1], 'LineWidth', 1.5);
text(0.175, 0.5, sprintf('5G Base Station\n(mmWave TX)'), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
rectangle('Position', [0.4 0.3 0.2 0.4], 'Curvature', 0.1, 'FaceColor', [0.8 1 0.8], 'LineWidth', 1.5);
text(0.5, 0.5, sprintf('Wireless Channel\n& Blockage Model'), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
rectangle('Position', [0.7 0.3 0.25 0.4], 'Curvature', 0.1, 'FaceColor', [1 0.9 0.8], 'LineWidth', 1.5);
text(0.825, 0.5, sprintf('User Equipment\n(Mobility)'), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
annotation('arrow', [0.3 0.4], [0.5 0.5], 'LineWidth', 2);
annotation('arrow', [0.6 0.7], [0.5 0.5], 'LineWidth', 2);
exportgraphics(f2, 'results/reports/Block_Diagram.png', 'Resolution', 300);
close(f2);

% 3. ML Flowchart
f3 = figure('Position', [100 100 600 600], 'Color', 'w'); axis off;
boxes = {'Simulation Data Extraction', 'Feature Engineering (SNR, Blockage)', 'Decision Tree Classifier Training', 'Proactive Beam Switching Logic'};
colors = {[0.9 0.9 1], [0.9 1 0.9], [1 0.9 0.9], [1 0.9 1]};
for i=1:4
    y = 0.85 - (i-1)*0.22;
    rectangle('Position', [0.2 y-0.08 0.6 0.12], 'Curvature', 0.2, 'FaceColor', colors{i}, 'LineWidth', 1.5);
    text(0.5, y-0.02, boxes{i}, 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 12);
    if i<4
        annotation('arrow', [0.5 0.5], [y-0.08 y-0.12], 'LineWidth', 2);
    end
end
exportgraphics(f3, 'results/reports/ML_Flowchart.png', 'Resolution', 300);
close(f3);

% 4. Beamforming Concept
f4 = figure('Position', [100 100 600 400], 'Color', 'w'); axis off; hold on;
plot(0, 0, 'k^', 'MarkerSize', 20, 'MarkerFaceColor', 'k'); % BS
text(0, -0.5, '5G Base Station', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
angles = [-30, -15, 0, 15, 30];
for i=1:5
    ang = angles(i) * pi/180;
    x = [0, 5*sin(ang)]; y = [0, 5*cos(ang)];
    plot(x, y, 'b--', 'LineWidth', 1.5);
    text(x(2)*1.1, y(2)*1.1, sprintf('Beam %d', i), 'HorizontalAlignment', 'center', 'Color', 'b', 'FontWeight', 'bold');
end
plot(3*sin(10*pi/180), 3*cos(10*pi/180), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
text(3*sin(10*pi/180)+0.6, 3*cos(10*pi/180), 'Moving UE', 'FontWeight', 'bold', 'Color', 'r');
xlim([-4 4]); ylim([-1 6]);
exportgraphics(f4, 'results/reports/Beamforming_Concept.png', 'Resolution', 300);
close(f4);

disp('Diagrams generated successfully.');
