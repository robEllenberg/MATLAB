function status = NXT_SetOutputState(OutputPort, Power, IsMotorOn, IsBrake, RegModeName, TurnRatio, RunStateName, TachoLimit, ReplyMode, varargin)
% Sends previously specified settings to current active motor.
%  
% Syntax
%   status = NXT_SetOutputState(port, power, IsMotorOn, IsBrake, RegModeName, TurnRatio, RunStateName, TachoLimit, ReplyMode) 
%
%   status = NXT_SetOutputState(port, power, IsMotorOn, IsBrake, RegModeName, TurnRatio, RunStateName, TachoLimit, ReplyMode, handle) 
%
% Description
%   status = NXT_SetOutputState(OutputPort, Power, IsMotorOn, IsBrake, RegModeName, TurnRatio,
%   RunStateName, TachoLimit, ReplyMode) sends the given settings like motor port (MOTOR_A,
%   MOTOR_B or MOTOR_C), the power (-100...100, the IsMotorOn boolean flag, the IsBrake
%   boolean flag, the regulation mode name RegModeName ('IDLE', 'SYNC', 'SPEED'), the
%   TurnRatio (-100...100), the RunStateName ('IDLE', 'RUNNING', 'RAMUP', 'RAMPDOWN'),
%   the TachoLimit (angle limit) in degrees, and the ReplyMode. By the ReplyMode one can request
%   an acknowledgement for the packet transmission. The two strings 'reply' and 'dontreply' are
%   valid. The return value status indicates if an error occures by the packet transmission.
%
%   status = NXT_SetOutputState(OutputPort, Power, IsMotorOn, IsBrake, RegModeName, TurnRatio,
%   RunStateName, TachoLimit, ReplyMode, handle) uses the given NXT connection handle.
%   This should be a serial handle on a PC system and a file handle on a Linux system.
%
% Example
%   NXT_SetOutputState(MOTOR_A, 80, true, true, 'SPEED', 0, 'RUNNING', 360, 'dontreply');
% 
% See also: DirectMotorCommand, NXT_GetOutputState, ReadFromNXT, MOTOR_A, MOTOR_B, MOTOR_C
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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

%% Constants
% for some reason we're not using ouputmode2byte...
NXT__MOTORON   = uint8(1);
NXT__BRAKE     = uint8(2);
NXT__REGULATED = uint8(4);


%% Parameter check

OutputPort     = fix(OutputPort);
TurnRatio      = fix(TurnRatio);
TachoLimit     = round(TachoLimit);

% check if bluetooth handle is given; if not use default one
if nargin > 9
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if (OutputPort < 0 || OutputPort > 2) && (OutputPort ~= 255)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'OutputPort %d is invalied, must be between 0 and 2, or 255', OutputPort);
end%if

% check if tacho limit is valid
if (TachoLimit < 0)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidTachoLimit', 'TachoLimit must be >= 0')
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('SETOUTPUTSTATE');

RegModeByte = regmode2byte(RegModeName);
if ~strcmpi(RegModeName, 'IDLE');
    IsRegulated = true;
else
    IsRegulated = false;
end%if

ModeByte = 0;
if IsMotorOn,   ModeByte = bitor(ModeByte, NXT__MOTORON);   end
if IsBrake,     ModeByte = bitor(ModeByte, NXT__BRAKE);     end
if IsRegulated, ModeByte = bitor(ModeByte, NXT__REGULATED); end

% create the real package payload
content       = uint8(zeros(10, 1));
content(1)    = OutputPort;
content(2)    = dec2wordbytes(Power, 1, 'signed'); % convert to signed byte
content(3)    = ModeByte;
content(4)    = RegModeByte;
content(5)    = dec2wordbytes(TurnRatio, 1, 'signed');
content(6)    = runstate2byte(RunStateName);
content(7:10) = dec2wordbytes(TachoLimit, 4); % unsigned says lego doc


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, ReplyMode, content);


%% Send bluetooth packet
COM_SendPacket(packet, handle);


%% Receive status packet if reply mode is used
if strcmpi(ReplyMode, 'reply')
    [type cmd status content] = COM_CollectPacket(handle);
else
    status = 0; %ok
end%if

end%function
