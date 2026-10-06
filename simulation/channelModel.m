% channelModel.m
function [rsrp, snr] = channelModel(bsPos, uePos, beamAngle, blockage, cfg)
    dist = norm(bsPos - uePos);
    fspl = 20*log10(dist) + 20*log10(cfg.fc) + 20*log10(4*pi/cfg.c) - 147.55;
    
    % Antenna gain (simplified Gaussian beam)
    theta = atand((uePos(2)-bsPos(2))/(uePos(1)-bsPos(1) + 1e-6));
    gain = 20 - min(12 * ((theta - beamAngle)/15)^2, 20);
    
    rxPower = cfg.txPower + gain - fspl - blockage;
    rsrp = rxPower;
    snr = rsrp - cfg.noisePower;
end
