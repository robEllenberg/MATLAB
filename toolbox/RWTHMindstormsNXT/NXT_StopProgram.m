function NXT_StopProgram(varargin)
% Stops the currently running program on the NXT Brick
%  
% Syntax
%   NXT_StopProgram() 
%
%   NXT_StopProgram(handle)
%
% Description
%   NXT_StopProgram() stops the current running embedded NXT Brick program.
%
%   NXT_StopProgram(handle) uses the given NXT connection handle. This should be
%   a struct containing a serial handle on a PC system and a file handle on a Linux system. 
%
%   If no Bluetooth handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_StopProgram();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_StopProgram(handle);
%
% See also: NXT_StartProgram, NXT_GetCurrentProgramName
%
% Signature
%   Author: Alexander Behrens, Linus Atorf (see AUTHORS)
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
if nargin > 0
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%%  Write payload
% no payload here...
payload = [];


%% Build bluetooth command
[type cmd] = name2commandbytes('STOPPROGRAM');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', payload); 
textOut(sprintf('+ Stopping current NXT program\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function
