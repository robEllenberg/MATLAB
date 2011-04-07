function name = commandbyte2name(byte)
% Determines command name from given command byte
%
% Syntax
%   name = commandbyte2name(byte)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
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

%% Check parameter
if byte < 0 || byte > 255
    error('MATLAB:RWTHMindstormsNXT:invalidByteValue', 'Bytes must be between 0 and 255!');
end%if

%% Create look up table
% we added the value '???' for 255 to mark the original initialized value
% (i.e. when the command was not yet known). this is far better than using
% 0 as uninitialized value, since cmdname{0} STARTPROGRAM, and we don't
% want that...
cmdname = {'STARTPROGRAM';'STOPPROGRAM';'PLAYSOUNDFILE';'PLAYTONE';'SETOUTPUTSTATE';'SETINPUTMODE';'GETOUTPUTSTATE';'GETINPUTVALUES';'RESETINPUTSCALEDVALUE';'MESSAGEWRITE';'RESETMOTORPOSITION';'GETBATTERYLEVEL';'STOPSOUNDPLAYBACK';'KEEPALIVE';'LSGETSTATUS';'LSWRITE';'LSREAD';'GETCURRENTPROGRAMNAME';[];'MESSAGEREAD';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'GET_FIRMWARE_VERSION';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'SET_BRICK_NAME';[];[];'GET_DEVICE_INFO';[];[];[];[];[];'POLL_COMMAND_LENGTH';'POLL_COMMAND';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'???';};

%% Determine command name
name = cmdname{byte + 1};

%% Check name
if (length(name) == 0) %#ok<ISMT>
    name = 'unknown';
    %TODO some kind of warning here to notice the user of this unknown command?
end 

end%function

