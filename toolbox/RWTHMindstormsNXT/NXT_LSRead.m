function [data BytesRead optionalStatusByte] = NXT_LSRead(port, varargin)
% Reads data from a digital low speed sensor port (I2C)
%  
% Syntax
%   [data BytesRead] = NXT_LSRead(port) 
%
%   [data BytesRead] = NXT_LSRead(port, handle) 
%
%   [data BytesRead optionalStatusByte] = NXT_LSRead(port) 
%
%   [data BytesRead optionalStatusByte] = NXT_LSRead(port, handle) 
%
% Description
%   [data BytesRead] = NXT_LSRead(port)) gets the data of the low speed (digital) sensor value
%   of the given sensor port. The value port can be addressed by the symbolic constants
%   SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The
%   return value BytesRead contains the number of bytes available to read.
%
%   [data BytesRead] = NXT_LSRead(port, handle) uses the given Bluetooth connection handle. This should be a
%   serial handle on a PC system and a file handle on a Linux system.
%
%   [data BytesRead optionalStatusByte] = NXT_LSRead(port, [handle]) will
%   ignore the automatic statusbyte check and instead return it as output
%   argument. This causes the function to ignore erronous I2C calls or
%   crashes if the sensor is not yet ready. You can effectively save a call
%   to NXT_LSGetStatus with this, if you interpret the statusbytes
%   correctly. This may vary, depending on your I2C sensor. The handle
%   argument is still optional, like above.
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Note:
%   For LS communication on the NXT, data lengths are limited to 16 bytes per command. Furthermore,
%   this protocol does not support variable-length return packages, so the response will always
%   contain 16 data bytes, with invalid data bytes padded with zeros.
%
%   Before using LS commands, the sensor mode has to be set to
%   LOWSPEED_9V using the NXT_SetInputMode command.
%
% Examples
%   handle = COM_OpenNXT('bluetooth.ini');
%
%   NXT_SetInputMode(SENSOR_1, 'LOWSPEED_9V', 'RAWMODE', 'dontreply');
%   % usually we would use NXT_LSWrite before, to request some sort of reply
%   [data BytesRead] = NXT_LSRead(SENSOR_1, handle);
%
% See also: NXT_SetInputMode, NXT_LSWrite, NXT_LSGetStatus, COM_ReadI2C
%
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
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'Sensor port %d invalid! It has to be 0, 1, 2 or 3', port);
end%if


%% Use wrapper functions
NXT_LSRequestRead(port, handle);
% depending on optional output argument, pass it or not
if nargout > 2
    [data BytesRead optionalStatusByte] = NXT_LSCollectRead(handle);
else
    [data BytesRead] = NXT_LSCollectRead(handle);
end%of

end % end function




%% ### Function: Request LS Read Packet ###
function NXT_LSRequestRead(InputPort, varargin)
% Sends the "LSRequestRead" packet: Requests the current value of the low speed (digital) sensor (e.g. ultrasonic)
%
% Usage: NXT_LSRequestRead(InputPort, varargin)
%               InputPort    :  inport port connected to the digital sensor (e.g. ultra sonic)
%               varargin     :  bluetooth handle (optional)
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 1
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if InputPort < 0 || InputPort > 3 
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort %d invalid! It has to be 0, 1, 2 or 3', InputPort);
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('LSREAD');


%% Packet bluetooth command
packet = COM_CreatePacket(type, cmd, 'reply', InputPort);


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function




%% ### Function: Collect LS Read Packet ###
function [data BytesRead optionalStatusByte] = NXT_LSCollectRead(varargin)
% Retrieves the previously requested low speed (gitial) sensor value (e.g. ultrasonic)
%
% Usage: [data BytesRead] = NXT_LSRead(port, varargin)
%            port         :  port connected to the digital sensor (e.g. ultrasonic)
%            varargin     :  bluetooth handle (optional)
%
% Returns:    data        : low speed (digital) sensor value
%             BytesRead   : number of bytes to read
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('LSREAD');

%% Collect bluetooth packet
% depending on optional output argument, ignore statusbyte check
if nargout > 2
    [type cmd status content] = COM_CollectPacket(handle, 'dontcheck');
    optionalStatusByte = status;
else
    [type cmd status content] = COM_CollectPacket(handle);
end%if
    
%% Check if packet is the right one
if (cmd ~= ExpectedCmd)
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    BytesRead = 0;
    data = [];
    return;
end%if

%% Interpret packet content
if length(content) ~= 17
    warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidLSReadDataLength', ...
            ['LSRead reply does not contain 16 data bytes, but it should! ' ...
            'This is a condition that should never happen. If it is not a toolbox-bug, ' ...
            'check the I²C protocol. Maybe the NXT firmware or the custom sensor is not ' ...
            'working properly or does not follow the NXT direct commands protocol.']);
end%if

BytesRead = content(1);
% avoid index out of bounds
tmpEnd = min(BytesRead + 1, length(content));
if length(content) > 1
    data = content(2:tmpEnd);
else
    data = [];
end%if

end % end function
