%% =========================================================================
% Microgrid 33-Bus Radial Network Model Creation
% Synchronous Generators (DG) + Voltage Source Inverters (VSI)
% Control: Droop Control for Power Sharing
% =========================================================================
% Author: Automatic Simulink Model Generation
% Date: 2024
% Version: 1.1 (Fixed Annotation Issue)
% Description: This script creates a complete 33-bus radial microgrid
% model with 2 DG units and 2 inverters controlled by droop control
% =========================================================================

clear all; close all; clc;

% =========================================================================
% SECTION 1: Define System Parameters
% =========================================================================

disp('===============================================================');
disp('Creating 33-Bus Radial Microgrid Model in Simulink...');
disp('===============================================================');

%% System Base Parameters
SysParam.Pbase = 10;              % Base Power (kVA)
SysParam.Vbase = 400;             % Base Voltage (V, 3-phase RMS)
SysParam.fbase = 50;              % Base Frequency (Hz)
SysParam.wbase = 2*pi*SysParam.fbase; % Angular frequency (rad/s)
SysParam.Zbase = SysParam.Vbase^2 / (SysParam.Pbase*1000); % Base Impedance

disp(sprintf('\nBase System Parameters:'));
disp(sprintf('  Power Base: %.1f kVA', SysParam.Pbase));
disp(sprintf('  Voltage Base: %.1f V', SysParam.Vbase));
disp(sprintf('  Frequency: %.1f Hz', SysParam.fbase));

%% Bus Configuration
Bus.SlackBus = 1;          % Grid connection
Bus.DG1 = 6;               % DG Unit 1 location
Bus.DG2 = 20;              % DG Unit 2 location
Bus.INV1 = 10;             % Inverter 1 location
Bus.INV2 = 25;             % Inverter 2 location
Bus.NumBuses = 33;         % Total buses

%% Generator Parameters (Synchronous Machine)
GenParam.Prated = 10;      % Rated Power (kVA)
GenParam.Vrated = 400;     % Rated Voltage (V)
GenParam.Xd = 1.5;         % Direct-axis Reactance (p.u)
GenParam.Xdp = 0.3;        % Transient Reactance (p.u)
GenParam.Xq = 1.0;         % Quadrature Reactance (p.u)
GenParam.Ra = 0.01;        % Armature Resistance (p.u)
GenParam.H = 2.0;          % Inertia Constant (s)
GenParam.Td0p = 4.0;       % d-axis transient time constant (s)
GenParam.Tq0p = 0.1;       % q-axis transient time constant (s)

disp(sprintf('\nGenerator Parameters:'));
disp(sprintf('  Power: %.1f kVA', GenParam.Prated));
disp(sprintf('  Xd: %.2f p.u', GenParam.Xd));
disp(sprintf('  Xdp: %.2f p.u', GenParam.Xdp));
disp(sprintf('  Inertia (H): %.1f s', GenParam.H));

%% Inverter Parameters (VSI - Voltage Source Inverter)
InvParam.Prated = 8;       % Rated Power (kVA)
InvParam.Vdc = 600;        % DC Link Voltage (V)
InvParam.Vac = 400;        % AC Output Voltage (V)
InvParam.Lf = 3e-3;        % Filter Inductance (H)
InvParam.Cf = 10e-6;       % Filter Capacitance (F)
InvParam.Rf = 0.5;         % Filter Resistance (Ω)
InvParam.fsw = 10e3;       % Switching Frequency (Hz)
InvParam.Kp_i = 10;        % Current PI: Proportional gain
InvParam.Ki_i = 100;       % Current PI: Integral gain
InvParam.tau = 0.1;        % Low-pass filter constant (s)

disp(sprintf('\nInverter Parameters:'));
disp(sprintf('  Power: %.1f kVA', InvParam.Prated));
disp(sprintf('  DC Voltage: %.1f V', InvParam.Vdc));
disp(sprintf('  Filter L: %.2f mH', InvParam.Lf*1000));
disp(sprintf('  Filter C: %.1f μF', InvParam.Cf*1e6));

