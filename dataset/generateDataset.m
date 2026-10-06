% dataset/generateDataset.m
function dataset = generateDataset(simData, cfg)
    % Add future failure label (prediction horizon)
    steps_ahead = round(cfg.prediction_horizon / cfg.dt);
    num_steps = height(simData);
    
    future_failure = zeros(num_steps, 1);
    
    for i = 1:num_steps-steps_ahead
        % If there's a failure in the horizon, label as 1
        if any(simData.is_failure(i+1 : i+steps_ahead))
            future_failure(i) = 1;
        end
    end
    
    % Add trend features (derivative of SNR)
    snr_trend = [0; diff(simData.snr_vals)] / cfg.dt;
    
    % Construct Dataset Table
    dataset = simData;
    dataset.snr_trend = snr_trend;
    dataset.future_failure = future_failure;
    
    % Save to disk
    save('results/datasets/ml_dataset.mat', 'dataset');
    writetable(dataset, 'results/datasets/ml_dataset.csv');
end
