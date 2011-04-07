function [name prog_run] = NXT_GetCurrentProgramName(varargin)
% Returns the name of the current running program
%  
% Syntax
%   [name prog_run] = NXT_GetCurrentProgramName() 
%
%   [name prog_run] = NXT_GetCurrentProgramName(handle) 
%
% Description
%   [name prog_run] = NXT_GetCurrentProgramName() returns the name of the current running
%   program. and the boolean flag prog_run (false == no program is running).
%
%   [name prog_run] = NXT_GetCurrentProgramName(handle) uses the given NXT handle. 
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% Examples
%   name = NXT_GetCurrentProgramName();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   name = NXT_GetCurrentProgramName(handle);
%
% See also: NXT_StartProgram, NXT_StopProgram
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/10/18
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
% check if NXT handle is given; if not use default one
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Use wrapper functions
NXT_RequestCurrentProgramName(handle);
[prog_run name] = NXT_CollectCurrentProgramName(handle);

end % end function 



%% ### Function: Request Current Program Name ###
function NXT_RequestCurrentProgramName(varargin)
% Sends the "GetCurrentProgramName" packet: Requests the name of the current program
%
% Usage: NXT_RequestCurrentProgramName(varargin)
%               varargin     :  NXT handle (optional)
%

%% Parameter check
% check if NXT handle is given; if not use default one
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Build direct command
[type cmd] = name2commandbytes('GETCURRENTPROGRAMNAME');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'reply', []); 
textOut(sprintf('+ Requesting name of running program...\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end % end function



%% ### Function: Collect Current Program Name Packet ###
function [prog_run name] = NXT_CollectCurrentProgramName(varargin)
% Retrieves the previously requested name of the current running program
%
% Returns:    name     : name of the running program (string)
%             prog_run : boolean flag if a program is running (false == no program)
%

%% Parameter check
% check if NXT handle is given; if not use default one
if nargin > 0
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Get reference
[dontcare ExpectedCmd] = name2commandbytes('GETCURRENTPROGRAMNAME');

%% Collect bluetooth packet
% use dontcheck argument, since no running program raises an error which we don't
% want to issue as warning...
[type cmd status content] = COM_CollectPacket(handle, 'dontcheck');

%% Check if packet is the right one
if cmd ~= ExpectedCmd
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    name = '';
    return;
end%if

% no manually interpret status byte
if status ~= 0
    [flag name] = checkStatusByte(status);
else
    %% Interpret packet content
    name = '';
    for i=1:1:length(content)
        if content(i) ~= 0
            name = [name char(wordbytes2dec(content(i),1))];
        end
    end
end

prog_run = ~status;

end % end function 

