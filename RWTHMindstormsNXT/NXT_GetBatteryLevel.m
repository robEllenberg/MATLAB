function voltage = NXT_GetBatteryLevel(varargin)
% Returns the current battery level in milli volts
%  
% Syntax
%   voltage = NXT_GetBatteryLevel() 
%
%   voltage = NXT_GetBatteryLevel(handle) 
%
% Description
%   voltage = NXT_GetBatteryLevel() returns the current battery level voltage of the NXT Brick in milli
%   voltage.
%
%   voltage = NXT_GetBatteryLevel(handle) uses the given Bluetooth connection handle. This should be a
%   serial handle on a PC system and a file handle on a Linux system.
%
%   If no Bluetooth handle is specified the default one (COM_GetDefaultNXT) is used.
%
% Examples
%   voltage = NXT_GetBatteryLevel();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   voltage = NXT_GetBatteryLevel(handle);
%
% See also: COM_GetDefaultNXT, NXT_SendKeepAlive
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
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Use wrapper functions
NXT_RequestBatteryLevel(handle);
voltage = NXT_CollectBatteryLevel(handle);

end % end function 



%% ### Function: Request Battery Level Packet ###
function NXT_RequestBatteryLevel(varargin)
% Sends the "GetBatteryLevel" packet: Requests the current battery voltage level in [mV]
%
% Usage: NXT_RequestBatteryLevel(varargin)
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
[type cmd] = name2commandbytes('GETBATTERYLEVEL');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'reply', []); 
textOut(sprintf('+ Requesting battery level...\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function



%% ### Function: Collect Battery Level Packet ###
function voltage = NXT_CollectBatteryLevel(varargin)
% Retrieves the previously requested battery level
%
% Returns:    voltage  : battery voltage level in [mv]
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('GETBATTERYLEVEL');

%% Collect bluetooth packet
[type cmd status content] = COM_CollectPacket(handle);

%% Check if packet is the right one
if cmd ~= ExpectedCmd || status ~= 0
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    voltage = 0;
    return;
end%if

%% Interpret packet content
voltage    = wordbytes2dec(content(1:2), 2); %unsigned

end % end function 

