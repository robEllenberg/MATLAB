function NXT_ResetInputScaledValue(port, varargin)
% Resets the sensor's ScaledVal back to 0 (depends on current sensor mode)
%  
% Syntax
%   NXT_ResetInputScaledValue(port) 
%
%   NXT_ResetInputScaledValue(port, handle)
%
% Description
%   NXT_ResetInputScaledValue(port) resets the sensors ScaledVal back to 0 of the given sensor
%   port. The value port can be addressed by the symbolic constants SENSOR_1, SENSOR_2,
%   SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The ScaledVal is set by
%   function NXT_SetInputMode. 
%
%   NXT_ResetInputScaledValue(port, handle) uses the given NXT connection handle. This should be a
%   struct containing a serial handle on a PC system and a file handle on a Linux system.
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
%   For more details see the official LEGO Mindstorms communication protocol.
%
% Note:
%
%   This function should be called after using NXT_SetInputMode, before you want to actually use your new
%   special input value (to make sure counting starts at zero). See NXT_GetInputValues for more details
%   about what kind of values are returned.
%
% Examples
%   NXT_ResetInputScaledValue(SENSOR_2);
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_ResetInputScaledValue(SENSOR_4, handle);
%
% See also: NXT_SetInputMode, NXT_GetInputValues
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
% check if bluetooth handle is given; if not use default one
if nargin > 1
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if port < 0 || port > 3 
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort %d is invalid! It has to be 0, 1, 2 or 3!', port);
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('RESETINPUTSCALEDVALUE');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', port);
textOut(sprintf('+ Resetting input scaled value for port %d...\n', port));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function

