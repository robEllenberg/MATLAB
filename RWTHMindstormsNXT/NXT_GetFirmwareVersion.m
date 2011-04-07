function [protocol_version firmware_version] = NXT_GetFirmwareVersion(varargin)
% Returns the protocol and firmware version of the NXT
%  
% Syntax
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion()
%
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion(handle)
%
% Description
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion() returns the protocol and
%   firmware version of the NXT as strings. 
%
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion(handle) uses the given
%   NXT connection handle. This should be a struct containing a serial handle on a PC system and a file handle on a Linux system.
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% Examples
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   [protocol_version firmware_version] = NXT_GetFirmwareVersion(handle);
%
% See also: COM_GetDefaultNXT
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/22
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
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Use wrapper functions
NXT_RequestFirmwareVersion(handle);
[protocol_version firmware_version] = NXT_CollectFirmwareVersion(handle);

end % end function 



%% ### Function: Request Firmware Version ###
function NXT_RequestFirmwareVersion(varargin)
% Sends the "GetFirmwareVersion" packet: Requests the protocol and firmware version of the NXT
%
% Usage: NXT_RequestFirmwareVersion(varargin)
%               varargin     :  bluetooth handle (optional)
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('GET_FIRMWARE_VERSION');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'reply', []); 
textOut(sprintf('+ Requesting firmware version...\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function



%% ### Function: Collect Protocol and Firmware Version ###
function [protocol_version firmware_version] = NXT_CollectFirmwareVersion(varargin)
% Retrieves the previously requested protocol and firmware version of the NXT
%
% Returns:    protocl_version   : protcol version of the NXT
%             firmware_version  : firmware version of the NXT
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
   handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('GET_FIRMWARE_VERSION');

%% Collect bluetooth packet
[type cmd status content] = COM_CollectPacket(handle);

%% Check if packet is the right one
if cmd ~= ExpectedCmd || status ~= 0
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    protocol_version = NaN;
    firmware_version = NaN;
    return;
end%if

%% Interpret packet content
protocol_version = [num2str(wordbytes2dec(content(2),1)) '.' sprintf('%02d',wordbytes2dec(content(1),1))];
firmware_version = [num2str(wordbytes2dec(content(4),1)) '.' sprintf('%02d',wordbytes2dec(content(3),1))];

end % end function 