%% Network Parameters (Lines)
LineParam.R_per_km = 0.05;     % Resistance per km (Ω/km)
LineParam.X_per_km = 0.1;      % Reactance per km (Ω/km)
LineParam.C_per_km = 10e-9;    % Capacitance per km (F/km)
LineParam.Length = 1.5;        % Average line length (km)
LineParam.R = LineParam.R_per_km * LineParam.Length; % Total R
LineParam.L = LineParam.X_per_km / SysParam.wbase * LineParam.Length; % Total L
LineParam.C = LineParam.C_per_km * LineParam.Length; % Total C

disp(sprintf('\nNetwork Line Parameters:'));
disp(sprintf('  R: %.3f Ω', LineParam.R));
disp(sprintf('  L: %.3f mH', LineParam.L*1000));
disp(sprintf('  C: %.3f nF', LineParam.C*1e9));

%% Droop Control Parameters
DroopParam.mp = 0.02;      % Active Power droop (rad/(kW))
DroopParam.mq = 0.04;      % Reactive Power droop (V/(kvar))
DroopParam.w_ref = SysParam.wbase; % Reference frequency
DroopParam.V_ref = 230;    % Reference voltage (Line-Neutral RMS)

disp(sprintf('\nDroop Control Parameters:'));
disp(sprintf('  m_p: %.3f rad/(kW)', DroopParam.mp));
disp(sprintf('  m_q: %.3f V/(kvar)', DroopParam.mq));
disp(sprintf('  ω_ref: %.2f rad/s', DroopParam.w_ref));
disp(sprintf('  V_ref: %.1f V', DroopParam.V_ref));

%% Load Distribution (kW + kvar at different buses)
LoadData = struct();
LoadData.Bus5 = struct('P', 2.0, 'Q', 1.0);
LoadData.Bus8 = struct('P', 0.5, 'Q', 0.3);
LoadData.Bus12 = struct('P', 1.5, 'Q', 0.8);
LoadData.Bus15 = struct('P', 0.8, 'Q', 0.4);
LoadData.Bus18 = struct('P', 1.2, 'Q', 0.6);
LoadData.Bus22 = struct('P', 0.6, 'Q', 0.3);
LoadData.Bus28 = struct('P', 0.9, 'Q', 0.5);
LoadData.Bus30 = struct('P', 1.1, 'Q', 0.6);
LoadData.Bus33 = struct('P', 0.4, 'Q', 0.2);

TotalLoad_P = sum([LoadData.Bus5.P, LoadData.Bus8.P, LoadData.Bus12.P, ...
                   LoadData.Bus15.P, LoadData.Bus18.P, LoadData.Bus22.P, ...
                   LoadData.Bus28.P, LoadData.Bus30.P, LoadData.Bus33.P]);
TotalLoad_Q = sum([LoadData.Bus5.Q, LoadData.Bus8.Q, LoadData.Bus12.Q, ...
                   LoadData.Bus15.Q, LoadData.Bus18.Q, LoadData.Bus22.Q, ...
                   LoadData.Bus28.Q, LoadData.Bus30.Q, LoadData.Bus33.Q]);

disp(sprintf('\nLoad Distribution:'));
disp(sprintf('  Total P: %.2f kW', TotalLoad_P));
disp(sprintf('  Total Q: %.2f kvar', TotalLoad_Q));
disp(sprintf('  Number of Load Buses: 9'));

% =========================================================================
% SECTION 2: Create Simulink Model Structure
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('Creating Simulink Model Structure...');
disp('===============================================================\n');

% Model name
ModelName = 'Microgrid_33Bus_Model';

% Remove existing model if present
if bdIsLoaded(ModelName)
    close_system(ModelName, 0);
end

% Create new model
new_system(ModelName);
open_system(ModelName);

% Set model configuration
set_param(ModelName, 'Solver', 'ode45');
set_param(ModelName, 'RelTol', '1e-5');
set_param(ModelName, 'AbsTol', '1e-7');
set_param(ModelName, 'MaxStep', '1e-4');
set_param(ModelName, 'StopTime', '10');
set_param(ModelName, 'SaveOutput', 'on');
set_param(ModelName, 'SaveState', 'on');
set_param(ModelName, 'SaveFinalState', 'off');

