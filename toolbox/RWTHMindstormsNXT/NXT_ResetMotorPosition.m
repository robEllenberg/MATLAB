function NXT_ResetMotorPosition(port, isRelative, varargin)
% Resets NXT internal counter for specified motor, relative or absolute counter
%  
% Syntax
%   NXT_ResetMotorPosition(port, isRelative) 
%
%   NXT_ResetMotorPosition(port, isRelative, handle)
%
% Description
%   NXT_ResetMotorPosition(port, isRelative) resets the NXT internal counter of the given motor
%   port. The value port can be addressed by the symbolic constants MOTOR_A, MOTOR_B,
%   MOTOR_C analog to the labeling on the NXT Brick. The boolean flag isRelative determines the
%   relative (BlockTachoCount) or absolute counter (RotationCount).  
%
%   NXT_ResetMotorPosition(port, handle) uses the given NXT connection handle. This should be a
%   struct containing a serial handle on a PC system and a file handle on a Linux system.
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_ResetMotorPosition(MOTOR_B, true);
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_ResetMotorPosition(MOTOR_A, false, handle);
%
% See also: NXTMotor, ResetPosition, NXC_ResetErrorCorrection
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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

%% Parameter check
% check if bluetooth handle is given. if not use default one
if nargin > 2
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if (port < 0 || port > 2)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'OutputPort %d is invalid! It has to be 0, 1 or 2.', port);
end%if


%% Build byte command
[type cmd] = name2commandbytes('RESETMOTORPOSITION');

if isRelative
    content = [uint8(port); uint8(1)]; % true
    desc = 'relative motor position (BlockTachoCount)';
else
    content = [uint8(port); uint8(0)]; % false
    desc = 'absolute motor position (RotationCount)';
end%if


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', content); 


%% Send bluetooth packet
textOut(sprintf('+ Resetting %s of port %d...\n', desc, port));
COM_SendPacket(packet, handle);

end%function

