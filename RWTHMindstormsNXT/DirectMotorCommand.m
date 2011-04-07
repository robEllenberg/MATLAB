function DirectMotorCommand(f_port, f_power, f_angle, f_speed, f_sync, f_ratio, f_ramp)
% Sends a direct command to the specified motor
%  
% Syntax
%
%   DirectMotorCommand(port, power, angle, speedRegulation, syncedToMotor, turnRatio, rampMode) 
%
% Description

%   DirectMotorCommand(port, power, angle, speedRegulation, syncedToMotor, turnRatio, rampMode)
%   sends the given settings like motor port (MOTOR_A, MOTOR_B or MOTOR_C), the power
%   (-100...100), the angle limit (also called TachoLimit), speedRegulation ('on', 'off'), syncedToMotor
%   (MOTOR_A, MOTOR_B, MOTOR_C), turnRatio (-100...100) and rampMode ('off', 'up',
%   'down'). 
%
%   This function is basically a convenient wrapper
%   for NXT_SetOutputState. It provides the fastest way possible to send a
%   direct command to the motor(s) via Bluetooth or USB. Complex parameter
%   combinations which are needed for speed regulation or synchronous
%   driving when using NXT_SetOutputState are not necessary, this
%   function does make sure the motor "just works". See below for examples.
%
% Note:
%   When driving synced motors, it's recommended to stop the motors between
%   consecutive direct motor command (using StopMotor) and to reset their
%   position counters (using NXT_ResetMotorPosition).
%
%   This function is intended for the advanced user. Knowledge about the
%   LEGO MINDSTORMS NXT Bluetooth Communication Protocol is not required,
%   but can help to understand what this function does.
%   
% Limitations:
%   Generally spoken, using DirectMotorCommand together with the class
%   NXTMotor (and its method SendToNXT) for the same motor is strongly discouraged.
%   This function can interfer with the on-brick embedded NXC program MotorControl and
%   could cause it to crash. It ignores whatever is happening on the NXT
%   when sending the direct command. The only advantage is the low latency.
%
%   When using the parameter angleLimit, the motor tries to reach the
%   desired position by turning off the power at the specified position.
%   This will lead to overshooting of the motor (i.e. the position it stops
%   will be too high or too low). Additionally, the LEGO firmware applies an
%   error correction mechanism which can lead to confusing results. Please
%   look inside the chapter "Troubleshooting" of this toolbox documentation
%   for more details.
%
%
% Examples
%
%  % let a driving robot go straight a bit.
%  % we use motor synchronization for ports B & C:
%  DirectMotorCommand(MOTOR_B, 60, 0, 'off', MOTOR_C, 0, 'off');
%  pause(5); % driving 5 seconds
%  StopMotor(MOTOR_B, 'off');
%  StopMotor(MOTOR_C, 'off');
%
%  % let motor A rotate for 1000 degrees (with COAST after "braking" and
%  % the firmware's error correction) and with speed regulation:
%  DirectMotorCommand(MOTOR_A, 50, 1000, 'on', 'off', 0, 'off');
%
%  % this command
%  DirectMotorCommand(MOTOR_A, 0, 0, 'off', 'off', 0, 'off');
%  % does exactly the same as calling
%  StopMotor(MOTOR_A, 'off');
%  % or as using
%  m = NXTMotor('A');
%  m.Stop('off');
%
% See also: NXT_SetOutputState, NXT_GetOutputState, NXTMotor, SendToNXT,
% Stop, StopMotor
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2009/08/25
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

%%
%
% The whole idea of the SetMotor, SetPower etc. concept is that we can
% reveal more complex functions later on. For beginners, a simple
% instruction like this is enough:
%   SetMotor(MOTOR_A);
%      SetPower(100);
%   DirectMotorCommand;
%
% The active motor will be remembered for each current active NXT, as well
% as all motor settings. The handle manages all information about an NXT,
% including its motors.
%
% Compare these easy commands to MATLABs way of using figures:
% In the beginning, a command sequence like this is just fine:
%   figure
%   plot(X, '.r')
%
% But later on, you can also use advanced settings:
%   figure
%   plot(X, '.r')
%   colormap hot
%   axis square
%   material shiny
%   shading interp
%   lighting phong
%
% Just like you would use more advanced motor commands:
%   SetMotor(MOTOR_A)
%       SpeedRegulation on
%       SetPower 80
%       SetAngleLimit 500
%       SetRampMode up
%       SyncToMotor off
%       SetTurnRatio 0 
%   DirectMotorCommand
%



%% check given arguments
if (nargin ~= 7)
    error('MATLAB:RWTHMindstormsNXT:invalidParameterCount', ...
         ['All 7 function arguments are needed. ' ...
          'Type "help DirectMotorCommand" or see documentation!']);
end

if ((f_port < 0) || (f_port > 2)) || isnan(f_port)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'MotorPort must be 0, 1, or 2. Constants MOTOR_A, MOTOR_B, and MOTOR_C can be used.');
end%if


%% get handle
h = COM_GetDefaultNXT();



