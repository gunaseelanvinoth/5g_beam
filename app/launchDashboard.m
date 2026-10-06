% app/launchDashboard.m
% Complete Professional Dashboard for 5G Beam Failure Prediction Project

function launchDashboard(simData, conv_log, pro_log, cfg)

    % ─── Main Window ──────────────────────────────────────────────────
    f_main = uifigure('Name', '5G Beam Failure Prediction Dashboard', ...
        'Position', [50 30 1200 700], 'Color', [0.12 0.14 0.18]);
    f = uipanel(f_main, 'Position', [0 0 1200 700], 'Scrollable', 'on', 'BackgroundColor', [0.12 0.14 0.18], 'BorderType', 'none');

    % ─── Title Bar ────────────────────────────────────────────────────
    uilabel(f, 'Position', [20 800 900 40], ...
        'Text', '5G mmWave ML-Based Beam Failure Prediction & Recovery Dashboard', ...
        'FontSize', 20, 'FontWeight', 'bold', 'FontColor', [0.2 0.85 1.0]);

    uilabel(f, 'Position', [20 778 600 20], ...
        'Text', 'Final-Year ECE Project  |  MATLAB R2026b  |  Simulation-Based', ...
        'FontSize', 11, 'FontColor', [0.6 0.6 0.7]);

    % ─── Compute Metrics ──────────────────────────────────────────────
    conv_outage  = sum(conv_log.is_outage) * cfg.dt;
    pro_outage   = sum(pro_log.is_outage)  * cfg.dt;
    conv_sw      = sum(conv_log.switched);
    pro_sw       = sum(pro_log.switched);
    improvement  = max(0, ((conv_outage - pro_outage) / max(conv_outage, 0.001)) * 100);
    avg_snr      = mean(simData.snr_vals);
    min_snr      = min(simData.snr_vals);
    total_fail   = sum(simData.is_failure);
    blockage_pct = 100 * sum(simData.blockage_state) / height(simData);

    % ─── KPI Cards Row 1 ──────────────────────────────────────────────
    kpiCard(f, [20  680 180 85], 'Conv. Outage (s)',    sprintf('%.2f', conv_outage),  [0.95 0.3 0.3]);
    kpiCard(f, [210 680 180 85], 'ML Outage (s)',       sprintf('%.2f', pro_outage),   [0.2  0.9 0.4]);
    kpiCard(f, [400 680 180 85], 'Outage Reduction',    sprintf('%.1f%%', improvement),[0.2  0.75 1.0]);
    kpiCard(f, [590 680 180 85], 'Conv. Switches',      num2str(conv_sw),              [0.85 0.85 0.85]);
    kpiCard(f, [780 680 180 85], 'ML Switches',         num2str(pro_sw),               [0.85 0.85 0.85]);
    kpiCard(f, [970 680 180 85], 'Beam Failures',       num2str(total_fail),           [0.95 0.6 0.2]);

    % ─── KPI Cards Row 2 ──────────────────────────────────────────────
    kpiCard(f, [20  585 180 85], 'Avg SNR (dB)',        sprintf('%.1f', avg_snr),      [0.2 0.75 1.0]);
    kpiCard(f, [210 585 180 85], 'Min SNR (dB)',        sprintf('%.1f', min_snr),      [0.95 0.5 0.2]);
    kpiCard(f, [400 585 180 85], 'Blockage Rate',       sprintf('%.1f%%', blockage_pct),[0.8 0.5 0.9]);
    kpiCard(f, [590 585 180 85], 'Failure Threshold',   sprintf('%d dB', cfg.failure_threshold), [0.7 0.7 0.7]);
    kpiCard(f, [780 585 180 85], 'ML Threshold',        sprintf('%.1f', cfg.ml_threshold),       [0.7 0.7 0.7]);
    kpiCard(f, [970 585 180 85], 'UE Speed (m/s)',      num2str(cfg.ue_speed),         [0.7 0.7 0.7]);

    % ─── Divider Label ────────────────────────────────────────────────
    uilabel(f, 'Position', [20 562 400 18], ...
        'Text', '── LIVE SIMULATION CHARTS ──', ...
        'FontSize', 11, 'FontColor', [0.4 0.5 0.6], 'FontWeight', 'bold');

    % ─── Chart 1: SNR Over Time (large, bottom-left) ──────────────────
    ax1 = makeAxes(f, [20 310 610 240], 'SNR vs Time', 'Time (s)', 'SNR (dB)');
    plot(ax1, simData.time, simData.snr_vals, 'Color', [0.2 0.85 1.0], 'LineWidth', 1.8);
    yline(ax1, cfg.failure_threshold, 'r--', 'LineWidth', 1.5);
    text(ax1, max(simData.time)*0.02, cfg.failure_threshold+3, 'Failure Threshold', ...
        'Color', 'r', 'FontSize', 9);

    % ─── Chart 2: Outage Comparison Bar Chart (bottom-right) ──────────
    ax2 = makeAxes(f, [660 310 300 240], 'Outage Duration Comparison', 'System', 'Outage (s)');
    bar(ax2, [1 2], [conv_outage, pro_outage], 'FaceColor', 'flat', ...
        'CData', [0.9 0.3 0.3; 0.2 0.9 0.4]);
    ax2.XTick = [1 2];
    ax2.XTickLabel = {'Conventional', 'ML Proactive'};
    xtickangle(ax2, 0);
    text(ax2, 1, conv_outage + 0.3, sprintf('%.2fs', conv_outage), ...
        'HorizontalAlignment', 'center', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
    text(ax2, 2, pro_outage + 0.3, sprintf('%.2fs', pro_outage), ...
        'HorizontalAlignment', 'center', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');

    % ─── Chart 3: Blockage State Over Time ───────────────────────────
    ax3 = makeAxes(f, [980 310 300 240], 'Blockage Events Over Time', 'Time (s)', 'Blockage State');
    area(ax3, simData.time, simData.blockage_state, ...
        'FaceColor', [0.8 0.4 0.1], 'FaceAlpha', 0.7, 'EdgeColor', 'none');
    ax3.YTick = [0 1]; ax3.YTickLabel = {'Clear', 'Blocked'};
    ylim(ax3, [-0.1 1.5]);

    % ─── Chart 4: Beam Switches Timeline ─────────────────────────────
    ax4 = makeAxes(f, [20 55 610 230], 'Beam Switching Events', 'Time (s)', 'Switch Triggered');
    stem(ax4, simData.time, conv_log.switched, 'r', 'Marker', 'x', 'MarkerSize', 6);
    hold(ax4, 'on');
    stem(ax4, simData.time, pro_log.switched * 0.8, 'Color', [0.2 0.85 0.4], ...
        'Marker', 'o', 'MarkerSize', 5);
    legend(ax4, sprintf('Conventional (%d switches)', conv_sw), ...
                sprintf('ML Proactive (%d switches)', pro_sw), 'Location', 'northeast');
    ylim(ax4, [-0.1 1.3]);

    % ─── Chart 5: UE Position Over Time ──────────────────────────────
    ax5 = makeAxes(f, [660 55 620 230], 'UE Position (Distance from Base Station)', ...
        'Time (s)', 'Distance (m)');
    dist = sqrt(simData.ue_x.^2 + simData.ue_y.^2);
    plot(ax5, simData.time, dist, 'Color', [0.7 0.5 1.0], 'LineWidth', 1.8);
    outage_t = simData.time(simData.is_failure == 1);
    outage_d = dist(simData.is_failure == 1);
    scatter(ax5, outage_t, outage_d, 30, 'r', 'filled');
    legend(ax5, 'UE Distance', 'Failure Points', 'Location', 'northwest');

    fprintf('[Dashboard] All panels rendered successfully.\n');
end

% ─── Helper: KPI Card ─────────────────────────────────────────────────
function kpiCard(parent, pos, label, val, color)
    p = uipanel(parent, 'Position', pos, ...
        'BackgroundColor', [0.18 0.20 0.26], ...
        'ForegroundColor', [0.55 0.6 0.7], ...
        'Title', label, 'FontSize', 9);
    uilabel(p, 'Position', [5 8 pos(3)-15 38], ...
        'Text', val, 'FontSize', 22, 'FontWeight', 'bold', ...
        'FontColor', color, 'HorizontalAlignment', 'center');
end

% ─── Helper: Styled Axes ──────────────────────────────────────────────
function ax = makeAxes(parent, pos, titleStr, xlabelStr, ylabelStr)
    ax = uiaxes(parent, 'Position', pos);
    ax.Color       = [0.16 0.18 0.22];
    ax.XColor      = [0.7 0.75 0.8];
    ax.YColor      = [0.7 0.75 0.8];
    ax.GridColor   = [0.3 0.3 0.35];
    ax.GridAlpha   = 0.4;
    ax.Title.String = titleStr;
    ax.Title.Color  = [0.9 0.9 0.95];
    ax.Title.FontSize = 11;
    ax.XLabel.String  = xlabelStr;
    ax.YLabel.String  = ylabelStr;
    ax.XLabel.Color   = [0.65 0.7 0.8];
    ax.YLabel.Color   = [0.65 0.7 0.8];
    grid(ax, 'on');
end
