% ml/trainAndValidateModel.m
% =========================================================
% HOW TO TRAIN THE ML MODEL - Complete Step-by-Step Script
% =========================================================
% Run this script independently in MATLAB to:
%   1. Simulate the 5G environment
%   2. Generate labeled training data
%   3. Train a Decision Tree model
%   4. Validate with metrics (Accuracy, Precision, Recall, F1)
%   5. Plot Confusion Matrix and Feature Importance
%   6. Save the trained model

function trainAndValidateModel()
    clc;
    fprintf('============================================\n');
    fprintf('   ML MODEL TRAINING - Step by Step\n');
    fprintf('============================================\n\n');

    % Add all project paths (resolve from project root)
    projectRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(projectRoot, 'simulation'), fullfile(projectRoot, 'dataset'), ...
            fullfile(projectRoot, 'ml'), fullfile(projectRoot, 'recovery'), ...
            fullfile(projectRoot, 'visualization'), fullfile(projectRoot, 'reports'));

    % -------------------------------------------------
    % STEP 1: Load Configuration
    % -------------------------------------------------
    fprintf('[STEP 1] Loading configuration...\n');
    cfg = config();
    fprintf('  - Carrier Frequency: %.0f GHz\n', cfg.fc / 1e9);
    fprintf('  - Simulation Duration: %d seconds\n', cfg.sim_duration);
    fprintf('  - UE Speed: %.0f m/s\n', cfg.ue_speed);
    fprintf('  - Prediction Horizon: %.1f s\n', cfg.prediction_horizon);
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 2: Run 5G Communication Simulation
    % -------------------------------------------------
    fprintf('[STEP 2] Running 5G mmWave simulation to collect data...\n');
    [simData, ~] = simulateCommunication(cfg);
    fprintf('  - Total time steps simulated: %d\n', height(simData));
    fprintf('  - Total blockage events: %d\n', sum(simData.blockage_state));
    fprintf('  - Total actual failures: %d\n', sum(simData.is_failure));
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 3: Generate Labeled Dataset
    % -------------------------------------------------
    fprintf('[STEP 3] Generating labeled dataset...\n');
    dataset = generateDataset(simData, cfg);
    
    total_samples = height(dataset);
    failure_labels = sum(dataset.future_failure);
    normal_labels = total_samples - failure_labels;
    
    fprintf('  - Total samples      : %d\n', total_samples);
    fprintf('  - Class 0 (Normal)   : %d (%.1f%%)\n', normal_labels, 100*normal_labels/total_samples);
    fprintf('  - Class 1 (Failure)  : %d (%.1f%%)\n', failure_labels, 100*failure_labels/total_samples);
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 4: Split Dataset (70% Train, 15% Val, 15% Test)
    % -------------------------------------------------
    fprintf('[STEP 4] Splitting dataset into Train / Val / Test...\n');
    valid_idx = find(~isnan(dataset.future_failure) & ...
                      dataset.time < max(dataset.time) - cfg.prediction_horizon);
    data_valid = dataset(valid_idx, :);
    N = height(data_valid);
    
    rng(cfg.seed);
    idx = randperm(N);
    train_end = round(0.70 * N);
    val_end   = round(0.85 * N);
    
    train_idx = idx(1:train_end);
    val_idx   = idx(train_end+1:val_end);
    test_idx  = idx(val_end+1:end);
    
    trainSet = data_valid(train_idx, :);
    valSet   = data_valid(val_idx, :);
    testSet  = data_valid(test_idx, :);
    
    fprintf('  - Training samples   : %d\n', height(trainSet));
    fprintf('  - Validation samples : %d\n', height(valSet));
    fprintf('  - Test samples       : %d\n', height(testSet));
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 5: Prepare Feature Matrix X and Label Vector Y
    % -------------------------------------------------
    fprintf('[STEP 5] Preparing feature matrix...\n');
    feature_names = {'ue_x', 'ue_y', 'serving_beam', 'snr_vals', 'blockage_state', 'snr_trend'};
    
    getX = @(d) [d.ue_x, d.ue_y, d.serving_beam, d.snr_vals, d.blockage_state, d.snr_trend];
    X_train = getX(trainSet); Y_train = trainSet.future_failure;
    X_val   = getX(valSet);   Y_val   = valSet.future_failure;
    X_test  = getX(testSet);  Y_test  = testSet.future_failure;
    
    fprintf('  Features used: %s\n', strjoin(feature_names, ', '));
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 6: Train the ML Model
    % -------------------------------------------------
    fprintf('[STEP 6] Training ML Model...\n');
    
    has_stats_toolbox = ~isempty(ver('stats'));
    
    if has_stats_toolbox
        fprintf('  [INFO] Statistics & ML Toolbox detected. Training Decision Tree...\n');
        mdl = fitctree(X_train, Y_train, ...
            'MinLeafSize', 10, ...
            'MaxNumSplits', 20, ...
            'ClassNames', [0; 1]);
        fprintf('  [INFO] Decision Tree trained successfully.\n');
    else
        fprintf('  [WARN] Statistics & ML Toolbox NOT found.\n');
        fprintf('         Using threshold-based heuristic model (fallback).\n');
        % Determine best SNR threshold from training data
        best_thresh = findBestThreshold(X_train, Y_train);
        mdl = struct('type', 'heuristic', 'threshold', best_thresh);
        fprintf('  [INFO] Heuristic model threshold = %.2f dB SNR\n', best_thresh);
    end
    
    % Save the model
    save('results/models/failure_predictor.mat', 'mdl');
    fprintf('  Model saved to results/models/failure_predictor.mat\n');
    fprintf('  Done.\n\n');

    % -------------------------------------------------
    % STEP 7: Evaluate on Test Set
    % -------------------------------------------------
    fprintf('[STEP 7] Evaluating model on test set...\n');
    
    Y_pred = zeros(size(Y_test));
    for i = 1:length(Y_test)
        [~, pred_class] = predictBeamFailure(mdl, X_test(i,:));
        Y_pred(i) = double(pred_class);
    end
    
    % Compute metrics manually (no toolbox needed)
    TP = sum((Y_test == 1) & (Y_pred == 1));
    TN = sum((Y_test == 0) & (Y_pred == 0));
    FP = sum((Y_test == 0) & (Y_pred == 1));
    FN = sum((Y_test == 1) & (Y_pred == 0));
    
    accuracy  = (TP + TN) / (TP + TN + FP + FN);
    precision = TP / max(TP + FP, 1);
    recall    = TP / max(TP + FN, 1);
    f1        = 2 * (precision * recall) / max(precision + recall, 1e-6);
    
    fprintf('  +-----------------------+----------+\n');
    fprintf('  | Metric                |  Value   |\n');
    fprintf('  +-----------------------+----------+\n');
    fprintf('  | Accuracy              |  %.4f  |\n', accuracy);
    fprintf('  | Precision             |  %.4f  |\n', precision);
    fprintf('  | Recall                |  %.4f  |\n', recall);
    fprintf('  | F1-Score              |  %.4f  |\n', f1);
    fprintf('  | True Positives (TP)   |  %-6d  |\n', TP);
    fprintf('  | True Negatives (TN)   |  %-6d  |\n', TN);
    fprintf('  | False Positives (FP)  |  %-6d  |\n', FP);
    fprintf('  | False Negatives (FN)  |  %-6d  |\n', FN);
    fprintf('  +-----------------------+----------+\n\n');

    % -------------------------------------------------
    % STEP 8: Plot Confusion Matrix
    % -------------------------------------------------
    fprintf('[STEP 8] Plotting Confusion Matrix...\n');
    C = [TN, FP; FN, TP];
    
    fig1 = figure('Name', 'ML Confusion Matrix', 'Color', 'w', 'Position', [100 100 500 420]);
    imagesc(C);
    colormap(flipud(bone));
    colorbar;
    
    labels = {'Normal (0)', 'Impending Failure (1)'};
    for r = 1:2
        for c = 1:2
            text(c, r, num2str(C(r,c)), ...
                'HorizontalAlignment', 'center', 'FontSize', 18, ...
                'FontWeight', 'bold', 'Color', ifelse(C(r,c)>max(C(:))/2, 'w', 'k'));
        end
    end
    xticks([1 2]); yticks([1 2]);
    xticklabels({'Predicted: Normal', 'Predicted: Failure'});
    yticklabels({'Actual: Normal', 'Actual: Failure'});
    title(sprintf('Confusion Matrix  |  Accuracy=%.2f  F1=%.2f', accuracy, f1));
    saveas(fig1, 'results/figures/Confusion_Matrix.png');
    fprintf('  Saved: results/figures/Confusion_Matrix.png\n\n');

    % -------------------------------------------------
    % STEP 9: Feature Importance Bar Chart
    % -------------------------------------------------
    fprintf('[STEP 9] Plotting Feature Importance...\n');
    if has_stats_toolbox
        importances = predictorImportance(mdl);
    else
        % Proxy: correlation of each feature with label
        importances = zeros(1, length(feature_names));
        for fi = 1:length(feature_names)
            r = corrcoef(X_train(:,fi), Y_train);
            importances(fi) = abs(r(1,2));
        end
    end
    
    fig2 = figure('Name', 'Feature Importance', 'Color', 'w', 'Position', [620 100 600 400]);
    bar(importances, 'FaceColor', [0.2 0.6 0.9]);
    xticks(1:length(feature_names));
    xticklabels(feature_names);
    xtickangle(30);
    ylabel('Importance Score');
    title('Feature Importance for Beam Failure Prediction');
    grid on;
    saveas(fig2, 'results/figures/Feature_Importance.png');
    fprintf('  Saved: results/figures/Feature_Importance.png\n\n');

    % -------------------------------------------------
    % STEP 10: SNR vs Failure Probability Plot
    % -------------------------------------------------
    fprintf('[STEP 10] Plotting SNR vs Failure Probability...\n');
    snr_range = linspace(min(X_test(:,4)), max(X_test(:,4)), 200);
    fail_prob = zeros(size(snr_range));
    
    for k = 1:length(snr_range)
        sample_state = [mean(X_test(:,1)), mean(X_test(:,2)), 3, snr_range(k), 0, 0];
        [prob, ~] = predictBeamFailure(mdl, sample_state);
        fail_prob(k) = prob;
    end
    
    fig3 = figure('Name', 'SNR vs Failure Probability', 'Color', 'w', 'Position', [100 540 600 380]);
    plot(snr_range, fail_prob, 'r-', 'LineWidth', 2);
    xlabel('SNR (dB)'); ylabel('Failure Probability');
    title('ML Model: SNR vs Predicted Failure Probability');
    xline(cfg.failure_threshold, 'k--', 'Failure Threshold');
    yline(cfg.ml_threshold, 'b--', 'ML Decision Threshold');
    grid on;
    legend('Failure Probability', 'Failure Threshold', 'ML Threshold');
    saveas(fig3, 'results/figures/SNR_vs_FailureProb.png');
    fprintf('  Saved: results/figures/SNR_vs_FailureProb.png\n\n');

    fprintf('============================================\n');
    fprintf('  MODEL TRAINING COMPLETE\n');
    fprintf('  Figures saved in: results/figures/\n');
    fprintf('  Model saved in  : results/models/\n');
    fprintf('============================================\n');
end

% ------- Helper Functions -------

function best_thresh = findBestThreshold(X, Y)
    snr_col = X(:, 4);
    thresholds = linspace(min(snr_col), max(snr_col), 50);
    best_f1 = -1; best_thresh = thresholds(1);
    for t = thresholds
        pred = double(snr_col < t);
        TP = sum((Y==1) & (pred==1));
        FP = sum((Y==0) & (pred==1));
        FN = sum((Y==1) & (pred==0));
        p = TP / max(TP+FP, 1);
        r = TP / max(TP+FN, 1);
        f1 = 2*p*r / max(p+r, 1e-6);
        if f1 > best_f1
            best_f1 = f1; best_thresh = t;
        end
    end
end

function result = ifelse(cond, a, b)
    if cond, result = a; else, result = b; end
end
