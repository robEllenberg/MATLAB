function NXC_MotorControl(Port, Power, TachoLimit, SpeedRegulation, ActionAtTachoLimit, SmoothStart, handle)
% Sends advanced motor-command to the NXC-program MotorControl on the NXT brick
%
% Syntax
%   NXC_MotorControl(Port, Power, TachoLimit, SpeedRegulation, ActionAtTachoLimit, SmoothStart)
%
%   NXC_MotorControl(Port, Power, TachoLimit, SpeedRegulation, ActionAtTachoLimit, SmoothStart, handle)
%
% Description
%   The NXC-program "MotorControl" must be running on the brick, otherwise
%   this function will not work. It is used to send advanced motor commands
%   to the NXT that can perform better and more precise motor regulation
%   than possible with only classic direct commands.
%
%   While one command is being executed (i.e. when the motor is still being
%   controlled if a TachoLimit other than 0 was set), this motor cannot
%   accept new commands. Use the NXTMotor classes command .WaitFor to make
%   sure the motor has finished it's current operation, before
%   sending a new one. If the NXC-program receives a new command while it
%   is still busy, a warning signal (high beep, then low beep) will be
%   played.
%
%   The command StopMotor (or NXTMotor's method .Stop) is always available to
%   stop a controlled motor-operation, even before the TachoLimit is reached. 
%
%
% Input:
% * Port has to be a port number between 0 and 2, or an array with max. 2
%   different motors specified.
%
% * Power is the power level applied to the motor, value between -100 and
%   100 (sign changes direction)
%
% * TachoLimit - integer from 0 to 999999, specifies the angle in degrees
%               the motor will try to reach, set 0 to run forever. Note
%               that direction is specified by the sign of Power.
%
% * SpeedRegulation must be false for "normal", unregulated motor
%   control. If set to true, single motors will be operated in speed
%   regulation mode. This means that the motor will increase its internal
%   power setting to reach a constant turning speed. Use this option when
%   working with motors under varying load. If you'd like to have motor movement
%           with preferrably constant torque, it's advisable to disable
%           this option.
%   In conjunction with multiple motors 
%   (i.e. when Port is an array of 2 ports), you have to disable
%   SpeedRegulation! Multiple motorss will enable synchronization between the two
%   motors. They will run at the same speed as if they were connected
%   through and axle, leading to straight movement for driving bots.
%
% * ActionAtTachoLimit is a string parameter with valid options
%   'Coast', 'Brake' or 'HoldBrake'. It specifies how the motor(s) should react
%   when their position counter reaches the set TachoLimit. In COAST
%   mode, the motor(s) will simply be turned of when the TachoLimit is
%   reached, leading to free movement until slowly stopping (called
%   coasting). The TachoLimit won't be met, the motor(s) move way too far
%   (overshooting), depending on their angular momentum.
%   Use BRAKE mode (default) to let the motor(s) automatically
%   slow down nice and smoothly shortly before the TachoLimit. This leads
%   to a very high precision, usually the TachoLimit is met within +/- 1
%   degree (depending on the motor load and speed of course). After this
%   braking, power to the motor(s) is turned off when they are at rest.
%   HOLDBRAKE is similar to BRAKE, but in this case, the active brake of
%   the motors stays enabled (careful, this consumes a lot of battery
%   power), causing the motor(s) to actively keep holding their position.
%
% * SmoothStart can be set to true to smoothly accelerate movement.
%   This "manual ramp up" of power will occur fairly quickly. It's
%   comfortable for driving robots so that they don't loose traction when
%   starting to move. If used in conjunction with SpeedRegulation for
%   single motors, after accleration is finished and the full power is
%   applied, the speed regulation can possibly even accelerate a bit more.
%
% * handle (optional) defines the given NXT connection. If no handle is 
%   specified, the default one (COM_GetDefaultNXT()) is used.
%
%
% Limitations
%
%   If you send a command to the NXT without waiting for the previous motor
%   operation to have finished, the command will be dropped (the NXT
%   indicates this with a high and low beep tone). Use NXTMotor classes WaitFor
%   to make sure the motor is ready for new  commands, or stop the motor
%   using NXTMotor's method .Stop.
%
%   The option SmoothStart in conjunction with ActionAtTachoLimit ==
%   'Coast' is not available. As a workaround, disable SmoothStart for
%   this mode.
%
%   With ActionAtTachoLimit = 'Coast' and synchronous driving (two motors),
%   the motors will stay synced after movement (even after .WaitFor() has
%   finished). This is by design. To disable the synchonization, just use
%   StopMotor(port, 'off').
%
% See also: WaitForMotor, NXT_SetOutputState, NXT_GetOutputState, NXC_ResetErrorCorrection, MOTOR_A, MOTOR_B, MOTOR_C%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/07/20
%   Copyright: 2007-2011, RWTH Aachen University
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

%% initialize
    InboxNr = 1; % meant is the NXT's inbox (i.e. MATLAB's outbox if you will)


