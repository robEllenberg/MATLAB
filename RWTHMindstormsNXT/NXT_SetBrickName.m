function NXT_SetBrickName(name, varargin)
% Sets a new name for the NXT Brick (connected to the specified handle)
%  
% Syntax
%   [NXT_SetBrickName(name) 
%
%   NXT_SetBrickName(name, handle)
%
% Description
%   NXT_SetBrickName(name) sets a new name for the NXT Brick. The value name is a string value
%   and determines the new name of the Brick.  The maximum length is limited to 15 characters.
%
%   NXT_SetBrickName(name, handle) uses the given NXT connection handle. This should be
%   a struct containing a serial handle on a PC system and a file handle on a Linux system. 
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_SetBrickName('MyRobot');
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_SetBrickName('Mindy', handle);
%
% See also: COM_GetDefaultNXT, NXT_SendKeepAlive, NXT_GetBatteryLevel
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
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
if nargin > 1
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if name is a string
if ~ischar(name)
	error('MATLAB:RWTHMindstormsNXT:inputArgumentNotAString', 'New brickname must be a string (char-array)');
end%if

% check if name length is less than 15
maxnamelen = 15;
if length(name) < 1 || length(name) > maxnamelen
    error('MATLAB:RWTHMindstormsNXT:newBricknameTooLong', 'New brickname must have a length between 1 and %d chars', maxnamelen);
end%if

%NOTE string-data does NOT have to be padded with spaces up to maximum data
%length, as it might seem from official direct command documentation or
%other implementations. Check this behaviour in new NXT firmware versions!

% create name: use the actual name, add zero terminated string byte to the end
name = [name char(0)];


%% Build bluetooth command
[type cmd] = name2commandbytes('SET_BRICK_NAME');
content = real(name);


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'reply', content); 
textOut(sprintf('+ Set new name of the Brick to %s \n', name));


%% Send bluetooth packet
COM_SendPacket(packet, handle);


%% Collect bluetooth packet
[type cmd status] = COM_CollectPacket(handle);


%% Check status of the packet
[ok errmsg] = checkStatusByte(status);
% use fprintf() to ensure display is written to console (unlike textOut)
if ok ~= 0 
    fprintf('Communication error: %s\n', errmsg)
else
    fprintf('* Brickname set to "%s"\n', name);
end%if


end%function
