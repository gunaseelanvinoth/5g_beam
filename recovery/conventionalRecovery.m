% recovery/conventionalRecovery.m
function [recovery_log, outage_duration, num_switches] = conventionalRecovery(simData, cfg)
    fprintf('Running Conventional Reactive Recovery...\n');
    
    num_steps = height(simData);
    outage_duration = 0;
    num_switches = 0;
    current_beam = simData.serving_beam(1);
    
    recovery_log = table(zeros(num_steps,1), zeros(num_steps,1), 'VariableNames', {'is_outage', 'switched'});
    
    for t = 1:num_steps
        snr = simData.snr_vals(t);
        
        % If SNR is below threshold, we have an outage and need to recover
        if snr < cfg.failure_threshold
            recovery_log.is_outage(t) = 1;
            outage_duration = outage_duration + cfg.dt;
            
            % Reactive Switch (Simplistic: pick best alternative randomly for simulation demo)
            % In reality, would measure other beams. Here we simulate switching delay.
            if rand() < 0.3 % 30% chance to recover per step (approx 0.3s)
                current_beam = randi(cfg.num_beams);
                num_switches = num_switches + 1;
                recovery_log.switched(t) = 1;
            end
        end
    end
end
