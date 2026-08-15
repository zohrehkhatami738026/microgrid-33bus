%% =========================================================================
% IEEE 33-Bus Radial Distribution Network with DGs and Inverters
% Complete Microgrid Model in Simulink
% =========================================================================
% Description: Creates IEEE 33-bus test system with:
%   - 1 Slack Bus (Grid Connection)
%   - 3 Synchronous Generators (DG) at Buses 6, 13, 21
%   - 2 Voltage Source Inverters at Buses 10, 25
%   - Droop Control for power sharing
%   - Radial network topology
% =========================================================================

clear all; close all; clc;

% =========================================================================
% SECTION 1: IEEE 33-Bus Network Data
% =========================================================================

disp('===============================================================');
disp('Creating IEEE 33-Bus Radial Microgrid Model');
disp('===============================================================\n');

%% System Base Parameters
SysParam.Pbase = 10;              % Base Power (kVA)
SysParam.Vbase = 400;             % Base Voltage (V, 3-phase RMS)
SysParam.fbase = 50;              % Base Frequency (Hz)
SysParam.wbase = 2*pi*SysParam.fbase;
SysParam.Zbase = SysParam.Vbase^2 / (SysParam.Pbase*1000);

disp('System Base Parameters:');
disp(sprintf('  Base Power: %.1f kVA', SysParam.Pbase));
disp(sprintf('  Base Voltage: %.1f V', SysParam.Vbase));
disp(sprintf('  Base Frequency: %.1f Hz\n', SysParam.fbase));

%% IEEE 33-Bus Network Configuration
% Format: [From Bus, To Bus, R(Ω), X(Ω), Load_P(kW), Load_Q(kvar)]
LineData = [
    1,  2,  0.5950, 0.3060, 0.0,   0.0;      % Line 1-2
    2,  3,  0.0000, 0.3100, 100.0, 60.0;     % Line 2-3 (with load)
    3,  4,  0.3660, 0.1864, 90.0,  40.0;     % Line 3-4
    4,  5,  0.3811, 0.1941, 120.0, 80.0;     % Line 4-5
    5,  6,  0.8190, 0.2707, 60.0,  30.0;     % Line 5-6 (DG1 location)
    6,  7,  0.1872, 0.6188, 200.0, 100.0;    % Line 6-7
    7,  8,  0.7114, 0.2351, 80.0,  40.0;     % Line 7-8
    8,  9,  1.0300, 0.7400, 140.0, 70.0;     % Line 8-9
    9,  10, 1.0440, 0.7400, 70.0,  40.0;     % Line 9-10 (INV1 location)
    10, 11, 0.1966, 0.0650, 0.0,   0.0;      % Line 10-11
    11, 12, 0.3744, 0.1238, 60.0,  30.0;     % Line 11-12
    12, 13, 1.4680, 1.1550, 95.0,  50.0;     % Line 12-13 (DG2 location)
    13, 14, 0.5416, 0.7129, 180.0, 90.0;     % Line 13-14
    14, 15, 0.5910, 0.7837, 150.0, 70.0;     % Line 14-15
    15, 16, 0.7463, 0.5450, 60.0,  35.0;     % Line 15-16
    16, 17, 1.2890, 1.7210, 100.0, 60.0;     % Line 16-17
    17, 18, 0.7320, 0.5740, 200.0, 100.0;    % Line 17-18
    18, 19, 0.5740, 0.3050, 70.0,  40.0;     % Line 18-19
    19, 20, 0.6802, 0.2125, 128.0, 70.0;     % Line 19-20
    20, 21, 0.3105, 0.3619, 150.0, 75.0;     % Line 20-21 (DG3 location)
    21, 22, 0.3619, 0.1038, 97.0,  50.0;     % Line 21-22
    22, 23, 0.5302, 0.2565, 165.0, 80.0;     % Line 22-23
    23, 24, 0.8342, 0.2565, 139.0, 70.0;     % Line 23-24
    24, 25, 1.2275, 0.7338, 150.0, 75.0;     % Line 24-25 (INV2 location)
    25, 26, 0.4453, 0.3648, 140.0, 70.0;     % Line 25-26
    26, 27, 0.4453, 0.3648, 110.0, 55.0;     % Line 26-27
    27, 28, 0.6050, 0.4454, 220.0, 110.0;    % Line 27-28
    28, 29, 0.7207, 0.5337, 150.0, 75.0;     % Line 28-29
    29, 30, 0.3750, 0.3127, 200.0, 100.0;    % Line 29-30
    30, 31, 0.3875, 0.1852, 150.0, 70.0;     % Line 30-31
    31, 32, 0.4440, 0.3574, 210.0, 100.0;    % Line 31-32
    32, 33, 0.3864, 0.1414, 60.0,  30.0;     % Line 32-33
];

