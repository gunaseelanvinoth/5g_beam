# Machine Learning-Based Beam Failure Prediction and Recovery in 5G mmWave Communication Systems

## Overview
This final-year ECE project simulates a 5G millimeter-wave communication environment to demonstrate how machine learning can predict impending beam failure and initiate proactive beam recovery, minimizing communication outages.

## Project Structure
- `main.m`: Main execution script.
- `config.m`: Central configuration file.
- `environment_check.m`: Checks MATLAB version and toolboxes.
- `simulation/`: Contains 5G communication simulation, mobility, and blockage models.
- `dataset/`: Automatic dataset generation and labeling for ML.
- `ml/`: Model training and beam failure prediction logic.
- `recovery/`: Conventional reactive recovery and ML-based proactive recovery algorithms.
- `visualization/` & `app/`: Dashboard and plotting scripts.

## How to Run
1. Open MATLAB.
2. Navigate to this project folder.
3. Run the main script:
   ```matlab
   main
   ```

## Requirements
- MATLAB (Tested on Windows)
- Recommended Toolboxes:
  - Statistics and Machine Learning Toolbox (for Decision Tree)
  - 5G Toolbox, Communications Toolbox (optional, custom mathematical fallbacks included)

## Architecture
The system monitors SNR and beam quality trends under varying blockage conditions. A machine learning model (Decision Tree) is trained on historical simulation data to predict failures before they occur. The proactive recovery system evaluates candidate beams and switches proactively, significantly reducing outage duration compared to the conventional reactive method.