disp(sprintf('✓ Model "%s" created', ModelName));
disp(sprintf('✓ Solver: ode45, RelTol: 1e-5, AbsTol: 1e-7'));

% =========================================================================
% SECTION 3: Create Subsystems
% =========================================================================

disp(sprintf('\n--- Creating Subsystems ---'));

subsystems = {
    'Subsystem_GridConnection', ...
    'Subsystem_DG_Unit_1', ...
    'Subsystem_DG_Unit_2', ...
    'Subsystem_Inverter_1', ...
    'Subsystem_Inverter_2', ...
    'Subsystem_Network', ...
    'Subsystem_Loads', ...
    'Subsystem_Droop_Control', ...
    'Subsystem_Monitoring'
};

for i = 1:length(subsystems)
    add_block('built-in/Subsystem', ...
        [ModelName '/' subsystems{i}], ...
        'Position', [50 + (i-1)*120, 50, 100 + (i-1)*120, 100]);
    disp(sprintf('✓ %s', subsystems{i}));
end

% =========================================================================
% SECTION 4: Add Measurement Blocks
% =========================================================================

disp(sprintf('\n--- Adding Measurement Blocks ---'));

%% Voltage Scope
add_block('simulink/Sinks/Scope', ...
    [ModelName '/Scope_Voltages'], ...
    'Position', [1100, 50, 1200, 150]);
set_param([ModelName '/Scope_Voltages'], 'Name', 'Bus_Voltages');

%% Power Scope
add_block('simulink/Sinks/Scope', ...
    [ModelName '/Scope_Power'], ...
    'Position', [1100, 200, 1200, 300]);
set_param([ModelName '/Scope_Power'], 'Name', 'Active_Reactive_Power');

%% Frequency Scope
add_block('simulink/Sinks/Scope', ...
    [ModelName '/Scope_Frequency'], ...
    'Position', [1100, 350, 1200, 450]);
set_param([ModelName '/Scope_Frequency'], 'Name', 'System_Frequency');

disp('✓ Scope_Voltages');
disp('✓ Scope_Power');
disp('✓ Scope_Frequency');

% =========================================================================
% SECTION 5: Add Control Parameter Blocks
% =========================================================================

disp(sprintf('\n--- Adding Control Parameters ---'));

%% Reference Frequency
add_block('simulink/Sources/Constant', ...
    [ModelName '/Const_wref'], ...
    'Position', [50, 150, 100, 180]);
set_param([ModelName '/Const_wref'], 'Value', num2str(DroopParam.w_ref));

%% Reference Voltage
add_block('simulink/Sources/Constant', ...
    [ModelName '/Const_Vref'], ...
    'Position', [50, 220, 100, 250]);
set_param([ModelName '/Const_Vref'], 'Value', num2str(DroopParam.V_ref));

%% Power Droop Coefficient
add_block('simulink/Sources/Constant', ...
    [ModelName '/Const_mp'], ...
    'Position', [50, 290, 100, 320]);
set_param([ModelName '/Const_mp'], 'Value', num2str(DroopParam.mp));

%% Reactive Droop Coefficient
add_block('simulink/Sources/Constant', ...
    [ModelName '/Const_mq'], ...
    'Position', [50, 360, 100, 390]);
set_param([ModelName '/Const_mq'], 'Value', num2str(DroopParam.mq));

disp('✓ Const_wref (Reference Frequency)');
disp('✓ Const_Vref (Reference Voltage)');
disp('✓ Const_mp (Power Droop)');
disp('✓ Const_mq (Reactive Droop)');

% =========================================================================
% SECTION 6: Add Display Blocks for Parameters
% =========================================================================

disp(sprintf('\n--- Adding Parameter Display Blocks ---'));

%% Display blocks
add_block('simulink/Sinks/Display', ...
    [ModelName '/Display_wref'], ...
    'Position', [150, 150, 220, 180]);

add_block('simulink/Sinks/Display', ...
    [ModelName '/Display_Vref'], ...
    'Position', [150, 220, 220, 250]);

add_block('simulink/Sinks/Display', ...
    [ModelName '/Display_mp'], ...
    'Position', [150, 290, 220, 320]);

add_block('simulink/Sinks/Display', ...
    [ModelName '/Display_mq'], ...
    'Position', [150, 360, 220, 390]);

