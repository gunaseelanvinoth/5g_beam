% tests/runAllTests.m
function runAllTests()
    fprintf('=== Running Automated Tests ===\n');
    
    % Test 1: Config Load
    try
        cfg = config();
        assert(isstruct(cfg), 'Config should return a struct');
        fprintf('[PASS] Configuration loaded successfully.\n');
    catch e
        fprintf('[FAIL] Configuration test failed: %s\n', e.message);
    end
    
    % Test 2: Simulation basic logic
    try
        cfg.sim_duration = 5; % Short run
        [simData, ~] = simulateCommunication(cfg);
        assert(height(simData) > 0, 'Simulation data should not be empty');
        fprintf('[PASS] Simulation executed successfully.\n');
    catch e
        fprintf('[FAIL] Simulation test failed: %s\n', e.message);
    end
    
    % Test 3: Dataset generation
    try
        dataset = generateDataset(simData, cfg);
        assert(any(strcmp(dataset.Properties.VariableNames, 'future_failure')), 'Dataset missing label');
        fprintf('[PASS] Dataset generation successful.\n');
    catch e
        fprintf('[FAIL] Dataset generation test failed: %s\n', e.message);
    end
    
    fprintf('=== All tests complete ===\n');
end
