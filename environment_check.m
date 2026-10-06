% environment_check.m
% Validates MATLAB version and required toolboxes for the 5G Beam Failure Project.

function status = environment_check()
    fprintf('=== 5G Beam Failure Project Environment Check ===\n');
    
    % OS and MATLAB Version
    fprintf('OS: %s\n', computer);
    fprintf('MATLAB Version: %s\n', version);
    fprintf('Current Directory: %s\n', pwd);
    
    % Check Toolboxes
    toolboxes = {'5G Toolbox', 'Communications Toolbox', 'Phased Array System Toolbox', ...
                 'Statistics and Machine Learning Toolbox', 'Deep Learning Toolbox'};
    
    v = ver;
    installed_toolboxes = {v.Name};
    
    status = true;
    for i = 1:length(toolboxes)
        if ismember(toolboxes{i}, installed_toolboxes)
            fprintf('[PASS] %s is installed.\n', toolboxes{i});
        else
            fprintf('[WARN] %s is missing. Fallbacks will be used if possible.\n', toolboxes{i});
        end
    end
    
    fprintf('================================================\n');
end