%% set parameter for function call with arguments
if nargin > 0
    
    if ~strcmpi(f_sync, 'off') && ~strcmpi(f_speed, 'off')
        error('MATLAB:RWTHMindstormsNXT:Motor:simultaneousSyncAndSpeedRegulationError', 'You can only use motor synchronization OR speed regulation at a time, but not both settings together.')
    end%if
    
    
    % don't influence with MotorSet, if different was set
    try
        oldmotor = h.NXTMOTOR_getCurrentMotor();
    catch
        oldmotor = NaN;
    end%try
    
    %TODO In this short version of DirectMotorCommand, we use SyncToMotor
    % and SpeedRegulation consecutively. Even if the parameters are correct
    % (meaning that motor sync and speed reg are mutually exclusive), we
    % produce a warning at this point, if e.g. speedreg was activated
    % before and should now be deactivated while using sync. In this
    % combination of long and short versions of DirectMotorCommand, this
    % warning produced by SpeedRegulation() is wrong. We have to avoid it
    % at this point by adding a SpeedRegulation('off'); before
    % SyncToMotor in the following command sequence, or by adding a little
    % if statement, depending on performance and complications...
    
    
    SetMotor(f_port);
        % choose correct order to avoid warnings
        if strcmpi(f_speed, 'off')
            SpeedRegulation(f_speed);
            SyncToMotor(f_sync);
        else
            SyncToMotor(f_sync);
            SpeedRegulation(f_speed);
        end%if
        SetPower(f_power);
        SetAngleLimit(f_angle);
        SetTurnRatio(f_ratio);
        SetRampMode(f_ramp);
        
    % for restore see later down
end


% get current motor state
% do it here, because a new state might have been set using the long syntax
% through the SetMotor-sequence above...
NXTMOTOR_State = h.NXTMOTOR_getState();

%% regular command sequence
whatmotor = h.NXTMOTOR_getCurrentMotor();

%function status = NXT_SetOutputState(OutputPort, Power, IsMotorOn, IsBrake, RegModeName, TurnRatio, RunStateName, TachoLimit, ReplyMode, varargin)


%% only use turnratio if motor is synced, ignore if all motors set...
if whatmotor ~= 255
    TurnRatio = 0; % only has affect if regmode is SYNC
    syncedmotor = -1;
    if NXTMOTOR_State(whatmotor + 1).SyncedToSpeed
        RegModeName = 'SPEED';
    elseif NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
        RegModeName = 'SYNC';
        TurnRatio = NXTMOTOR_State(whatmotor + 1).TurnRatio;
        syncedmotor = NXTMOTOR_State(whatmotor + 1).SyncedToMotor; 
    else
        RegModeName = 'IDLE';
    end%if
end%if

%% if synced....
if whatmotor ~= 255
    if syncedmotor ~= -1
        % send other packet as well
        NXT_SetOutputState(syncedmotor, ... % port
            NXTMOTOR_State(syncedmotor + 1).Power, ... % power
            true, ... % motoron
            ~NXTMOTOR_State(syncedmotor + 1).BrakeDisabled, ... % brake
            RegModeName, ... % reg mode
            NXTMOTOR_State(syncedmotor + 1).TurnRatio, ... % turn ratio
            NXTMOTOR_State(syncedmotor + 1).RunStateName, ... % runstate 
            NXTMOTOR_State(syncedmotor + 1).AngleLimit, ...
            'dontreply'); 

        if (NXTMOTOR_State(syncedmotor+1).Power ~= 0)
            % set memory counter
            SetMemoryCount(syncedmotor, GetMemoryCount(syncedmotor) + ...
                           sign(NXTMOTOR_State(syncedmotor+1).Power) * NXTMOTOR_State(syncedmotor+1).AngleLimit); 
        end
    end%if
end%if

% if all motor ports are set, we remember this now
realport = whatmotor;
% but whatmotor cannot be > 2, or else the global var will be out of
% index...
if whatmotor == 255
    % we set it to the first motor in this case, if all motors are set,
    % their settings should be the same anyway...
    whatmotor = 0; % looks like bad style to override it here, i know...
    
    % need to set these now as they weren't set above
    if NXTMOTOR_State(whatmotor + 1).SyncedToSpeed
        RegModeName = 'SPEED';
    else
        % SYNC doesn't make sense for all motors!
        RegModeName = 'IDLE';
    end%if
    % also no sense makes a TurnRatio:
    TurnRatio = 0;
    
end%if


%% send "regular" packet...
NXT_SetOutputState(realport, ... % port
    NXTMOTOR_State(whatmotor + 1).Power, ... % power
    true, ... % motoron
    ~NXTMOTOR_State(whatmotor + 1).BrakeDisabled, ... % brake
    RegModeName, ... % reg mode
    TurnRatio, ... % turn ratio
    NXTMOTOR_State(whatmotor + 1).RunStateName, ... % runstate 
    NXTMOTOR_State(whatmotor + 1).AngleLimit, ...
    'dontreply'); 

    if (NXTMOTOR_State(whatmotor+1).Power ~= 0)
        % set memory counter
        SetMemoryCount(whatmotor, GetMemoryCount(whatmotor) + ...
                       sign(NXTMOTOR_State(whatmotor+1).Power) * NXTMOTOR_State(whatmotor+1).AngleLimit); 
    end
    

    
%% Restore previous motor number setting
try % try because oldmotor might not've been set
    % applies only to short-notation with nargin == 7...
    if ~isnan(oldmotor)
        h.NXTMOTOR_setCurrentMotor(oldmotor);
    end
catch
    % nothing, its nothing to restore here...
end%


%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
