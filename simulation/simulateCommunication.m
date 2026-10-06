% simulation/simulateCommunication.m
function [simData, history] = simulateCommunication(cfg)
    rng(cfg.seed);
    
    num_steps = round(cfg.sim_duration / cfg.dt);
    
    % Data structures
    time = (0:num_steps-1)' * cfg.dt;
    ue_x = zeros(num_steps, 1);
    ue_y = zeros(num_steps, 1);
    serving_beam = zeros(num_steps, 1);
    snr_vals = zeros(num_steps, 1);
    blockage_state = zeros(num_steps, 1); % 0=clear, 1=blocked
    is_failure = zeros(num_steps, 1);
    
    % Initial State
    ue_x(1) = cfg.ue_start_pos(1);
    ue_y(1) = cfg.ue_start_pos(2);
    current_beam = 3; % Start with central beam
    serving_beam(1) = current_beam;
    
    for t = 2:num_steps
        % Mobility Model (simple linear motion along x)
        ue_x(t) = ue_x(t-1) + cfg.ue_speed * cfg.dt;
        ue_y(t) = ue_y(t-1);
        
        % Blockage Model (Markov chain)
        if blockage_state(t-1) == 0
            if rand() < cfg.blockage_prob * cfg.dt
                blockage_state(t) = 1;
            else
                blockage_state(t) = 0;
            end
        else
            if rand() < 0.5 * cfg.dt % Recovery from blockage
                blockage_state(t) = 0;
            else
                blockage_state(t) = 1;
            end
        end
        
        % Channel & Beam Model
        angle_to_ue = atand(ue_y(t) / ue_x(t));
        if isnan(angle_to_ue), angle_to_ue = 0; end
        
        % Calculate gain for the current serving beam (simplified)
        beam_angle = cfg.beam_angles(current_beam);
        misalignment = abs(angle_to_ue - beam_angle);
        beam_gain = max(-30, 20 - 0.5 * misalignment^2); % Basic parabolic pattern
        
        % Path loss (simplified Friis)
        dist = sqrt(ue_x(t)^2 + ue_y(t)^2);
        path_loss = 20*log10(dist) + 20*log10(cfg.fc) + 20*log10(4*pi/3e8) - 120; 
        
        % SNR Calculation
        signal_power = cfg.tx_power + beam_gain - path_loss;
        if blockage_state(t) == 1
            signal_power = signal_power - cfg.blockage_attenuation;
        end
        
        snr_vals(t) = signal_power - cfg.noise_power;
        
        % Failure Condition
        if snr_vals(t) < cfg.failure_threshold
            is_failure(t) = 1;
        end
        
        serving_beam(t) = current_beam;
    end
    
    % Package Output
    simData = table(time, ue_x, ue_y, serving_beam, snr_vals, blockage_state, is_failure);
    history.num_steps = num_steps;
end
