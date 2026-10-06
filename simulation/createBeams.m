% createBeams.m
function beams = createBeams(cfg)
    angles = linspace(-60, 60, cfg.numBeams);
    beams.angles = angles;
end
