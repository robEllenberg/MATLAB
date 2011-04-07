function NXT_LSWrite(InputPort, RXLength, data, ReplyMode, varargin)
% Writes given data to a digital low speed sensor port (I2C)
%  
% Syntax
%   NXT_LSWrite(port, RXLength, data, ReplyMode) 
%
%   NXT_LSWrite(port, RXLength, data, ReplyMode, handle) 
%
% Description
%   NXT_LSWrite(port, RXLength, data, ReplyMode) writes the given data to a low speed (digital)
%   sensor of the given sensor port. The value port can be addressed by the symbolic constants
%   SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The
%   value RXLength represents the data length of the expected receiving packet. By the ReplyMode
%   one can request an acknowledgement for the packet transmission. The two strings 'reply' and
%   'dontreply' are valid.
%
%   NXT_LSWrite(port, RXLength, data, ReplyMode, handle) uses the given Bluetooth connection
%   handle. This should be a serial handle on a PC system and a file handle on a Linux system.
%
%   If no Bluetooth handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Note:
%   For LS communication on the NXT, data lengths are limited to 16 bytes per command. Rx Data Length
%   MUST be specified in the write command since reading from the device is done on a master-slave
%   basis.
%
%   Before using LS commands, the sensor mode has to be set to
%   LOWSPEED_9V using the NXT_SetInputMode command.
%
% Example
%   RequestLen = 1;
%   I2Cdata = hex2dec(['02'; '42']); % specific ultrasonic I²C command
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_SetInputMode(SENSOR_1, 'LOWSPEED_9V', 'RAWMODE', 'dontreply');
%
%   NXT_LSWrite(SENSOR_1, RequestLen, I2Cdata, 'dontreply', handle);
%
% See also: NXT_SetInputMode, NXT_LSRead, NXT_LSGetStatus, COM_ReadI2C
%
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

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 4
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if InputPort < 0 || InputPort > 3 
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort %d invalid! It has to be 0, 1, 2 or 3', InputPort);
end%if


if length(data) > 16
    error('MATLAB:RWTHMindstormsNXT:Sensor:LSWriteDataTooLarge', 'LSWrite data input lengths on the NXT are limited to a maximum size of 16 bytes!')
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('LSWRITE');

content = zeros(4+length(data) - 1, 1);
content(1) = InputPort;
content(2) = uint8(length(data)); % TX data len
content(3) = uint8(RXLength);     % RX data len
content(4:4+length(data)-1) = data(:);



%% Packet bluetooth command
packet = COM_CreatePacket(type, cmd, ReplyMode, content);


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function