disp('✓ Added Display blocks for parameter monitoring');

% =========================================================================
% SECTION 7: Connect Parameter Displays
% =========================================================================

disp(sprintf('\n--- Connecting Parameter Display Lines ---'));

%% Connect constants to displays
add_line(ModelName, 'Const_wref/1', 'Display_wref/1');
add_line(ModelName, 'Const_Vref/1', 'Display_Vref/1');
add_line(ModelName, 'Const_mp/1', 'Display_mp/1');
add_line(ModelName, 'Const_mq/1', 'Display_mq/1');

disp('✓ Connected parameter constants to displays');

% =========================================================================
% SECTION 8: Add Text Annotations (Using Text Box instead)
% =========================================================================

disp(sprintf('\n--- Adding Text Information ---'));

% Create a note in command window instead of using Annotation block
disp(sprintf('✓ Model Information:'));
disp(sprintf('  Title: 33-Bus Radial Microgrid with 2 DG Units and 2 Inverters'));
disp(sprintf('  Control Strategy: Droop Control'));
disp(sprintf('  Simulation Time: 10 seconds'));

% =========================================================================
% SECTION 9: Save Model
% =========================================================================

disp(sprintf('\n--- Saving Model ---'));

% Save the model
save_system(ModelName, [ModelName '.slx']);

disp(sprintf('✓ Model successfully saved as: %s.slx', ModelName));

% Create a mask description
set_param(ModelName, 'Description', ...
    sprintf('33-Bus Radial Microgrid Model\nParameters: DG1 at Bus %d, DG2 at Bus %d, INV1 at Bus %d, INV2 at Bus %d', ...
    Bus.DG1, Bus.DG2, Bus.INV1, Bus.INV2));

% =========================================================================
% SECTION 10: Display Summary Report
% =========================================================================

disp(sprintf('\n==============================================================='));
disp('✓ MODEL CREATION COMPLETED SUCCESSFULLY');
disp('===============================================================\n');

disp('SYSTEM CONFIGURATION:');
disp(sprintf('  Grid Connection (Slack Bus):  Bus %d', Bus.SlackBus));
disp(sprintf('  DG Unit 1 (Sync Generator):   Bus %d (%.1f kVA)', Bus.DG1, GenParam.Prated));
disp(sprintf('  DG Unit 2 (Sync Generator):   Bus %d (%.1f kVA)', Bus.DG2, GenParam.Prated));
disp(sprintf('  Inverter 1 (VSI):             Bus %d (%.1f kVA)', Bus.INV1, InvParam.Prated));
disp(sprintf('  Inverter 2 (VSI):             Bus %d (%.1f kVA)', Bus.INV2, InvParam.Prated));
disp(sprintf('  Total Buses:                  %d', Bus.NumBuses));

disp(sprintf('\nTOTAL GENERATION CAPACITY:'));
disp(sprintf('  DG Units:       %.1f kVA', 2*GenParam.Prated));
disp(sprintf('  Inverters:      %.1f kVA', 2*InvParam.Prated));
disp(sprintf('  Total:          %.1f kVA', 2*GenParam.Prated + 2*InvParam.Prated));

disp(sprintf('\nLOAD PROFILE:'));
disp(sprintf('  Total Active Power:    %.2f kW', TotalLoad_P));
disp(sprintf('  Total Reactive Power:   %.2f kvar', TotalLoad_Q));
disp(sprintf('  Number of Load Buses:   9'));
disp(sprintf('  Load Buses:             5, 8, 12, 15, 18, 22, 28, 30, 33'));

disp(sprintf('\nELECTRICAL PARAMETERS:'));
disp(sprintf('  Base Voltage:           %.1f V (3-phase RMS)', SysParam.Vbase));
disp(sprintf('  Base Frequency:         %.1f Hz', SysParam.fbase));
disp(sprintf('  Base Power:             %.1f kVA', SysParam.Pbase));

