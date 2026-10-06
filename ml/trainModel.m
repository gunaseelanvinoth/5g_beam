% ml/trainModel.m
function mdl = trainModel(dataset)
    % Prepare training data
    % Use only data up to where we can look ahead
    valid_idx = find(~isnan(dataset.future_failure) & dataset.time < max(dataset.time)-2);
    trainData = dataset(valid_idx, :);
    
    % Features: ue_x, ue_y, serving_beam, snr_vals, blockage_state, snr_trend
    X = [trainData.ue_x, trainData.ue_y, trainData.serving_beam, trainData.snr_vals, trainData.blockage_state, trainData.snr_trend];
    Y = trainData.future_failure;
    
    % Train Decision Tree
    % Check if Statistics and Machine Learning Toolbox is available
    if ~isempty(ver('stats'))
        mdl = fitctree(X, Y, 'MinLeafSize', 10);
        fprintf('[ML] Trained Decision Tree successfully.\n');
    else
        fprintf('[WARN] Statistics Toolbox missing. Using a simple threshold-based heuristic as fallback.\n');
        mdl = struct('type', 'heuristic', 'threshold', 5); % Dummy model
    end
    
    save('results/models/failure_predictor.mat', 'mdl');
end