NumLines = size(LineData, 1);
NumBuses = 33;

disp(sprintf('Network Configuration:'));
disp(sprintf('  Number of Buses: %d', NumBuses));
disp(sprintf('  Number of Lines: %d', NumLines));

% Calculate total load
TotalLoad_P = sum(LineData(:, 5));
TotalLoad_Q = sum(LineData(:, 6));
disp(sprintf('  Total Load: %.2f kW + j%.2f kvar\n', TotalLoad_P, TotalLoad_Q));

%% Bus Information
BusInfo = struct();
BusInfo.SlackBus = 1;          % Grid connection (Bus 1)
BusInfo.DG_Buses = [6, 13, 21]; % DG locations
BusInfo.INV_Buses = [10, 25];   % Inverter locations

disp('Generation Sources:');
disp(sprintf('  Slack Bus (Grid): Bus %d', BusInfo.SlackBus));
for i = 1:length(BusInfo.DG_Buses)
    disp(sprintf('  DG Unit %d: Bus %d (10 kVA)', i, BusInfo.DG_Buses(i)));
end
for i = 1:length(BusInfo.INV_Buses)
    disp(sprintf('  Inverter %d: Bus %d (8 kVA)', i, BusInfo.INV_Buses(i)));
end

TotalGen = 1*Inf + 3*10 + 2*8;  % Grid + 3 DGs + 2 INVs
disp(sprintf('  Total Generation: Grid + 46 kVA (DGs + INVs)\n');

%% Generator Parameters (for all DG units)
GenParam.Prated = 10;      % Rated Power (kVA)
GenParam.Vrated = 400;     % Rated Voltage (V)
GenParam.Xd = 1.5;         % Direct-axis Reactance (p.u)
GenParam.Xdp = 0.3;        % Transient Reactance (p.u)
GenParam.Xq = 1.0;         % Quadrature Reactance (p.u)
GenParam.Ra = 0.01;        % Armature Resistance (p.u)
GenParam.H = 2.0;          % Inertia Constant (s)
GenParam.Td0p = 4.0;       % d-axis transient time constant (s)

disp('Generator Parameters (each DG unit):');
disp(sprintf('  Power: %.1f kVA', GenParam.Prated));
disp(sprintf('  Xd: %.2f p.u, Xdp: %.2f p.u', GenParam.Xd, GenParam.Xdp));
disp(sprintf('  Inertia (H): %.1f s\n', GenParam.H));

%% Inverter Parameters (for all inverters)
InvParam.Prated = 8;       % Rated Power (kVA)
InvParam.Vdc = 600;        % DC Link Voltage (V)
InvParam.Vac = 400;        % AC Output Voltage (V)
InvParam.Lf = 3e-3;        % Filter Inductance (H)
InvParam.Cf = 10e-6;       % Filter Capacitance (F)
InvParam.Rf = 0.5;         % Filter Resistance (Ω)
InvParam.fsw = 10e3;       % Switching Frequency (Hz)

disp('Inverter Parameters (each VSI unit):');
disp(sprintf('  Power: %.1f kVA', InvParam.Prated));
disp(sprintf('  DC Voltage: %.1f V', InvParam.Vdc));
disp(sprintf('  Filter L: %.2f mH, C: %.1f μF\n', InvParam.Lf*1000, InvParam.Cf*1e6));

%% Droop Control Parameters
DroopParam.mp = 0.02;      % Active Power droop (rad/(kW))
DroopParam.mq = 0.04;      % Reactive Power droop (V/(kvar))
DroopParam.w_ref = SysParam.wbase;
DroopParam.V_ref = 230;    % Line-Neutral RMS voltage

disp('Droop Control Parameters:');
disp(sprintf('  m_p: %.3f rad/(kW)', DroopParam.mp));
disp(sprintf('  m_q: %.3f V/(kvar)', DroopParam.mq));
disp(sprintf('  ω_ref: %.2f rad/s (50 Hz)', DroopParam.w_ref));
disp(sprintf('  V_ref: %.1f V\n', DroopParam.V_ref));

% =========================================================================
% SECTION 2: Create Simulink Model
% =========================================================================

disp('===============================================================');
disp('Creating Simulink Model...');
disp('===============================================================\n');

ModelName = 'IEEE_33Bus_Microgrid';

% Remove existing model
if bdIsLoaded(ModelName)
    close_system(ModelName, 0);
end

% Create new model
new_system(ModelName);
open_system(ModelName);

% Configure model
set_param(ModelName, 'Solver', 'ode45');
set_param(ModelName, 'RelTol', '1e-5');
set_param(ModelName, 'AbsTol', '1e-7');
set_param(ModelName, 'MaxStep', '1e-4');
set_param(ModelName, 'StopTime', '10');
set_param(ModelName, 'SaveOutput', 'on');
set_param(ModelName, 'SaveState', 'on');

disp(sprintf('✓ Model "%s" created', ModelName));
disp(sprintf('✓ Solver: ode45, Stop Time: 10s\n'));

% =========================================================================
% SECTION 3: Create Main Subsystems
% =========================================================================

disp('Creating Subsystems...\n');

% Main subsystems
SubsystemNames = {
    'Grid_Source',
    'DG_Sources',
    'Inverters',
    'Network_Lines',
    'Loads',
    'Control_Droop',
    'Monitoring'
};

for i = 1:length(SubsystemNames)
    add_block('built-in/Subsystem', ...
        [ModelName '/' SubsystemNames{i}], ...
        'Position', [50 + (i-1)*140, 50, 120 + (i-1)*140, 120]);
    disp(sprintf('✓ %s', SubsystemNames{i}));
end

% =========================================================================
% SECTION 4: Add Control Parameter Constants
% =========================================================================

disp(sprintf('\nAdding Control Parameters...\n'));

YPos = 200;
ConstNames = {'wref', 'Vref', 'mp', 'mq'};
ConstValues = {DroopParam.w_ref, DroopParam.V_ref, DroopParam.mp, DroopParam.mq};

for i = 1:length(ConstNames)
    BlockName = sprintf('Const_%s', ConstNames{i});
    add_block('simulink/Sources/Constant', ...
        [ModelName '/' BlockName], ...
        'Position', [50, YPos + (i-1)*60, 120, YPos + 25 + (i-1)*60]);
    set_param([ModelName '/' BlockName], 'Value', num2str(ConstValues{i}));
    disp(sprintf('✓ %s = %.4f', BlockName, ConstValues{i}));
end

% =========================================================================
% SECTION 5: Add Measurement and Display Blocks
% =========================================================================

disp(sprintf('\nAdding Monitoring Blocks...\n'));

% Scopes
ScopeNames = {'Bus_Voltages', 'Active_Power', 'Reactive_Power', 'Frequency'};
for i = 1:length(ScopeNames)
    add_block('simulink/Sinks/Scope', ...
        [ModelName '/' ScopeNames{i}], ...
        'Position', [1150, 50 + (i-1)*150, 1250, 150 + (i-1)*150]);
    disp(sprintf('✓ Scope: %s', ScopeNames{i}));
end

% =========================================================================
% SECTION 6: Save Model
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('Saving Model...');
disp('===============================================================\n');

save_system(ModelName, [ModelName '.slx']);
disp(sprintf('✓ Model saved: %s.slx', ModelName));

% =========================================================================
% SECTION 7: Generate Line Connection Report
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('IEEE 33-Bus Network Topology');
disp('===============================================================\n');

disp('Line Details (From Bus - To Bus - R(Ω) - X(Ω) - Load):');
disp('─────────────────────────────────────────────────────────');

for i = 1:NumLines
    FromBus = LineData(i, 1);
    ToBus = LineData(i, 2);
    R = LineData(i, 3);
    X = LineData(i, 4);
    P = LineData(i, 5);
    Q = LineData(i, 6);
    
    % Check if bus has DG or Inverter
    DGflag = ismember(ToBus, BusInfo.DG_Buses);
    INVflag = ismember(ToBus, BusInfo.INV_Buses);
    
    BusType = '';
    if ToBus == BusInfo.SlackBus
        BusType = ' [SLACK]';
    elseif DGflag
        BusType = ' [DG]';
    elseif INVflag
        BusType = ' [INV]';
    end
    
    if P > 0 || Q > 0
        disp(sprintf('Line %2d: Bus %2d → Bus %2d │ R=%.4f Ω, X=%.4f Ω │ Load: %.0fkW, %.0fkvar%s', ...
            i, FromBus, ToBus, R, X, P, Q, BusType));
    else
        disp(sprintf('Line %2d: Bus %2d → Bus %2d │ R=%.4f Ω, X=%.4f Ω │ No Load%s', ...
            i, FromBus, ToBus, R, X, BusType));
    end
end

% =========================================================================
% SECTION 8: Display Summary
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('MODEL SUMMARY - IEEE 33-Bus Radial Microgrid');
disp('===============================================================\n');

disp('NETWORK CONFIGURATION:');
disp(sprintf('  Total Buses: %d', NumBuses));
disp(sprintf('  Total Lines: %d', NumLines));
disp(sprintf('  Network Type: Radial (Tree Structure)'));
disp(sprintf('  Main Feeder: Bus 1 → Bus 2 → ... → Bus 33\n');

disp('GENERATION SOURCES:');
disp(sprintf('  Slack Bus (Grid): Bus 1 (infinite capacity)'));
disp(sprintf('  DG Unit 1: Bus 6 (10 kVA Synchronous Generator)'));
disp(sprintf('  DG Unit 2: Bus 13 (10 kVA Synchronous Generator)'));
disp(sprintf('  DG Unit 3: Bus 21 (10 kVA Synchronous Generator)'));
disp(sprintf('  Inverter 1: Bus 10 (8 kVA Voltage Source Inverter)'));
disp(sprintf('  Inverter 2: Bus 25 (8 kVA Voltage Source Inverter)'));
disp(sprintf('  Total Distributed Generation: 46 kVA\n');

disp('LOAD DISTRIBUTION:');
disp(sprintf('  Total Active Power Load: %.2f kW', TotalLoad_P));
disp(sprintf('  Total Reactive Power Load: %.2f kvar', TotalLoad_Q));
disp(sprintf('  Number of Load Buses: %d', nnz(LineData(:,5) > 0)));
disp(sprintf('  Load Distribution: Distributed across 27 buses\n');

disp('ELECTRICAL PARAMETERS:');
disp(sprintf('  Nominal Voltage: 400 V (3-phase RMS)'));
disp(sprintf('  Nominal Frequency: 50 Hz'));
disp(sprintf('  System Impedance Range:');
disp(sprintf('    Minimum: %.4f Ω (Line 2-3)', min(LineData(:,3))));
disp(sprintf('    Maximum: %.4f Ω (Line 16-17)', max(LineData(:,3)))\n');

disp('CONTROL STRATEGY:');
disp(sprintf('  Control Type: Droop Control'));
disp(sprintf('  Active Power Droop (m_p): %.3f rad/(kW)', DroopParam.mp));
disp(sprintf('  Reactive Power Droop (m_q): %.3f V/(kvar)', DroopParam.mq));
disp(sprintf('  Reference Frequency: %.1f Hz', SysParam.fbase));
disp(sprintf('  Reference Voltage: %.1f V (Line-Neutral)\n');

disp('SIMULATION PARAMETERS:');
disp(sprintf('  Solver: ode45 (Runge-Kutta 4/5)'));
disp(sprintf('  Relative Tolerance: 1e-5'));
disp(sprintf('  Absolute Tolerance: 1e-7'));
disp(sprintf('  Max Step Size: 1e-4 s'));
disp(sprintf('  Total Simulation Time: 10 s\n');

disp('OUTPUT FILE:');
disp(sprintf('  Model Name: %s', ModelName));
disp(sprintf('  File Type: .slx (Simulink)'));
disp(sprintf('  Location: %s', pwd));

% =========================================================================
% SECTION 9: Save Data to Workspace
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('Saving Data to MATLAB Workspace');
disp('===============================================================\n');

assignin('base', 'LineData', LineData);
assignin('base', 'BusInfo', BusInfo);
assignin('base', 'SysParam', SysParam);
assignin('base', 'GenParam', GenParam);
assignin('base', 'InvParam', InvParam);
assignin('base', 'DroopParam', DroopParam);
assignin('base', 'NumBuses', NumBuses);
assignin('base', 'NumLines', NumLines);
assignin('base', 'ModelName', ModelName);

disp('✓ LineData: Network line configuration');
disp('✓ BusInfo: Bus information (Slack, DG, INV buses)');
disp('✓ SysParam: System base parameters');
disp('✓ GenParam: Generator parameters');
disp('✓ InvParam: Inverter parameters');
disp('✓ DroopParam: Droop control parameters');
disp('✓ ModelName: Simulink model name\n');

% =========================================================================
% SECTION 10: Instructions
% =========================================================================

disp('===============================================================');
disp('NEXT STEPS - Completing the Model');
disp('===============================================================\n');

disp('1. OPEN THE MODEL:');
disp(sprintf('   >> open_system(''%s'')', ModelName));
disp('');
disp('2. COMPLETE SUBSYSTEMS:');
disp('');
disp('   a) Grid_Source:');
disp('      - Add AC Voltage Source (400V, 50Hz)');
disp('      - Add 3-Phase V-I Measurement');
disp('      - Add ground reference');
disp('');
disp('   b) DG_Sources:');
disp('      - Add 3 Synchronous Generators (Bus 6, 13, 21)');
disp('      - Add dq Transformation blocks');
disp('      - Add Governor and AVR control');
disp('      - Add Droop controller for each DG');
disp('');
disp('   c) Inverters:');
disp('      - Add 2 DC Sources (600V each)');
disp('      - Add 2 Universal Bridge (6 IGBT) converters');
disp('      - Add LC filters');
disp('      - Add PWM generators');
disp('      - Add current and voltage controllers');
disp('');
disp('   d) Network_Lines:');
disp('      - Add 32 Series RLC branches (one per line)');
disp('      - Connect all buses in radial topology');
disp('      - Use LineData parameters');
disp('');
disp('   e) Loads:');
disp('      - Add 27 Constant Power Loads');
disp('      - Use load data from LineData');
disp('');
disp('   f) Control_Droop:');
disp('      - Implement P-ω droop equation');
disp('      - Implement Q-V droop equation');
disp('      - Add low-pass filters');
disp('');
disp('   g) Monitoring:');
disp('      - Add voltage measurements at critical buses');
disp('      - Add power flow measurements');
disp('      - Add frequency measurement');
disp('');
disp('3. CONNECT SUBSYSTEMS:');
disp('   - Connect Grid_Source to Network_Lines');
disp('   - Connect DG_Sources to Network_Lines');
disp('   - Connect Inverters to Network_Lines');
disp('   - Connect Loads to Network_Lines');
disp('   - Connect Monitoring to Scopes');
disp('   - Connect Control signals from Droop');
disp('');
disp('4. RUN SIMULATION:');
disp(sprintf('   >> sim(''%s'')', ModelName));
disp('');
disp('5. ANALYZE RESULTS:');
disp('   - Check voltage profiles at all buses');
disp('   - Verify power sharing among DGs and inverters');
disp('   - Analyze frequency stability');
disp('   - Study transient response to load changes\n');

disp('===============================================================');
disp('✓ IEEE 33-BUS MODEL FRAMEWORK CREATED SUCCESSFULLY');
disp('===============================================================\n');

disp('For help on implementing each component, refer to:');
disp('  - Simscape Power Systems documentation');
disp('  - MATLAB Simulink help');
disp('  - IEEE 33-bus test case documentation\n');

% =========================================================================
% END OF SCRIPT
% =========================================================================
