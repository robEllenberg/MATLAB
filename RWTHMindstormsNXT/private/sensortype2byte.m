function byte = sensortype2byte(name)
% Determines sensor type byte from given sensor type name
%
% Syntax
%   byte = sensortype2byte(name)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf, Nick Watts (see AUTHORS)
%   Date: 2010/09/14
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

%% Create look up table
NXT__NO_SENSOR          =  0; %#ok<NASGU> %hex2dec('00'); %#ok<NASGU>
NXT__SWITCH             =  1; %#ok<NASGU> %hex2dec('01'); %#ok<NASGU>
NXT__TEMPERATURE        =  2; %#ok<NASGU> %hex2dec('02'); %#ok<NASGU>
NXT__REFLECTION         =  3; %#ok<NASGU> %hex2dec('03'); %#ok<NASGU>
NXT__ANGLE              =  4; %#ok<NASGU> %hex2dec('04'); %#ok<NASGU>
NXT__LIGHT_ACTIVE       =  5; %#ok<NASGU> %hex2dec('05'); %#ok<NASGU>
NXT__LIGHT_INACTIVE     =  6; %#ok<NASGU> %hex2dec('06'); %#ok<NASGU>
NXT__SOUND_DB           =  7; %#ok<NASGU> %hex2dec('07'); %#ok<NASGU>
NXT__SOUND_DBA          =  8; %#ok<NASGU> %hex2dec('08'); %#ok<NASGU>
NXT__CUSTOM             =  9; %#ok<NASGU> %hex2dec('09'); %#ok<NASGU>
NXT__LOWSPEED           =  10;%#ok<NASGU> %hex2dec('0A'); %#ok<NASGU>
NXT__LOWSPEED_9V        =  11;%#ok<NASGU> %hex2dec('0B'); %#ok<NASGU>
NXT__HIGHSPEED          =  12;%#ok<NASGU> %hex2dec('0C'); %#ok<NASGU>
NXT__COLORFULL          =  13;%#ok<NASGU> %hex2dec('0D'); %#ok<NASGU>
NXT__COLORRED           =  14;%#ok<NASGU> %hex2dec('0E'); %#ok<NASGU>
NXT__COLORGREEN         =  15;%#ok<NASGU> %hex2dec('0F'); %#ok<NASGU>
NXT__COLORBLUE          =  16;%#ok<NASGU> %hex2dec('10'); %#ok<NASGU>
NXT__COLORNONE          =  17;%#ok<NASGU> %hex2dec('11'); %#ok<NASGU>
NXT__NO_OF_SENSOR_TYPES =  18;%#ok<NASGU> %hex2dec('12'); %#ok<NASGU>


%% Check parameter
if ~exist(['NXT__' name], 'var') || ~isreal(['NXT__' name])
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidTypeName', 'Unknown NXT sensor type "%s". See inside this method (private/sensortype2byte.m) for a list.', name)
end%if

%% Interpret sensor type byte
byte = eval(['NXT__' name]);

end%function
