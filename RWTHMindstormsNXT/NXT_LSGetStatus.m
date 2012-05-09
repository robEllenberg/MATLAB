function [BytesReady status] = NXT_LSGetStatus(port, varargin)
% Gets the number of available bytes for digital low speed sensors (I2C)
%  
% Syntax
%   [BytesReady status] = NXT_LSGetStatus(port) 
%
%   [BytesReady status] = NXT_LSGetStatus(port, handle) 
%
% Description
%   [BytesReady status] = NXT_LSGetStatus(port) gets the number of available bytes from the low speed (digital)
%   sensor reading of the given sensor port. The value port can be addressed by
%   the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling
%   on the NXT Brick. The return value BytesReady contains the number of bytes available to read. 
%   status indicates if an error occures by the packet transmission. Function checkStatusBytes
%   is interpreting this information per default.
%
%   [BytesReady status] = NXT_LSGetStatus(port, handle) uses the given Bluetooth connection handle. This should be a
%   serial handle on a PC system and a file handle on a Linux system.
%
%   If no Bluetooth handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Note:
%   This function's status byte sometimes contains an error message: "Pending communication
%   transaction in progress". This is by design (see documentation of NXTCommLSCheckStatus
%   on page 70 of the "LEGO Mindstorms NXT Executable File Specification" document). 
%
%   Before using LS commands, the sensor mode has to be set to
%   LOWSPEED_9V using the NXT_SetInputMode command.
%
%
% Examples
%   [BytesReady status] = NXT_LSGetStatus(SENSOR_3);
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_SetInputMode(SENSOR_1, 'LOWSPEED_9V', 'RAWMODE', 'dontreply');
%   % note that status can contain errorsmessages, use checkStatusByte
%   [BytesReady status] = NXT_LSGetStatus(SENSOR_1, handle);
%
% See also: NXT_SetInputMode, checkStatusByte, NXT_LSWrite, NXT_LSRead
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
NXT_LSRequestStatus(port, handle);
[BytesReady status] = NXT_LSCollectStatus(handle);

end % end function




%% ### Function: Request LS Status Packet ###
function NXT_LSRequestStatus(InputPort, varargin)
% Sends the "LSRequestStatus" packet: Requests the current status of the low speed (digital) sensor (e.g. ultrasonic)
%
% Usage: NXT_LSRequestStatus(InputPort, varargin)
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
[type cmd] = name2commandbytes('LSGETSTATUS');



%% Packet bluetooth command
packet = COM_CreatePacket(type, cmd, 'reply', InputPort);


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function




%% ### Function: Collect LS Status Packet ###
function [BytesReady status] = NXT_LSCollectStatus(varargin)
% Retrieves the previously requested low speed (digital) sensor status (e.g. ultrasonic)
%
% Usage: [BytesReady status] = NXT_LSCollectStatus(varargin)
%            port         :  port connected to the digital sensor (e.g. ultrasonic)
%            varargin     :  bluetooth handle (optional)
%
% Returns:    BytesRead   : number of bytes available to read
%             status      : status byte
%
%
% NOTE: This function's status byte sometimes contains an error message:
% "Pending communication transaction in progress". This seems to be by
% design (see documentation of NXTCommLSCheckStatus on page 70 of the
% "LEGO Mindstorms NXT Executable File Specification" document).
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('LSGETSTATUS');

%% Collect bluetooth packet
% note that status could be ~= 0, so dont check and warn here:
[type cmd status content] = COM_CollectPacket(handle, 'dontcheck');

%% Check if packet is the right one
% do NOT check for status byte here, as it may contain an error message.
% this is what LSGetStatus is for after all. 
if cmd ~= ExpectedCmd 
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    BytesReady = 0;
    return;
end%if

%% Interpret packet content
BytesReady = content;

end % end function
