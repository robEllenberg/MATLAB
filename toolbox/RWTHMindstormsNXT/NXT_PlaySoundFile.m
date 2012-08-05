function NXT_PlaySoundFile(filename, loop, varargin)
% Plays the given sound file on the NXT Brick
%  
% Syntax
%   NXT_PlaySoundFile(filename, 'loop')
%
%   NXT_PlaySoundFile(filename, '', handle)
%
% Description
%   NXT_PlaySoundFile(filename, loop) plays the soundfile stored on NXT Brick determined by
%   the string filename. The maximum length is limited to 15 characters. The file
%   extension '.rso' is added automatically if it was omitted. If the loop
%   parameter is equal to 'loop' the playback loop is activated.
%
%   NXT_PlaySoundFile(name, loop, handle) uses the given NXT connection handle.
%   This should be a a struct containing a serial handle on a PC system and a file handle on a Linux system. 
%
%   If no Bluetooth handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_PlaySoundFile('Goodmorning', 0);
%
%   handle = NXT_OpenNXT('bluetooth.ini');
%   NXT_StartProgram('Goodmorning.rso', 1, handle);
%
% See also: NXT_StopSoundPlayback
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/22
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
if nargin > 2
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if name is a string
if ~ischar(filename)
	error('MATLAB:RWTHMindstormsNXT:NXTProgramNameNotAString', 'Program name must be a string (char-array)');
end%if

% check if name length is less than 15
maxnamelen = 15+1+3;
if length(filename) < 1 || length(filename) > maxnamelen
    error('MATLAB:RWTHMindstormsNXT:invalidNXTProgramNameLength', 'Program name must have a length between 1 (e.g. "a.rxe") and %d chars', maxnamelen);
end%if


% check if filename extension is present
if length(filename) > 3
    if ~strcmpi(filename(end-3:end), '.rso')
        filename = [filename '.rso'];
    end
else
    filename = [filename '.rso'];
end

% check loop parameter 
switch loop
    case 'loop'
        loop = true;
    otherwise
        loop = false;
end

%%  Write payload
% attach null terminator
if loop
    loop_byte = 1;
else
    loop_byte = 0;
end
payload = [loop_byte real(filename) 0]';


%% Build bluetooth command
[type cmd] = name2commandbytes('PLAYSOUNDFILE');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', payload); 
textOut(sprintf('+ Playing sound file: %s \n', filename));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function
