% recovery/proactiveRecovery.m
function [recovery_log, outage_duration, num_switches] = proactiveRecovery(simData, cfg, mdl)
    fprintf('Running ML-Based Proactive Recovery...\n');
    
    num_steps = height(simData);
    outage_duration = 0;
    num_switches = 0;
    current_beam = simData.serving_beam(1);
    
    recovery_log = table(zeros(num_steps,1), zeros(num_steps,1), zeros(num_steps,1), ...
        'VariableNames', {'is_outage', 'switched', 'pred_prob'});
        
    for t = 1:num_steps
        snr = simData.snr_vals(t);
        
        % Feature vector for current step
        if t == 1
            snr_trend = 0;
        else
            snr_trend = (simData.snr_vals(t) - simData.snr_vals(t-1)) / cfg.dt;
        end
        current_state = [simData.ue_x(t), simData.ue_y(t), current_beam, snr, simData.blockage_state(t), snr_trend];
        
        % Predict
        if isstruct(mdl)
             [pred_prob, pred_class] = predictBeamFailure(mdl, current_state);
        else
            % using standard predict function inside predictBeamFailure
            [pred_prob, pred_class] = predictBeamFailure(mdl, current_state);
        end
        recovery_log.pred_prob(t) = pred_prob;
        
        % Proactive Switch
        if pred_prob >= cfg.ml_threshold
            % Switch before failure
            current_beam = randi(cfg.num_beams);
            num_switches = num_switches + 1;
            recovery_log.switched(t) = 1;
        end
        
        % Check if we still hit an outage despite proactive switching
        if snr < cfg.failure_threshold
            recovery_log.is_outage(t) = 1;
            outage_duration = outage_duration + cfg.dt;
        end
    end
end
