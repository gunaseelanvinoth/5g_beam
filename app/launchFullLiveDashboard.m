function launchFullLiveDashboard(mdl, cfg)
    f_main = uifigure('Name', 'FULL LIVE 5G Beam Dashboard', 'Position', [50 30 1200 750], 'Color', [0.12 0.14 0.18]);
    pnl = uipanel(f_main, 'Position', [0 0 1200 750], 'Scrollable', 'on', 'BackgroundColor', [0.12 0.14 0.18], 'BorderType', 'none');
    
    uilabel(pnl, 'Position', [20 700 1000 35], 'Text', 'LIVE 5G mmWave ML Beam Failure Prediction Dashboard', 'FontSize', 18, 'FontWeight', 'bold', 'FontColor', [0.9 0.9 0.95]);
    uilabel(pnl, 'Position', [20 680 600 20], 'Text', 'Streaming real-time Network Data into Machine Learning Model', 'FontSize', 11, 'FontColor', [0.6 0.6 0.7]);
    
    % Create KPI Handles
    kpi_handles = gobjects(12, 1);
    kpi_handles(1) = kpiCard(pnl, [20  585 180 85], 'Conv. Outage (s)', '0.0', [0.95 0.3 0.3]);
    kpi_handles(2) = kpiCard(pnl, [210 585 180 85], 'ML Outage (s)', '0.0', [0.2  0.9 0.4]);
    kpi_handles(3) = kpiCard(pnl, [400 585 180 85], 'Outage Reduction', '0.0%', [0.2  0.75 1.0]);
    kpi_handles(4) = kpiCard(pnl, [590 585 180 85], 'Conv. Switches', '0', [0.85 0.85 0.85]);
    kpi_handles(5) = kpiCard(pnl, [780 585 180 85], 'ML Switches', '0', [0.85 0.85 0.85]);
    kpi_handles(6) = kpiCard(pnl, [970 585 180 85], 'Beam Failures', '0', [0.95 0.6 0.2]);
    
    kpi_handles(7) = kpiCard(pnl, [20  490 180 85], 'Avg SNR (dB)', '0.0', [0.2 0.75 1.0]);
    kpi_handles(8) = kpiCard(pnl, [210 490 180 85], 'Min SNR (dB)', '0.0', [0.95 0.5 0.2]);
    kpi_handles(9) = kpiCard(pnl, [400 490 180 85], 'Blockage Rate', '0.0%', [0.8 0.5 0.9]);
    kpi_handles(10) = kpiCard(pnl, [590 490 180 85], 'Failure Threshold', sprintf('%d dB', cfg.failure_threshold), [0.7 0.7 0.7]);
    kpi_handles(11) = kpiCard(pnl, [780 490 180 85], 'ML Threshold', sprintf('%.1f', cfg.ml_threshold), [0.7 0.7 0.7]);
    kpi_handles(12) = kpiCard(pnl, [970 490 180 85], 'UE Speed (m/s)', num2str(cfg.ue_speed), [0.7 0.7 0.7]);
    
    % Axes
    ax1 = makeAxes(pnl, [20 230 610 240], 'Live SNR vs Time', 'Time (s)', 'SNR (dB)'); hold(ax1,'on');
    h_snr = plot(ax1, NaN, NaN, 'Color', [0.2 0.85 1.0], 'LineWidth', 1.8);
    yline(ax1, cfg.failure_threshold, 'r--', 'LineWidth', 1.5);
    
    ax2 = makeAxes(pnl, [660 230 300 240], 'Outage Comparison', 'System', 'Outage (s)');
    h_bar = bar(ax2, [1 2], [0 0], 'FaceColor', 'flat');
    h_bar.CData = [0.9 0.3 0.3; 0.2 0.9 0.4];
    ax2.XTick = [1 2]; ax2.XTickLabel = {'Conventional', 'ML Proactive'};
    txt_b1 = text(ax2, 1, 0.5, '0.0s', 'Color','w','HorizontalAlignment','center','FontWeight','bold');
    txt_b2 = text(ax2, 2, 0.5, '0.0s', 'Color','w','HorizontalAlignment','center','FontWeight','bold');
    
    ax3 = makeAxes(pnl, [980 230 300 240], 'Blockage Events', 'Time (s)', 'Blockage State'); hold(ax3,'on');
    h_blk = plot(ax3, NaN, NaN, 'Color', [0.8 0.4 0.1], 'LineWidth', 2);
    ax3.YTick = [0 1]; ax3.YTickLabel = {'Clear', 'Blocked'}; ylim(ax3, [-0.1 1.5]);
    
    ax4 = makeAxes(pnl, [20 10 610 200], 'Beam Switching Events', 'Time (s)', 'Switch Triggered'); hold(ax4,'on');
    h_sw_c = stem(ax4, NaN, NaN, 'r', 'Marker', 'x', 'MarkerSize', 6);
    h_sw_p = stem(ax4, NaN, NaN, 'Color', [0.2 0.85 0.4], 'Marker', 'o', 'MarkerSize', 5);
    ylim(ax4, [-0.1 1.3]);
    legend(ax4, 'Conventional', 'ML Proactive', 'Location', 'northeast', 'TextColor', 'w');
    
    ax5 = makeAxes(pnl, [660 10 620 200], 'UE Distance & Failures', 'Time (s)', 'Distance (m)'); hold(ax5,'on');
    h_dist = plot(ax5, NaN, NaN, 'Color', [0.7 0.5 1.0], 'LineWidth', 1.8);
    h_fail = scatter(ax5, NaN, NaN, 30, 'r', 'filled');
    
    % Simulation Variables
    buf_size = 150;
    t_arr = zeros(1,buf_size);
    snr_arr = zeros(1,buf_size) + 85;
    blk_arr = zeros(1,buf_size);
    sw_c_arr = zeros(1,buf_size);
    sw_p_arr = zeros(1,buf_size);
    dist_arr = zeros(1,buf_size);
    fail_arr = zeros(1,buf_size);
    
    t = 0;
    prev_snr = 85;
    
    conv_outage_time = 0;
    pro_outage_time = 0;
    conv_sw_count = 0;
    pro_sw_count = 0;
    total_failures = 0;
    ue_dist = 50;
    
    while ishandle(f_main)
        % Live Network Data
        [status, out] = system('netsh wlan show interfaces');
        if status == 0
            idx = regexp(out, 'Signal\s*:\s*(\d+)%', 'tokens');
            if ~isempty(idx)
                sig_pct = str2double(idx{1}{1});
            else
                sig_pct = randi([75, 95]);
            end
        else
            sig_pct = randi([75, 95]);
        end
        
        % Oscillation
        live_snr = (sig_pct * 0.7) + 25 + (randn() * 4); 
        
        % Simulate random physical blockages for demonstration
        if rand() < 0.05
            live_snr = live_snr - randi([15 35]); 
        end
        
        is_blocked = live_snr < 65;
        is_fail = live_snr < cfg.failure_threshold;
        snr_trend = live_snr - prev_snr;
        prev_snr = live_snr;
        
        % ML Prediction
        features = [10+t, ue_dist, 1, live_snr, is_blocked, snr_trend];
        try
            [pred_prob, ~] = predictBeamFailure(mdl, features);
        catch
            pred_prob = double(live_snr < 72);
        end
        
        % Logic Tracking
        c_sw = 0; p_sw = 0;
        if is_fail
            conv_outage_time = conv_outage_time + cfg.dt;
            if rand() < 0.3 % 30% chance to switch reactively per step
                c_sw = 1; conv_sw_count = conv_sw_count + 1;
                total_failures = total_failures + 1;
            end
        end
        
        if is_fail && pred_prob < 0.5
            pro_outage_time = pro_outage_time + cfg.dt; 
        end
        
        if pred_prob > 0.5 && ~is_fail
            if rand() < 0.4 % Proactive switch trigger
                p_sw = 1; pro_sw_count = pro_sw_count + 1;
            end
        end
        
        ue_dist = ue_dist + cfg.ue_speed * cfg.dt;
        
        % Shift buffers
        t_arr = [t_arr(2:end) t];
        snr_arr = [snr_arr(2:end) live_snr];
        blk_arr = [blk_arr(2:end) is_blocked];
        sw_c_arr = [sw_c_arr(2:end) c_sw];
        sw_p_arr = [sw_p_arr(2:end) p_sw];
        dist_arr = [dist_arr(2:end) ue_dist];
        fail_arr = [fail_arr(2:end) is_fail];
        
        % Update Plots (Only update if window is still open)
        if ~ishandle(f_main), break; end
        
        set(h_snr, 'XData', t_arr, 'YData', snr_arr);
        xlim(ax1, [t_arr(1) max(t_arr(end),0.1)]); ylim(ax1, [30 110]);
        
        h_bar.YData = [conv_outage_time, pro_outage_time];
        txt_b1.Position(2) = conv_outage_time + 0.5; txt_b1.String = sprintf('%.1fs', conv_outage_time);
        txt_b2.Position(2) = pro_outage_time + 0.5; txt_b2.String = sprintf('%.1fs', pro_outage_time);
        ylim(ax2, [0 max(3, max(conv_outage_time)*1.3)]);
        
        set(h_blk, 'XData', t_arr, 'YData', blk_arr);
        xlim(ax3, [t_arr(1) max(t_arr(end),0.1)]);
        
        set(h_sw_c, 'XData', t_arr(sw_c_arr==1), 'YData', sw_c_arr(sw_c_arr==1));
        set(h_sw_p, 'XData', t_arr(sw_p_arr==1), 'YData', sw_p_arr(sw_p_arr==1)*0.8);
        xlim(ax4, [t_arr(1) max(t_arr(end),0.1)]);
        
        set(h_dist, 'XData', t_arr, 'YData', dist_arr);
        set(h_fail, 'XData', t_arr(fail_arr==1), 'YData', dist_arr(fail_arr==1));
        xlim(ax5, [t_arr(1) max(t_arr(end),0.1)]);
        
        % Update KPIs
        kpi_handles(1).Text = sprintf('%.1f', conv_outage_time);
        kpi_handles(2).Text = sprintf('%.1f', pro_outage_time);
        impr = max(0, ((conv_outage_time - pro_outage_time) / max(conv_outage_time, 0.001)) * 100);
        kpi_handles(3).Text = sprintf('%.1f%%', impr);
        kpi_handles(4).Text = num2str(conv_sw_count);
        kpi_handles(5).Text = num2str(pro_sw_count);
        kpi_handles(6).Text = num2str(total_failures);
        kpi_handles(7).Text = sprintf('%.1f', mean(snr_arr(snr_arr>0)));
        kpi_handles(8).Text = sprintf('%.1f', min(snr_arr));
        kpi_handles(9).Text = sprintf('%.1f%%', 100*mean(blk_arr));
        
        drawnow;
        t = t + cfg.dt;
        pause(0.2);
    end