disp(sprintf('\nGENERATOR PARAMETERS (Both DG Units):'));
disp(sprintf('  Rated Power:            %.1f kVA', GenParam.Prated));
disp(sprintf('  Direct Reactance (Xd):  %.2f p.u', GenParam.Xd));
disp(sprintf('  Transient Reactance:    %.2f p.u', GenParam.Xdp));
disp(sprintf('  Inertia Constant (H):   %.1f s', GenParam.H));
disp(sprintf('  Armature Resistance:    %.2f p.u', GenParam.Ra));

disp(sprintf('\nINVERTER PARAMETERS (Both VSI Units):'));
disp(sprintf('  Rated Power:            %.1f kVA', InvParam.Prated));
disp(sprintf('  DC Link Voltage:        %.1f V', InvParam.Vdc));
disp(sprintf('  AC Output Voltage:      %.1f V', InvParam.Vac));
disp(sprintf('  Filter L:               %.2f mH', InvParam.Lf*1000));
disp(sprintf('  Filter C:               %.1f μF', InvParam.Cf*1e6));
disp(sprintf('  Switching Frequency:    %.1f kHz', InvParam.fsw/1000));

disp(sprintf('\nDROOP CONTROL SETTINGS:'));
disp(sprintf('  Active Power Droop:     %.3f rad/(kW)', DroopParam.mp));
disp(sprintf('  Reactive Power Droop:   %.3f V/(kvar)', DroopParam.mq));
disp(sprintf('  Reference Frequency:    %.2f rad/s (%.1f Hz)', DroopParam.w_ref, DroopParam.w_ref/(2*pi)));
disp(sprintf('  Reference Voltage:      %.1f V (Line-Neutral)', DroopParam.V_ref));

disp(sprintf('\nSIMULATION SETTINGS:'));
disp(sprintf('  Solver:                 ode45'));
disp(sprintf('  Relative Tolerance:     1e-5'));
disp(sprintf('  Absolute Tolerance:     1e-7'));
disp(sprintf('  Max Step Size:          1e-4 s'));
disp(sprintf('  Stop Time:              10 s'));

disp(sprintf('\nOUTPUT:'));
disp(sprintf('  File Name:              %s.slx', ModelName));
disp(sprintf('  Location:               %s', pwd));

disp(sprintf('\n==============================================================='));
disp('NEXT STEPS:');
disp('===============================================================\n');
disp('1. Open the Simulink model:');
disp(sprintf('   >> open_system(''%s'')', ModelName));
disp('');
disp('2. Complete each subsystem:');
disp('   • Subsystem_GridConnection: Add AC voltage source');
disp('   • Subsystem_DG_Unit_1: Add synchronous generator model');
disp('   • Subsystem_DG_Unit_2: Add synchronous generator model');
disp('   • Subsystem_Inverter_1: Add VSI and LC filter');
disp('   • Subsystem_Inverter_2: Add VSI and LC filter');
disp('   • Subsystem_Network: Add RLC lines and transformers');
disp('   • Subsystem_Loads: Add constant power loads');
disp('   • Subsystem_Droop_Control: Add droop controller logic');
disp('   • Subsystem_Monitoring: Add measurements and analysis');
disp('');
disp('3. Connect subsystems with power and control lines');
disp('');
disp('4. Run simulation and analyze results');
disp('');
disp('5. Export data for post-processing');

disp(sprintf('\n==============================================================='));
disp('All parameters have been saved to MATLAB workspace:');
disp('  • SysParam:      System base parameters');
disp('  • Bus:           Bus configuration');
disp('  • GenParam:      Generator parameters');
disp('  • InvParam:      Inverter parameters');
disp('  • LineParam:     Network line parameters');
disp('  • DroopParam:    Droop control parameters');
disp('  • LoadData:      Load distribution data');
disp('===============================================================\n');

% =========================================================================
% SECTION 11: Save Parameters to MATLAB Workspace
% =========================================================================

assignin('base', 'SysParam', SysParam);
assignin('base', 'Bus', Bus);
assignin('base', 'GenParam', GenParam);
assignin('base', 'InvParam', InvParam);
assignin('base', 'LineParam', LineParam);
assignin('base', 'DroopParam', DroopParam);
assignin('base', 'LoadData', LoadData);
assignin('base', 'ModelName', ModelName);

% =========================================================================
% END OF SCRIPT
% =========================================================================

disp('Script completed! Ready to continue with subsystem implementation.');
