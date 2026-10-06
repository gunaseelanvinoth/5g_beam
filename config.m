% config.m
% Central configuration for the 5G Beam Failure Project.

function cfg = config()
    rng('shuffle'); % Ensure absolute randomness every time config is called

    % Simulation Parameters
    cfg.fc = 28e9; % Carrier frequency (28 GHz mmWave)
    cfg.bandwidth = 100e6; % 100 MHz bandwidth
    cfg.num_beams = 5; 
    cfg.beam_angles = [-30, -15, 0, 15, 30]; % Angles in degrees
    
    cfg.tx_power = 0; 
    cfg.noise_power = -90; % dBm
    
    % Mobility Parameters - randomized so every run's charts are completely different!
    cfg.ue_speed = randi([5, 18]); 
    cfg.ue_start_pos = [randi([-30, 30]), randi([20, 60])]; 
    cfg.sim_duration = 100; % seconds
    cfg.dt = 0.1; % sampling interval
    
    % Environment / Blockage - randomized severity
    cfg.blockage_prob = 0.08 + rand() * 0.15; 
    cfg.blockage_attenuation = randi([30, 50]); 
    
    % ML / Prediction Parameters
    cfg.prediction_horizon = 2; % seconds
    cfg.ml_threshold = 0.5; % probability threshold for proactive switch
    cfg.failure_threshold = 60; % Increased threshold so failures actually trigger
    
    % Execution Controls
    % Random seed based on current time — every run gives DIFFERENT results
    cfg.seed = mod(sum(clock() * 1000), 2^31); 
    cfg.recovery_mode = 'both'; % 'conventional', 'proactive', 'both'
end
