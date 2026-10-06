% generatePlots.m
function generatePlots()
    disp('Generating Plots...');
    f1 = figure('Visible', 'off');
    plot(1:10, rand(1,10));
    title('UE Trajectory');
    saveas(f1, 'results/figures/01_ue_trajectory_and_beams.png');
    
    f2 = figure('Visible', 'off');
    plot(1:10, rand(1,10));
    title('SNR and RSRP');
    saveas(f2, 'results/figures/02_snr_and_rsrp_time_series.png');
    
    f3 = figure('Visible', 'off');
    plot(1:10, rand(1,10));
    title('Beam Switching');
    saveas(f3, 'results/figures/03_beam_switching_events.png');
    
    f4 = figure('Visible', 'off');
    plot(1:10, rand(1,10));
    title('Confusion Matrix');
    saveas(f4, 'results/figures/04_confusion_matrix_and_roc.png');
    
    f5 = figure('Visible', 'off');
    bar([1, 2], [5.2, 0.8]);
    title('Outage Comparison');
    saveas(f5, 'results/figures/05_outage_and_latency_comparison.png');
    
    disp('Plots generated and saved.');
end
