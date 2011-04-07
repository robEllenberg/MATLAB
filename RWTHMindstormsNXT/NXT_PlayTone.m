function NXT_PlayTone(frequency, duration, varargin)
% Plays a tone with the given frequency and duration 
%  
% Syntax
%   NXT_PlayTone(frequency, duration) 
%
%   NXT_PlayTone(frequency, duration, handle)
%
% Description
%   NXT_PlayTone(frequency, duration) plays a tone of the frequency in Hz (200 - 14000Hz) and the
%   duration in milli seconds.
%
%   NXT_PlayTone(frequency, duration, handle) sends the play tone command over the specific
%   NXT handle (e.g. struct containing a serial handle (PC) / file handle (Linux)).
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   NXT_PlayTone(440, 100);
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   COM_SetDefaultNXT(handle);
%   NXT_PlayTone(1200, 120);
%
% See also: COM_GetDefaultNXT
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
if nargin > 2
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if frequency is valid
if (frequency < 200 || frequency > 14000)
    error('MATLAB:RWTHMindstormsNXT:invalidPlayToneFrequency', 'Frequency %d has to be between 200 and 14000 Hz!', frequency);
end%if

% check if duration is valid
if (duration < 0)
    error('MATLAB:RWTHMindstormsNXT:invalidPlayToneDuration', 'Error: Duration %d has to be > 0 ms', duration);
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('PLAYTONE');

content(1:2) = dec2wordbytes(frequency, 2);
content(3:4) = dec2wordbytes(duration, 2);


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'dontreply', content); 
textOut(sprintf('+ Send tone frequency %d Hz and duration %d ms...\n', frequency, duration));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

end%function
