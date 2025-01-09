# Systune - Performance vs Robustness Tuning

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=simorxb/systune-performance-robustness)

## Summary
This project demonstrates the tuning of control systems to balance performance and robustness using MATLAB's systune. The focus is on optimizing a linear feedback controller and a low-pass filter for an unstable system with specific performance and robustness requirements.

## Project Overview
Control systems often require a balance between high performance and robustness. This project explores the tuning of a control architecture for an unstable plant defined as:

$$
G(s) = \frac{30}{s^2 + 0.5s - 5}
$$

### Control Architecture
The chosen control system consists of:
1. A **linear feedback controller** with:
   - 2 poles, 2 zeros
   - Integral effect
   - 4 tunable parameters

$$C(s) = \frac{as^2 + bs + c}{s^2 + ds}$$

2. A **first-order low-pass filter** applied to the reference input with a tunable time constant:
   $$F(s) = \frac{\tau}{s + \tau}$$

### MATLAB Implementation
MATLAB's systune toolbox is used to optimize the tunable controller and filter parameters. Key commands include:
- `tunableTF`, `tunableGain`, `feedback`, and `connect`.

These enable creating a tunable system that meets defined performance and robustness requirements.

### Performance and Robustness Requirements
- **Hard Requirements**:
  - Disk-based margins of 20 dB gain and 60° phase (±20 dB and ±60° robustness to variations).
  - Implemented with:
    ```matlab
    Rmarg = TuningGoal.Margins('AP_y', 20, 60);
    ```

- **Soft Requirements**:
  - Tracking error minimization based on frequency:
    ```matlab
    Rtrack = TuningGoal.Tracking('r','y',err);
    ```
  - Control disturbance rejection:
    ```matlab
    Rreject = TuningGoal.Gain('AP_u','y',frd([0.001 0.05 0.05], [0 1 100]));
    ```
  - Limiting the gain from the reference signal to the control input:
    ```matlab
    Rcontrolinput = TuningGoal.Gain('r','AP_u', 50);
    ```

### Results
- Optimized controller and filter:
  
  $$C(s) = \frac{1.067e06 s^2 + 2.197e06 s + 6.333e05}{s^2 + 1.055e05 s}$$
  
  $$F(s) = \frac{5.029}{s + 5.029}$$

- Achievements:
  - Disk-based margins exceeded: 40 dB gain, 90° phase worst-case scenario.
  - Step response settling time < 1 second.
  - No overshoot in step response.
  - All soft requirements met.

## Author
This project is developed by Simone Bertoni. Learn more about my work on my personal website - [Simone Bertoni - Control Lab](https://simonebertonilab.com/).

## Contact
For further communication, connect with me on [LinkedIn](https://www.linkedin.com/in/simone-bertoni-control-eng/).
