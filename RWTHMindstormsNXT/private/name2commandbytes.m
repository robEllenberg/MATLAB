function [type cmd bytes] = name2commandbytes(name)
% Determines command bytes from given command name
%
% Syntax
%   [type cmd bytes] = name2commandbytes(name)
%
% Description
%   The function names are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
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

persistent lookup

if isempty(lookup)
%% System commands
    lookup.GET_FIRMWARE_VERSION   = [1; 136]; %#ok<NASGU> %hex2dec(['01'; '88']);
    lookup.SET_BRICK_NAME         = [1; 152]; %#ok<NASGU> %hex2dec(['01'; '98']);
    lookup.GET_DEVICE_INFO        = [1; 155]; %#ok<NASGU> %hex2dec(['01'; '9B']);
    lookup.POLL_COMMAND_LENGTH    = [1; 161]; %#ok<NASGU> %hex2dec(['01'; 'A1']);
    lookup.POLL_COMMAND           = [1; 162]; %#ok<NASGU> %hex2dec(['01'; 'A2']);

    lookup.READ_IO_MAP            = [1; 148];  %#ok<NASGU> %hex2dec(['01'; '94']);
    lookup.WRITE_IO_MAP           = [1; 149];  %#ok<NASGU> %hex2dec(['01'; '95']);

%% Direct commands
    lookup.STARTPROGRAM           = [0; 0];   %#ok<NASGU> %hex2dec(['00'; '00']);
    lookup.STOPPROGRAM            = [0; 1];   %#ok<NASGU> %hex2dec(['00'; '01']);
    lookup.PLAYSOUNDFILE          = [0; 2];   %#ok<NASGU> %hex2dec(['00'; '02']);
    lookup.PLAYTONE               = [0; 3];   %#ok<NASGU> %hex2dec(['00'; '03']);
    lookup.SETOUTPUTSTATE         = [0; 4];   %#ok<NASGU> %hex2dec(['00'; '04']);
    lookup.SETINPUTMODE           = [0; 5];   %#ok<NASGU> %hex2dec(['00'; '05']);
    lookup.GETOUTPUTSTATE         = [0; 6];   %#ok<NASGU> %hex2dec(['00'; '06']);
    lookup.GETINPUTVALUES         = [0; 7];   %#ok<NASGU> %hex2dec(['00'; '07']);
    lookup.RESETINPUTSCALEDVALUE  = [0; 8];   %#ok<NASGU> %hex2dec(['00'; '08']);
    lookup.MESSAGEWRITE           = [0; 9];   %#ok<NASGU> %hex2dec(['00'; '09']);
    lookup.RESETMOTORPOSITION     = [0; 10];  %#ok<NASGU> %hex2dec(['00'; '0A']);
    lookup.GETBATTERYLEVEL        = [0; 11];  %#ok<NASGU> %hex2dec(['00'; '0B']);
    lookup.STOPSOUNDPLAYBACK      = [0; 12];  %#ok<NASGU> %hex2dec(['00'; '0C']);
    lookup.KEEPALIVE              = [0; 13];  %#ok<NASGU> %hex2dec(['00'; '0D']);
    lookup.LSGETSTATUS            = [0; 14];  %#ok<NASGU> %hex2dec(['00'; '0E']);
    lookup.LSWRITE                = [0; 15];  %#ok<NASGU> %hex2dec(['00'; '0F']);
    lookup.LSREAD                 = [0; 16];  %#ok<NASGU> %hex2dec(['00'; '10']);
    lookup.GETCURRENTPROGRAMNAME  = [0; 17];  %#ok<NASGU> %hex2dec(['00'; '11']);
    lookup.MESSAGEREAD            = [0; 19];  %#ok<NASGU> %hex2dec(['00'; '13']);

end%if
    

%% Determine command bytes
bytes = lookup.(name);
type  = bytes(1);
cmd   = bytes(2);

end%function
