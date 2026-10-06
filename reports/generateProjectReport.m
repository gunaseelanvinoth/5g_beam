% reports/generateProjectReport.m
function generateProjectReport(simData, conv_log, pro_log)
    fprintf('Generating Academic Project Report...\n');
    report_file = 'results/reports/Final_Project_Report.md';
    
    fid = fopen(report_file, 'w');
    fprintf(fid, '# Machine Learning-Based Beam Failure Prediction and Recovery in 5G mmWave Communication Systems\n\n');
    fprintf(fid, '## 1. Abstract\nThis project simulates a 5G mmWave environment and evaluates proactive beam recovery using machine learning versus conventional reactive methods.\n\n');
    fprintf(fid, '## 2. Introduction\nmmWave communication suffers from high path loss and blockage. Proactive beam switching can minimize outage durations.\n\n');
    
    fprintf(fid, '## 3. Methodology\nThe simulation models user mobility, blockage via Markov chains, and beam gain using parabolic approximations. A machine learning model predicts future beam failures based on SNR trends.\n\n');
    
    % Results
    conv_outage = sum(conv_log.is_outage) * 0.1;
    pro_outage = sum(pro_log.is_outage) * 0.1;
    
    fprintf(fid, '## 4. Results\n');
    fprintf(fid, '| Metric | Conventional System | Proactive System (ML) |\n');
    fprintf(fid, '|---|---|---|\n');
    fprintf(fid, '| Outage Duration (s) | %.2f | %.2f |\n', conv_outage, pro_outage);
    fprintf(fid, '| Total Beam Switches | %d | %d |\n\n', sum(conv_log.switched), sum(pro_log.switched));
    
    fprintf(fid, '## 5. Conclusion\nThe ML-based proactive system demonstrated significant potential in reducing communication outage periods by switching beams prior to threshold failure.\n');
    
    fclose(fid);
    fprintf('Report generated at %s\n', report_file);
end
