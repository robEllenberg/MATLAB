function NXT_StopSoundPlayback(varargin)
% Stops the current sound playback
%  
% Syntax
%   NXT_StopSoundPlayback()
%
%   NXT_StopSoundPlayback(handle)
%
% Description
%   NXT_StopSoundPlayback() stops the current sound playback.
%
%   NXT_StopSoundPlayback(handle) sends the stop sound playback command over the specific
%   Bluetooth handle (serial handle (PC) / file handle (Linux)).
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_StopSoundPlayback();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   NXT_StopSoundPlayback(handle);
%
% See also: NXT_PlaySoundFile, NXT_PlayTone, COM_GetDefaultNXT
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



%% Build bluetooth command
[type cmd] = name2commandbytes('STOPSOUNDPLAYBACK');

content = [];


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', content); 
textOut(sprintf('+ Stop sound playback...\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function