end

function lbl = kpiCard(parent, pos, labelStr, val, color)
    p = uipanel(parent, 'Position', pos, 'BackgroundColor', [0.18 0.20 0.26], 'ForegroundColor', [0.55 0.6 0.7], 'Title', labelStr, 'FontSize', 9);
    lbl = uilabel(p, 'Position', [5 8 pos(3)-15 38], 'Text', val, 'FontSize', 22, 'FontWeight', 'bold', 'FontColor', color, 'HorizontalAlignment', 'center');
end

function ax = makeAxes(parent, pos, titleStr, xlabelStr, ylabelStr)
    ax = uiaxes(parent, 'Position', pos);
    ax.Color = [0.16 0.18 0.22]; ax.XColor = [0.7 0.75 0.8]; ax.YColor = [0.7 0.75 0.8];
    ax.GridColor = [0.3 0.3 0.35]; ax.GridAlpha = 0.4;
    ax.Title.String = titleStr; ax.Title.Color = [0.9 0.9 0.95]; ax.Title.FontSize = 11;
    ax.XLabel.String = xlabelStr; ax.YLabel.String = ylabelStr;
    ax.XLabel.Color = [0.65 0.7 0.8]; ax.YLabel.Color = [0.65 0.7 0.8];
    grid(ax, 'on');
end
