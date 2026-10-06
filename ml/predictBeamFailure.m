% ml/predictBeamFailure.m
function [pred_prob, pred_class] = predictBeamFailure(mdl, current_state)
    % current_state is [ue_x, ue_y, serving_beam, snr_vals, blockage_state, snr_trend]
    
    if isstruct(mdl) && strcmp(mdl.type, 'heuristic')
        % Fallback heuristic
        pred_class = current_state(4) < mdl.threshold;
        pred_prob = double(pred_class);
    else
        % Decision tree prediction
        [pred_class, scores] = predict(mdl, current_state);
        pred_prob = scores(2); % Probability of class 1 (failure)
    end
end
