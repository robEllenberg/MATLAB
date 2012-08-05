function ToolboxTest
%% ToolboxTest
% This tool offers multiple toolbox tests, originally written to track
% or confirm certain bugs. The quality of these tests isn't very high,
% but running and passing them should make sure the bugs are gone and
% don't return after certain changes.
%
% For the tests you have to connect the following hardware equipment to
% your NXT:
%
% * All 3 motors to ports A, B, C
% * The NXT light sensor to port 1
% * Any digital sensor to port 4 (e.g. ultrasonic).
%
% The following tests are available. They can (and should) all be tested
% with USB and Bluetooth connections:
%
% # Command syntax check: Many toolbox commands are called and tested, with
% or without default handles. This detects syntax errors and obvious
% mistakes when changing / braking a function.
% # Check USB connection after cable has been removed -- versions prior to
% 4.01 would crash MATLAB on Linux here.
% # Motor control timing and multitasking tests: Does the motor control
% lock up or stall when braking multiple motors at once, etc.?
% # Motor precision torture test: Many random movements, does it work for a
% long time? What is the overall precision?
% # Motor precision torture as above, but with all motors running
% simultaneously (and independently)
% # Same as above, but this time two motors are synced and the other one
% runs independently.
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/10/07
%   Copyright: 2007-2010, RWTH Aachen University
%
%
;
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

    DebugMode off

    disp(sprintf(['Available tests:\n', ...
          ' 1. Test syntax of most commands (test terminates)\n', ...
          ' 2. Test "MATLAB crash on Linux after USB cable removed bug"\n', ...
          '    fixed in ver4.02, see also ticket 39 (test terminates)\n', ...
          ' 3. Test certain MotorControl timing/latency (test terminates)\n', ...
          ' 4. Torture test for MotorControl precsion, single motor\n', ...
          '    (test runs infinitely, break with CTRL+C)\n', ...
          ' 5. Torture test for MotorControl precsion, all motors\n', ...
          '    (test runs infinitely, break with CTRL+C)\n', ...
          ' 6. Torture test for MotorControl precsion, two motors synced\n', ...
          '    one motor single (test runs infinitely, break with CTRL+C)\n', ...
           ]))
       
    answer = NaN;
    while(isnan(answer))
        answer = str2double(input('Enter your choice: ', 's'));
    end%if

    testFunc{1} = @TestCommandSyntax;
    testFunc{2} = @TestNoUSBCableBug;
    testFunc{3} = @CheckLatenciesBetweenStopAndSend;
    testFunc{4} = @SingleMotorPrecisionTorture;
    testFunc{5} = @AllMotorsPrecisionTorture;
    testFunc{6} = @TwoSyncedOneSingleMotorsPrecisionTorture;
    
    
    disp(sprintf('\nStarting test no. %d ...\n', answer));
    
    testFunc{answer}();
 


end%function

