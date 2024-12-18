clear; % Clear the workspace

%% Plant

% Create 's' for transfer function representation
s = tf('s');

% Define the system transfer function
G = 30/(s^2 + 0.5*s - 5);

%% Controller

% Define a controller transfer function (2 zeros / 2 poles)
C0 = tunableTF('C', 2, 2);

% Fix the structure of the denominator to have integral effect:
% Den(s) = s^2 + ds
C0.Denominator.Value = [1 1 0];
C0.Denominator.Free = [0 1 0];

%% Feedback loop

% Define analysis points for output and control input
AP_y = AnalysisPoint('AP_y');
AP_u = AnalysisPoint('AP_u');

% Create the open-loop system with the controller and analysis points
CL0 = feedback(G*AP_u*C0, AP_y);

% Define input and output names for the system
CL0.InputName = 'rf'; % Filtered reference input
CL0.OutputName = 'y'; % System output

% Reference signal filter
tau0 = tunableGain('tau', 1, 1);
F0 = tau0/(s + tau0);

% Connect F0 and CL0
F0.InputName = 'r';
F0.OutputName = 'rf';
CLF0 = connect(CL0, F0, 'r', 'y');

%% Tuning

% Define frequency response data for tracking error
err = frd([0.001 1 1],[0 5 10]);
% Define tuning goal for tracking error
Rtrack = TuningGoal.Tracking('r','y',err);

% Plot the tracking goal
figure;
viewGoal(Rtrack);
title('Tracking Error as a function of frequency');

% Define tuning gain goal for disturbance rejection
Rreject = TuningGoal.Gain('AP_u','y',frd([0.001 0.05 0.05], [0 1 100]));

% Plot the disturbance rejection goal
figure;
viewGoal(Rreject);
title('Disturbance Rejection: Maximum gain as a function of frequency');

% Define tuning gain goal for control input
Rcontrolinput = TuningGoal.Gain('r','AP_u', 50);

% Plot the control input goal
figure;
viewGoal(Rcontrolinput);
title('Reference to Control Input: Maximum gain as a function of frequency');

% Soft requirements for tuning
SoftReqs = [Rtrack, Rreject, Rcontrolinput];

% Define tuning goal for stability margins
Rmarg = TuningGoal.Margins('AP_y', 20, 60);

% Plot the stability margins goal
figure;
viewGoal(Rmarg);
title('Disk-based stability margins');

% Hard requirements for tuning
HardReqs = [Rmarg];

% Perform tuning
[CLF,fSoft] = systune(CLF0, SoftReqs, HardReqs);

%% Verification

% Plot the step response of the closed-loop system
figure;
[t, y] = step(CLF,5);
plot(y, t, 'LineWidth', 2);
xlabel('Time (s)');
grid on;
title('Step response from reference to output');

% Plot the tracking goal vs achieved
figure;
viewGoal(Rtrack,CLF);
title('Tracking Error as a function of frequency');

% Plot the disturbance rejection goal vs achieved
figure;
viewGoal(Rreject,CLF);
title('Disturbance Rejection: Maximum gain as a function of frequency');

% Plot the control input goal vs achieved
figure;
viewGoal(Rcontrolinput,CLF);
title('Reference to Control Input: Maximum gain as a function of frequency');

% Plot the stability margins goal vs achieved
figure;
viewGoal(Rmarg,CLF);
title('Disk-based stability margins');

% Plot the step response from disturbance to output
figure;
[t, y] = step(getIOTransfer(CLF,'AP_u','y'),20);
plot(y, t, 'LineWidth', 2);
xlabel('Time (s)');
grid on;
title('Step response from disturbance to output');

% Plot the step response from reference to control input
figure;
[t, y] = step(getIOTransfer(CLF,'r','AP_u'),10);
plot(y, t, 'LineWidth', 2);
xlabel('Time (s)');
grid on;
title('Step response from reference to control input');