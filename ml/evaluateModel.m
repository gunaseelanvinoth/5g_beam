% ml/evaluateModel.m
function evaluateModel(mdl, dataset)
    % Extracts ground truth and makes predictions to plot a confusion matrix
    
    valid_idx = find(~isnan(dataset.future_failure));
    testData = dataset(valid_idx, :);
    
    Y_true = testData.future_failure;
    Y_pred = zeros(size(Y_true));
    
    for i = 1:height(testData)
        snr_trend = testData.snr_trend(i);
        state = [testData.ue_x(i), testData.ue_y(i), testData.serving_beam(i), ...
                 testData.snr_vals(i), testData.blockage_state(i), snr_trend];
             
        [~, pred_class] = predictBeamFailure(mdl, state);
        Y_pred(i) = double(pred_class);
    end
    
    % Manual confusion matrix calculation (Fallback for Base MATLAB without ML toolbox)
    TN = sum((Y_true == 0) & (Y_pred == 0));
    FP = sum((Y_true == 0) & (Y_pred == 1));
    FN = sum((Y_true == 1) & (Y_pred == 0));
    TP = sum((Y_true == 1) & (Y_pred == 1));
    C = [TN, FP; FN, TP];
    
    % Plot Confusion Matrix manually
    fig = figure('Name', 'ML Model Evaluation', 'Color', 'w');
    imagesc(C);
    colormap(flipud(bone)); % Better color aesthetics
    colorbar;
    
    % Add text annotations inside cells
    for i = 1:2
        for j = 1:2
            % Determine text color for contrast
            if C(i,j) > max(C(:))/2
                textColor = 'w';
            else
                textColor = 'k';
            end
            text(j, i, num2str(C(i,j)), 'HorizontalAlignment', 'center', ...
                'FontSize', 16, 'Color', textColor, 'FontWeight', 'bold');
        end
    end
    
    title('Beam Failure Prediction Confusion Matrix');
    xticks([1 2]); yticks([1 2]);
    xticklabels({'Pred: Normal', 'Pred: Failure'});
    yticklabels({'Actual: Normal', 'Actual: Failure'});
    
    saveas(fig, 'results/figures/Confusion_Matrix.png');
end