function TestCommandSyntax
    analogPort = SENSOR_1;
    digitalPort = SENSOR_4;
    
    %% Connect to NXT
    disp('    Connecting...')

    % different syntaxes and things
    h = COM_OpenNXT('bluetooth.ini');
    COM_CloseNXT(h);
    h = COM_OpenNXT('bluetooth.ini');
    COM_CloseNXT('all');

    h = COM_OpenNXTEx('Any', '', 'bluetooth.ini');



    %% Try the commands WITHOUT default handle
    disp('    *** Commands without default handle')

    %% *** SENSORS
    disp('    Sensors...')

    port = analogPort;
    %% analog
    %light
    OpenLight(port, 'active', h);
    NXT_ResetInputScaledValue(port, h);
    GetLight(port, h);
    CloseSensor(port, h);

    OpenLight(port, 'inactive', h);
    GetLight(port, h);
    CloseSensor(port, h);

    %sound
    OpenSound(port, 'db', h);
    GetSound(port, h);
    CloseSensor(port, h);

    OpenSound(port, 'dba', h);
    GetSound(port, h);
    CloseSensor(port, h);

    %switch
    OpenSwitch(port, h);
    GetSwitch(port, h);
    CloseSensor(port, h);
    
    % gyro
    OpenGyro(port, h);
    CalibrateGyro(port, 'Auto', h);
    GetGyro(port, h);
    CloseSensor(port, h);


    port = digitalPort;

    %% I2C
    disp('    I2C...')

    %ultrasonic
    OpenUltrasonic(port, '', h);
    GetUltrasonic(port, h);
    CloseSensor(port, h);

    OpenUltrasonic(port, 'snapshot', h);
    USMakeSnapshot(port, h);
    USGetSnapshotResults(port, h);
    CloseSensor(port, h);

    %compass
    OpenCompass(port, h);
    GetCompass(port, h);
    CalibrateCompass(port, true, h);
    pause(0.5);
    CalibrateCompass(port, false, h);
    CloseSensor(port, h);

    %acceleration
    OpenAccelerator(port, h);
    GetAccelerator(port, h);
    CloseSensor(port, h);

    %infrared
    OpenInfrared(port, h);
    GetInfrared(port, h);
    CloseSensor(port, h);


    %% MOTORS
    port = MOTOR_B;
    port2 = MOTOR_C;
    disp('    Motors...')

    StopMotor('all', 'brake', h);
    StopMotor('all', 'off', h);

    SwitchLamp(port, 'on', h);
    SwitchLamp(port, 'off', h);
    
    m   = NXTMotor(port);
    m2  = NXTMotor([port; port2]);

    tmp1 = m.ReadFromNXT(h);
    m.ResetPosition(h);
    m.Stop('brake', h);
    m.Stop('off', h);
    
    [tmp1 tmp2] = m2.ReadFromNXT(h);
    m2.ResetPosition(h);
    m2.Stop('brake', h);
    m2.Stop('off', h);
    
    m.WaitFor(5, h);
    m2.WaitFor(5, h);
    
    m.Power = 50;
    m.TachoLimit = 300;
    m.ActionAtTachoLimit = 'Brake';
    m.SpeedRegulation = true;
    m.SmoothStart = true;
    m.SendToNXT(h);
    m.WaitFor(10, h);
    
    m.SpeedRegulation = false;
    m.SmoothStart = true;
    m.ActionAtTachoLimit = 'HoldBrake';
    m.SendToNXT(h);
    m.WaitFor(10, h);
    
    m.ActionAtTachoLimit = 'Coast';
    m.SmoothStart = false;
    m.SendToNXT(h);
    m.WaitFor(10, h);
    
    m.Stop('off', h);
    
    m2.Power = -50;
    m2.TachoLimit = 400;
    m2.SpeedRegulation = false;
    m2.ActionAtTachoLimit = 'Brake';
    m2.SmoothStart = true;
    m2.SendToNXT(h);
    m2.WaitFor(10, h);
    
    m2.Stop('off', h);
    


    %% Direct Commands
    disp('    Some direct commands...')


    NXT_ResetMotorPosition(port, true, h);
    NXT_ResetMotorPosition(port, false, h);

    NXT_SendKeepAlive('dontreply', h);

    NXT_PlayTone(800, 500, h);

    [status sleeptime]  = NXT_SendKeepAlive('reply', h);
    battery             = NXT_GetBatteryLevel(h);
    [protocol firmware] = NXT_GetFirmwareVersion(h);

    battery
    sleeptime
    firmware


    %% Set Default!

    COM_SetDefaultNXT(h);

    %% Try the commands WITH default handle
    disp('    *** Commands with default handle')

    %% *** SENSORS
    disp('    Sensors...')

    port = analogPort;
    %% analog
    %light
    OpenLight(port, 'active');
    NXT_ResetInputScaledValue(port);
    GetLight(port);
    CloseSensor(port);

    OpenLight(port, 'inactive');
    GetLight(port);
    CloseSensor(port);

    %sound
    OpenSound(port, 'db');
    GetSound(port);
    CloseSensor(port);

    OpenSound(port, 'dba');
    GetSound(port);
    CloseSensor(port);

    %switch
    OpenSwitch(port);
    GetSwitch(port);
    CloseSensor(port);
    
    % gyro
    OpenGyro(port);
    CalibrateGyro(port, 'Auto');
    GetGyro(port);
    CloseSensor(port);


    port = digitalPort;

    %% I2C
    disp('    I2C...')

    %ultrasonic
    OpenUltrasonic(port, '');
    GetUltrasonic(port);
    CloseSensor(port);

    OpenUltrasonic(port, 'snapshot');
    USMakeSnapshot(port);
    USGetSnapshotResults(port);
    CloseSensor(port);

    %compass
    OpenCompass(port);
    GetCompass(port);
    CalibrateCompass(port, true);
    pause(0.5);
    CalibrateCompass(port, false);
    CloseSensor(port);

    %acceleration
    OpenAccelerator(port);
    GetAccelerator(port);
    CloseSensor(port);

    %infrared
    OpenInfrared(port);
    GetInfrared(port);
    CloseSensor(port);


    %% MOTORS
    port = MOTOR_B;
    port2 = MOTOR_C;
    disp('    Motors...')

    StopMotor('all', 'brake');
    StopMotor('all', 'off');

    SwitchLamp(port, 'on');
    SwitchLamp(port, 'off');
    
    m   = NXTMotor(port);
    m2  = NXTMotor([port; port2]);

    tmp1 = m.ReadFromNXT();
    m.ResetPosition();
    m.Stop('brake');
    m.Stop('off');
    
    [tmp1 tmp2] = m2.ReadFromNXT();
    m2.ResetPosition();
    m2.Stop('brake');
    m2.Stop('off');
    
    m.WaitFor();
    m2.WaitFor();
    
    m.Power = 50;
    m.TachoLimit = 300;
    m.ActionAtTachoLimit = 'Brake';
    m.SpeedRegulation = true;
    m.SmoothStart = true;
    m.SendToNXT();
    m.WaitFor();
    
    m.SpeedRegulation = false;
    m.SmoothStart = true;
    m.ActionAtTachoLimit = 'HoldBrake';
    m.SendToNXT();
    m.WaitFor();
    
    m.ActionAtTachoLimit = 'Coast';
    m.SmoothStart = false;
    m.SendToNXT();
    m.WaitFor();
    
    m.Stop('off');
    
    m2.Power = -50;
    m2.SpeedRegulation = false;
    m2.TachoLimit = 400;
    m2.ActionAtTachoLimit = 'Brake';
    m2.SmoothStart = true;
    m2.SendToNXT();
    m2.WaitFor();
    
    m2.Stop('off');


    %% Direct Commands
    disp('    Some direct commands...')


    NXT_ResetMotorPosition(port, true);
    NXT_ResetMotorPosition(port, false);

    NXT_SendKeepAlive('dontreply');

    NXT_PlayTone(800, 500);

    [status sleeptime]  = NXT_SendKeepAlive('reply');
    battery             = NXT_GetBatteryLevel(h);
    [protocol firmware] = NXT_GetFirmwareVersion(h);

    battery
    sleeptime
    firmware





    COM_CloseNXT(h);

    disp('    *** Test successful so far ***')
