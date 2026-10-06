% main.m
% Master execution script for 5G Beam Failure Project

clc; clear; close all;

% Setup paths
addpath('app', 'simulation', 'dataset', 'ml', 'recovery', 'evaluation', 'visualization', 'reports', 'tests');

fprintf('================================================\n');
fprintf(' MACHINE LEARNING-BASED BEAM FAILURE PREDICTION \n');
fprintf('================================================\n');

% 1. Environment Check
status = environment_check();

% 2. Load Configuration
cfg = config();

% 3. Run Simulation to generate data
fprintf('\n[1/5] Running Network Simulation...\n');
[simData, history] = simulateCommunication(cfg);
fprintf('Simulation complete. %d steps simulated.\n', height(simData));

% 4. Generate Dataset
fprintf('\n[2/5] Generating ML Dataset...\n');
dataset = generateDataset(simData, cfg);
fprintf('Dataset generated and saved.\n');

% 5. Train ML Model (with full validation metrics)
fprintf('\n[3/5] Training and Validating ML Model...\n');
mdl = trainModel(dataset);
trainAndValidateModel(); % Full step-by-step training with metrics & charts
fprintf('Model training and validation complete.\n');

% 6. Run Recovery Scenarios
fprintf('\n[4/5] Evaluating Recovery Algorithms...\n');
[conv_log, conv_outage, conv_switches] = conventionalRecovery(simData, cfg);
[pro_log, pro_outage, pro_switches] = proactiveRecovery(simData, cfg, mdl);

fprintf('--- Results ---\n');
fprintf('Conventional Outage: %.2f s | Switches: %d\n', conv_outage, conv_switches);
fprintf('Proactive Outage:    %.2f s | Switches: %d\n', pro_outage, pro_switches);

% 7. Visualize and Dashboard
fprintf('\n[5/5] Generating Visualizations and Reports...\n');
plotPerformanceComparison(simData, conv_log, pro_log);
plotBeamNetwork(simData, cfg);
evaluateModel(mdl, dataset);
fprintf('Saved performance comparison, network map, and ML confusion matrix figures.\n');

generateProjectReport(simData, conv_log, pro_log);
generateArchitectureDiagram();

% Launch LIVE Dashboard (all charts update in real-time)
fprintf('Opening Full Live Dashboard...\n');
launchFullLiveDashboard(mdl, cfg);
fprintf('Live Dashboard launched.\n');

fprintf('\n=== Project Execution Complete ===\n');
