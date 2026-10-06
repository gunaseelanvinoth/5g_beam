% Main entry point for Live Dashboard
clc;
disp('Starting 5G Beam Failure LIVE Monitoring...');
disp('Connecting to Laptop Network Interface...');
addpath('app','simulation','dataset','ml','recovery','visualization','reports');

% Try to load model, if not, train quickly
try
    loaded = load('results/models/failure_predictor.mat');
    mdl = loaded.mdl;
catch
    disp('Loading configurations...');
    cfg = config();
    disp('Training initial model for live predictions...');
    [simData, ~] = simulateCommunication(cfg);
    dataset = generateDataset(simData, cfg);
    mdl = trainModel(dataset);
end

disp('Launching Live Dashboard. Close the window to stop.');
launchLiveDashboard(mdl);