end%function

function TestNoUSBCableBug
    COM_CloseNXT all
    clear all

    disp('    No MATLAB crash means: TEST SUCCESSFUL!')
    disp('    Any error message is a good thing!')
    disp('    ')

    DebugMode off

    % USB Verbindung herstellen
    myNXT = COM_OpenNXT();
    COM_CloseNXT(myNXT);


    disp('    UNPLUG USB CABLE')
    disp('    Press ENTER to continue')
    pause;


    % Bluetooth Verbindung herstellen (actually USB ^^)
    myNXT = COM_OpenNXT();

    COM_CloseNXT(myNXT);
    
end%function

function CheckLatenciesBetweenStopAndSend()
    COM_CloseNXT all

    disp('    Listen for the NXT to beep. It should NOT do that!');
    disp('    Beeping means a dropped motor command, this is bad.');
    disp('    Motors B and C should spin, stop, then motor B spin.');
    disp('    Press ENTER to continue...');
    pause;
    
    %% Set up parameters
    port                = MOTOR_B;
    port2               = MOTOR_C;


    %% Connect to NXT
    hNXT = COM_OpenNXT('bluetooth.ini');
    COM_SetDefaultNXT(hNXT);


    %% Create basic object
    m = NXTMotor;
    m.Port                  = port;
    m.Power                 = 80;
    m.TachoLimit            = 1000;
    m.SpeedRegulation       = true;
    m.SmoothStart           = true;
    m.ActionAtTachoLimit    = 'Brake';

    m2 = m;
    m2.Port = port2;

    %% Precall method to fill MATLAB cache;
    % the order here makes sense, even with the multiple commands :-)
    % it's the proper way to use .WaitFor after .Stop! It might be a bit slower
    % sometimes, but it can never go wrong!
    m.Stop();
    m.WaitFor();
    m.SendToNXT();
    m.Stop();
    m.WaitFor();

    pause(0.5);

    %% Main test

    % start 1st motor 
    m.SendToNXT();
    % now the trick that let's us create very fine granulated pauses:
    % what we wait here will be the time we get to use .Stop before
    % the motor stops, so we can get right into the interesting
    % last braking section
    pause(0.1);
    m2.SendToNXT();

    % when waiting for the 1st motor is done, the 2nd will be exactly the
    % amount of pause before finishing (if the motors run exact equally).
    m.WaitFor()

    % now the test:
    m2.Stop();
    % can we already start the next command with m2?
    m2.SendToNXT();


    %% Clean up
    COM_CloseNXT(hNXT);
    
     disp('Test completed (no NXT beep and 2 separate movements means: successful)');

