% mobilityModel.m
function pos = mobilityModel(t, cfg)
    % Linear movement
    v = 15; % m/s
    pos = [50 + v*t, 20, 1.5];
end