%% Lot's of Error-Checking and preparing input data...
    
    % NXT handle given?
    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end
    
    % port-array ok?
    if length(Port) > 2
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'Maximum number of ports allowed for this command is 2');
    end%if
    for j = 1 : length(Port)
        if IsFraction(Port(j)) | (Port(j) < 0) | (Port(j) > 2)
            error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'A motor-port can only be 0, 1, or 2 for this command. An array of up to 2 different motors is allowed.');
        end%if
    end%for
    if (length(Port) == 2) && (Port(1) >= Port(2))
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort',...
                        'Two ports must not be the same and must be given in ascending order.');
    end%if

  
    
    % important to sort so that it's either AB, AC or BC!
    Port = sort(Port);
    % set real port number to use in protocol
    % we use the following port constants, apart from the ABC thing
    % OUT_A	0x00
    % OUT_B	0x01
    % OUT_C	0x02
    % OUT_AB	0x03
    % OUT_AC	0x04
    % OUT_BC	0x05
    % OUT_ABC	0x06

    if length(Port) > 1
        if (Port(1) == 0) && (Port(2) == 1)
        	prt = 3;
        elseif (Port(1) == 0) && (Port(2) == 2)
            prt = 4;
        elseif (Port(1) == 1) && (Port(2) == 2)
            prt = 5;
        end%if
    else
      prt = Port;  
    end%if
    
    if IsFraction(Power) | (Power > 100) | (Power < -100) 
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidPower', 'Input argument Power has to be an integer between -100 and 100!');
    end%if

    if IsFraction(TachoLimit) | (TachoLimit < 0) | (TachoLimit > 999999)
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidTachoLimt', 'Input argument TachoLimit has to be an integer between 0 and 999999!');
    end%if

    pwr = ConvertFromSigned(Power);
    
    if (prt > 2) && (SpeedRegulation)
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidSpeedRegulation', 'SpeedRegulation cannot be enabled when using multiple motors together (since they are operated synchronized). Set SpeedRegulation to false or use a single motor!');
    end%if
    
    
    % doesn't apply anymore
    % advanced check if current NXC program will do something
    %if (prt > 2) && (TachoLimit == 0)
    %    warning('MATLAB:RWTHMindstormsNXT:Motor:NXCProgramWillIgnoreThis', 'You''re sending a motor-command for 2 motors with TachoLimit = 0. The NXC-program "MotorControl" running on the brick will ignore this. Use classic Direct Commands like NXT_SetOutputState instead for this parameter configuration.')
    %end%if
    
%% Decide between controlled and uncontrolled cmd
    if strcmpi(ActionAtTachoLimit, 'coast')

        % build string message for uncontrolled cmd
        %from the NXC program:
        % #define PROTO_CONTROLLED_MOTORCMD       1 
        % #define PROTO_RESET_ERROR_CORRECTION    2
        % #define PROTO_ISMOTORREADY              3
        % #define PROTO_CLASSIC_MOTORCMD          4 <--
        % #define PROTO_JUMBOPACKET               5
        
        if SmoothStart && (TachoLimit ~= 0)
            warning('MATLAB:RWTHMindstormsNXT:Motor:noSmoothStartForCoastAtTachoLimit', 'The option SmoothStart is not supported for ActionAtTachoLimit = ''Coast'' and will be ignored. Either set SmoothStart to false, or disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Motor:noSmoothStartForCoastAtTachoLimit'')');
        end%if
        
        msg = sprintf('4%1d%3d%6d%1d', prt, pwr, TachoLimit, SpeedRegulation);
        
        
    elseif strcmpi(ActionAtTachoLimit, 'brake') || strcmpi(ActionAtTachoLimit, 'holdbrake')
    
        % use mode as bitfield...
        HoldBrake = strcmpi(ActionAtTachoLimit, 'holdbrake');
        
        mode = 0;
        if HoldBrake;           mode = mode + 1; end
        if SpeedRegulation;     mode = mode + 2; end
        if SmoothStart;         mode = mode + 4; end

    
        % build string message for controlled cmd
        %from the NXC program:
        % #define PROTO_CONTROLLED_MOTORCMD       1 <--
        % #define PROTO_RESET_ERROR_CORRECTION    2
        % #define PROTO_ISMOTORREADY              3
        % #define PROTO_CLASSIC_MOTORCMD          4
        % #define PROTO_JUMBOPACKET               5
        msg = sprintf('1%1d%3d%6d%1d', prt, pwr, TachoLimit, mode);
    
    else
        % error out if necessary
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidActionAtTachoLimit',...
                    'Possible values for ActionAtTachoLimit are ''Coast'' (turn off motor at TachoLimit), ''Brake'' (brake until motor has stopped at TachoLimit, then turn it off), ''HoldBrake'' (same as ''Brake'', but keep active brake enabled).');
    end%if
        
        
%% Add delay if necessary 
    % if an NXC command was sent a very short time ago for this motor (or a stop command),
    % wait here until the NXC program has processed everything:

    NXTMOTOR_State = handle.NXTMOTOR_getState();
   
    delay = 0.015; %#NXCDELAY
    for j = 1 : length(Port)
        % wait if other NXC command was sent...
        while toc(NXTMOTOR_State(Port(j)+1).LastMsgToNXCSentTime) < delay
            % wait ^^
        end%while
        % wait if a stop was sent...
        while toc(NXTMOTOR_State(Port(j)+1).LastStopCmdSentTime) < delay
            % wait ^^
        end%while
    end%for
    
    
%% finally, send message    
    NXT_MessageWrite(msg, InboxNr, handle);

    
%% Remember timestamp
    
    for j = 1 : length(Port)
        NXTMOTOR_State(Port(j)+1).LastMsgToNXCSentTime = tic();
    end%for
    
    handle.NXTMOTOR_setState(NXTMOTOR_State);
    
end%function



%% helper functions
function y = ConvertFromSigned(x)
    if x < 0
        y = 100 + abs(x);
    else
        y = x;
    end%if
end%function

function ret = IsFraction(x)
    if x == fix(x)
        ret = false;
    else
        ret = true;
    end%if
end%if
    
    