end%function

function SingleMotorPrecisionTorture()
    %% Prepare
    COM_CloseNXT all
    
    disp('   Running torture test. Beeping NXT or')
    disp('   TIME OUT warnings are bad!')
    disp('   Terminate with CTRL+C')
    

    %% Set up parameters
    port                = MOTOR_B;
    ActionAtTachoLimit  = 'Brake';

    minAbsPower         =    10;
    maxAbsPower         =   100;
    minTachoLimit       =    8;
    maxTachoLimit       =  1200;


    %% Create basic motor object
    m = NXTMotor;
    m.Port                  = port;
    %m.SpeedRegulation       = SpeedRegulation;
    %m.SmoothStart           = SmoothStart;
    m.ActionAtTachoLimit    = ActionAtTachoLimit;


    %% Connect to NXT
    hNXT = COM_OpenNXT('bluetooth.ini');
    COM_SetDefaultNXT(hNXT);


    %% Main testing loop
    figure;
    j = 0;
    while (true)
        j = j + 1;

        m.SpeedRegulation   = (rand > 0.5);
        m.SmoothStart       = (rand > 0.5);


        powerSgn    = 1 - (rand > 0.5) * 2;
        absPower    = floor(minAbsPower + (maxAbsPower - minAbsPower) * rand);
        tachoLimit  = floor(minTachoLimit + (maxTachoLimit - minTachoLimit) * rand);

        m.Power         = absPower * powerSgn;
        m.TachoLimit    = tachoLimit; 

        m.SendToNXT();
        if m.WaitFor(20)
            disp('TIME OUT')
            NXT_PlayTone(600, 500);
            stat = NXT_GetOutputState(m.Port(1))
            m
            m.Stop('off');
        end%if



        data = m.ReadFromNXT();

        error(j) = (data.TachoCount * powerSgn) - tachoLimit;

        hist(error);
        xlabel('Absolute error (relative to target position) in degrees')
        ylabel('Absolute number of error values occured')
        title('Histogram for motor precision')
        drawnow

    end%while
end%function

