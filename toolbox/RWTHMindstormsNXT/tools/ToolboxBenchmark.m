function ToolboxBenchmark()
% ToolboxBenchmark
% This function calls and times some basic toolbox functions,
% so it can be used to get a rough idea of the machine's speed or to
% compare different methods of communication (USB and Bluetooth)
%
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/10/07
%   Copyright: 2007-2010, RWTH Aachen University
%
%
% ***********************************************************************************************
% *  This file is part of the RWTH - Mindstorms NXT Toolbox.                                    *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is free software: you can redistribute it and/or modify  *
% *  it under the terms of the GNU General Public License as published by the Free Software     *
% *  Foundation, either version 3 of the License, or (at your option) any later version.        *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is distributed in the hope that it will be useful,       *
% *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *
% *  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.             *
% *                                                                                             *
% *  You should have received a copy of the GNU General Public License along with the           *
% *  RWTH - Mindstorms NXT Toolbox. If not, see <http://www.gnu.org/licenses/>.                 *
% ***********************************************************************************************



%% Clean up previous handles
COM_CloseNXT all

%% Set up Matlab
clear all % if you use clear all, call COM_CloseNXT all before, as we did!
close all
format compact

% get no of logical cpus present
import java.lang.*;
r=Runtime.getRuntime;
numCPUs= r.availableProcessors;


disp(' ')
disp('*** RWTH - Mindstorms NXT Toolbox Benchmark')
if ispc; OS = 'Windows'; else OS = 'Linux'; end
rwthver  = ver('RWTHMindstormsNXT');
disp(['    Toolbox version: ' rwthver.Version])
disp(['    MATLAB version:  ' version])
disp(['    Running on ' OS ' (' sprintf('%d',numCPUs) ' CPUs), ' datestr(now)])




%% Set up ports

portLight   = SENSOR_1;
portSound   = SENSOR_2;
portSwitch  = SENSOR_3;
portUS      = SENSOR_4;
portMotor   = MOTOR_A;
portMotor2  = MOTOR_B;
 
motor1 = NXTMotor(portMotor);
motor2 = NXTMotor(portMotor2);

%% Connect to NXT

h = COM_OpenNXTEx('Any', '', 'bluetooth.ini');
COM_SetDefaultNXT(h);

disp(['    Connection type is ' h.ConnectionTypeName])



fprintf('Preparing benchmark... ');

%% Close all sensors to be sure
for j = 0 : 3
    CloseSensor(j);
end%for

%% Open Sensors
OpenLight(portLight, 'active');
OpenSound(portSound, 'db');
OpenSwitch(portSwitch);
OpenUltrasonic(portUS);

%% Stop and reset all motors
StopMotor all off
for j = 0 : 2
    % reset both absolute and relative positions
    NXT_ResetMotorPosition(j, false);
    NXT_ResetMotorPosition(j, true);
end%for


%% Call test functions to load them into memory
TestLight;
TestSound;
TestSwitch;
TestUS;
TestMotorRead;

fprintf('done.\n')


%% Estimate speed for later test
fprintf('Estimating speed... ');

EstimatingTime = 4; % in sec
if h.ConnectionTypeValue == 2 % BT
    PacketsPerSec = 17; %hardcoded BT optimum
else
    PacketCounter = 0;
    tic
    while(toc < EstimatingTime)
        TestMotorRead;
        PacketCounter = PacketCounter + 1;
    end%while
    PacketsPerSec = PacketCounter / EstimatingTime;
end%if



fprintf(['done. (%.1f packets/sec)\n'], PacketsPerSec)



%% Actual benchmarking begins
TestingTime = 3; %in sec
TestingCalls = PacketsPerSec * TestingTime;


fprintf('Starting benchmark, testing time is ~%d sec per unit\n', TestingTime);


fprintf('- Testing BEEP... ');
DoBenchmark(@TestBeep, TestingCalls * 3);

fprintf('- Testing LIGHT... ');
DoBenchmark(@TestLight, TestingCalls);

fprintf('- Testing SOUND... ');
DoBenchmark(@TestSound, TestingCalls);
 
fprintf('- Testing SWITCH... ');
DoBenchmark(@TestSwitch, TestingCalls);

fprintf('- Testing ULTRASONIC... ');
if strcmpi(h.ConnectionTypeName, 'USB')
    % less calls for USB
    DoBenchmark(@TestUS, TestingCalls / 6);
else
    DoBenchmark(@TestUS, TestingCalls / 2);
end%if

% for motor read, we let the motor running...
DirectMotorCommand(portMotor, 20, 0, 'on', 'off', 0, 'off');
DirectMotorCommand(portMotor2, -20, 0, 'on', 'off', 0, 'off');

fprintf('- Testing MOTOR READ... ');
DoBenchmark(@TestMotorRead, TestingCalls);

StopMotor all off

fprintf('- Testing MOTOR WRITE... ');
DoBenchmark(@TestMotorWrite, TestingCalls);

StopMotor all off


%% Clean up
% Close all sensors
for j = 0 : 3
    CloseSensor(j);
end%for

COM_CloseNXT(h);






%% **** NESTED FUNCTIONS ****

    function DoBenchmark(func, times)
        
        startCPU = cputime;
        tic;
        for zzz = 1 : times % dont need index, avoid confusion with outer func
            func();
        end%for
        cpuTaken = cputime - startCPU;
        timeTaken = toc;

        timePerCall = timeTaken / times;
        callsPerSec = times / timeTaken;
        
        cpuLoad = cpuTaken / timeTaken;
        threadLoad = cpuLoad * numCPUs;
        
        
        fprintf('done.     (took %.1f secs)\n', toc);
        fprintf('  Calls/sec: %.2f\n', callsPerSec);
        fprintf('  Time/call: %.1f ms\n', timePerCall * 1000);
        fprintf('  CPU usage: %.0f%% (thread usage: %.0f%%)\n',cpuLoad * 100, threadLoad * 100)

    end%function

    function TestBeep()
        NXT_PlayTone(fix(rand * 800 + 300), 2);
    end%function

    function TestLight()
        dummy = GetLight(portLight);
    end%function
    
    function TestSound()
        dummy = GetSound(portSound);
    end%function

    function TestSwitch()
        dummy = GetSwitch(portSwitch);
    end%function

    function TestUS()
        dummy = GetUltrasonic(portUS);
    end%function

    function TestMotorRead
        % randomly use different motors
        if rand > 0.5
            dummy = motor1.ReadFromNXT();
        else
            dummy = motor2.ReadFromNXT();
        end%if
    end%function

    function TestMotorWrite
        % randomly use different motors and settings
        if rand > 0.5
            DirectMotorCommand(portMotor, 45, 3446, 'on', 'off', 0, 'down');
%             SetMotor(portMotor)
%                 SetPower(45)
%                 SpeedRegulation on
%                 SetAngleLimit(3446)
%                 SetRampMode down
%             SendMotorSettings
        else
            DirectMotorCommand(portMotor2, -80, 3446, 'off', 'off', 0, 'up');
%             SetMotor(portMotor2)
%                 SetPower(-80)
%                 SpeedRegulation off
%                 SetAngleLimit off
%                 SetRampMode up
%             SendMotorSettings
        end%if
        
    end%function


end%function