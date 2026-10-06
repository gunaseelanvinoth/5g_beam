% config.m
% Central configuration for the 5G Beam Failure Project.

function cfg = config()
    % Simulation Parameters
    cfg.fc = 28e9; % Carrier frequency (28 GHz mmWave)
    cfg.bandwidth = 100e6; % 100 MHz bandwidth
    cfg.num_beams = 5; 
    cfg.beam_angles = [-30, -15, 0, 15, 30]; % Angles in degrees
    
    cfg.tx_power = 0; % Reduced tx power to make environment more realistic for failures
    cfg.noise_power = -90; % dBm
    
    % Mobility Parameters
    cfg.ue_speed = 10; % m/s (faster to cause beam misalignment quicker)
    cfg.ue_start_pos = [10, 50]; % (x,y) in meters
    cfg.sim_duration = 100; % seconds
    cfg.dt = 0.1; % sampling interval
    
    % Environment / Blockage
    cfg.blockage_prob = 0.15; % Increased probability of blockage
    cfg.blockage_attenuation = 40; % Higher attenuation when blocked (e.g., building)
    
    % ML / Prediction Parameters
    cfg.prediction_horizon = 2; % seconds
    cfg.ml_threshold = 0.5; % probability threshold for proactive switch
    cfg.failure_threshold = 60; % Increased threshold so failures actually trigger
    
    % Execution Controls
    cfg.seed = 42; 
    cfg.recovery_mode = 'both'; % 'conventional', 'proactive', 'both'
end