function AllMotorsPrecisionTorture()
    %% Prepare
    COM_CloseNXT all

    disp('   Running torture test. Beeping NXT or')
    disp('   TIME OUT warnings are bad!')
    disp('   Terminate with CTRL+C')
    
    
    %% Set up parameters
    port                = MOTOR_B;
    port2               = MOTOR_C;
    port3               = MOTOR_A;

    ActionAtTachoLimit  = 'Brake';

    minAbsPower         =    10;
    maxAbsPower         =   100;
    minTachoLimit       =    8;
    maxTachoLimit       =  1200;


    %% Create basic motor object
    m = NXTMotor;
    m.Port                  = port;
    m.ActionAtTachoLimit    = ActionAtTachoLimit;


    %% Connect to NXT
    hNXT = COM_OpenNXT('bluetooth.ini');
    COM_SetDefaultNXT(hNXT);


    %% Main testing loop
    figure;
    j = 0;
    while (true)
        j = j + 1;

        powerSgn    = 1 - (rand > 0.5) * 2;
        absPower    = floor(minAbsPower + (maxAbsPower - minAbsPower) * rand);
        tachoLimit  = floor(minTachoLimit + (maxTachoLimit - minTachoLimit) * rand);

        m.SpeedRegulation   = (rand > 0.5);
        m.SmoothStart       = (rand > 0.5);


        m.Power         = absPower * powerSgn;
        m.TachoLimit    = tachoLimit; 

        m2 = m;
        m2.Port = port2;
        m3 = m;
        m3.Port = port3;

        m2.Stop();
        m3.Stop();

        %pause(0.5);

        m.SendToNXT();

        pause(0.1 * rand);
        m2.SendToNXT();
        pause(0.1 * rand);
        m3.SendToNXT();

        if m.WaitFor(20);
            disp('TIME OUT')
            NXT_PlayTone(600, 500);
            stat = NXT_GetOutputState(m.Port(1))
            m
            m.Stop('off');
        end%if

        data = m.ReadFromNXT();

        error(j) = (data.TachoCount * powerSgn) - tachoLimit;
        hist(error);
        xlabel('Absolute error (relative to target position) in degrees')
        ylabel('Absolute number of error values occured')
        title('Histogram for motor precision')
        drawnow

    end%while



    %% Clean up
    COM_CloseNXT(hNXT);

end%function

function TwoSyncedOneSingleMotorsPrecisionTorture()
    %% Prepare
    COM_CloseNXT all
    
    disp('   Running torture test. Beeping NXT or')
    disp('   TIME OUT warnings are bad!')
    disp('   Terminate with CTRL+C')

    %% Set up parameters
    singlePort          = MOTOR_A;
    syncPort1           = MOTOR_B;
    syncPort2           = MOTOR_C;

    SpeedRegulation     = false;
    SmoothStart         = true;
    ActionAtTachoLimit  = 'Brake';

    minAbsPower         =    10;
    maxAbsPower         =   100;
    minTachoLimit       =    8;
    maxTachoLimit       =  1200;


    %% Create basic motor object
    m = NXTMotor;
    m.Port                  = singlePort;
    m.SpeedRegulation       = SpeedRegulation;
    m.SmoothStart           = SmoothStart;
    m.ActionAtTachoLimit    = ActionAtTachoLimit;

    %% Create decoy sync object
    s = NXTMotor;
    s.Port                  = [syncPort1; syncPort2];
    s.SpeedRegulation       = false; % off for sync
    s.SmoothStart           = SmoothStart;
    s.ActionAtTachoLimit    = ActionAtTachoLimit;


    %% Connect to NXT
    hNXT = COM_OpenNXT('bluetooth.ini');
    COM_SetDefaultNXT(hNXT);


    %% Main testing loop
    figure;
    j = 0;
    while (true)
        j = j + 1;


        powerSgn    = 1 - (rand > 0.5) * 2;
        absPower    = floor(minAbsPower + (maxAbsPower - minAbsPower) * rand);
        tachoLimit  = floor(minTachoLimit + (maxTachoLimit - minTachoLimit) * rand);

        m.Power           = absPower * powerSgn;
        m.TachoLimit      = tachoLimit; 
        m.SmoothStart     = (rand > 0.5);
        m.SpeedRegulation = (rand > 0.5);

        s.Power         = m.Power;
        s.TachoLimit    = m.TachoLimit;
        s.SmoothStart   = (rand > 0.5);

        s.Stop();

        %pause(0.5);

        m.SendToNXT();

        pause(0.1 * rand);
        s.SendToNXT();

        if m.WaitFor(20)
            disp('TIME OUT')
            NXT_PlayTone(600, 500);
            stat = NXT_GetOutputState(m.Port(1))
            m
            m.Stop('off');
        end%if

        data = m.ReadFromNXT();

        error(j) = (data.TachoCount * powerSgn) - tachoLimit;
        hist(error);
        xlabel('Absolute error (relative to target position) in degrees')
        ylabel('Absolute number of error values occured')
        title('Histogram for motor precision')
        drawnow

    end%while



    %% Clean up
    COM_CloseNXT(hNXT);
end%function