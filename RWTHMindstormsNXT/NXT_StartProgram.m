function status = NXT_StartProgram(filename, varargin)
% Starts the given program on the NXT Brick
%  
% Syntax
%
%   NXT_StartProgram(filename, [handle])
%
%   status = NXT_StartProgram(filename, [handle])
%
% Description
%   NXT_StartProgram(filename) starts the embedded NXT Brick program determined by the string
%   filename. The maximum length is limited to 15 characters. The file
%   extension '.rxe' is added automatically if it was omitted. The output argument status is
%   optional and return the error status of the collected packet. If it is
%   omitted, not reply packet will be requested (this is significantly
%   faster via Bluetooth).
%
%
%   The last parameter handle is optional. If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_StartProgram('ResetCounter');
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_StartProgram('Demo.rxe', handle);
%
% See also: NXT_StopProgram, NXT_GetCurrentProgramName
%
% Signature
%   Author: Alexander Behrens, Linus Atorf (see AUTHORS)
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
% check if bluetooth handle is given. if not use default one
if nargin > 1
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if name is a string
if ~ischar(filename)
	error('MATLAB:RWTHMindstormsNXT:NXTProgramNameNotAString', 'Program name must be a string (char-array)');
end%if

% check if filename extension is present
if length(filename) > 3
    if ~strcmpi(filename(end-3:end), '.rxe')
        filename = [filename '.rxe'];
    end
else
    filename = [filename '.rxe'];
end

% check if name ist not too long
maxnamelen = 15+1+3;
if length(filename) < 5 || length(filename) > maxnamelen
    error('MATLAB:RWTHMindstormsNXT:invalidNXTProgramNameLength', 'Program name must have a length between 5 (e.g. "a.rxe") and %d chars (including extension ".rxe")', maxnamelen);
end%if




%% Send & collect data
if nargout > 0
    NXT_RequestStartProgram(filename, 'reply', handle);
    status = NXT_CollectStartProgram(handle);
else
    NXT_RequestStartProgram(filename, 'dontreply', handle);
end

end%function


%% ### Function: Request Start Program Packet ###
function NXT_RequestStartProgram(progname, telegram, varargin)
% Sends the "StartProgram" packet: Requests to start the program specified by the given filename
%
% Usage: NXT_RequestStartProgram(prgname, telegram, varargin)
%               progname     :  name of the program
%               telegram     :  type of telegram ('reply', 'dontreply')
%               varargin     :  NXT handle (optional)
%

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%%  Write payload
% attach null terminator
payload = [real(progname) 0]';


%% Build bluetooth command
[type cmd] = name2commandbytes('STARTPROGRAM');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, telegram, payload); 
textOut(sprintf('+ Starting NXT program: %s \n', progname));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function


%% ### Function: Collect Current Program Name Packet ###
function status = NXT_CollectStartProgram(varargin)
% Retrieves the previously requested name of the current running program
%
% Returns:    status   : status if start program was successfull (status == 0 == successfulname)
%

%% Parameter check
% check if NXT handle is given; if not use default one
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('STARTPROGRAM');

%% Collect bluetooth packet
[type cmd status content] = COM_CollectPacket(handle, 'dontcheck');

%% Check if packet is the right one
if cmd ~= ExpectedCmd
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    return;
end%if

end % end function 
