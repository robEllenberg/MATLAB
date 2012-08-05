function name = byte2sensortype(byte)
% Determines sensor type parameter from given byte
%
% Syntax
%   name = byte2sensortype(byte)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf, Nick Watts (see AUTHORS)
%   Date: 2010/09/14
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

%% Check parameter
if byte < 0 || byte > 255
    error('MATLAB:RWTHMindstormsNXT:invalidByteValue', 'Bytes must be between 0 and 255!');
end%if

%% Create look up table
sensorname = {'NO_SENSOR';'SWITCH';'TEMPERATURE';'REFLECTION';'ANGLE';'LIGHT_ACTIVE';'LIGHT_INACTIVE';'SOUND_DB';'SOUND_DBA';'CUSTOM';'LOWSPEED';'LOWSPEED_9V';'HIGHSPEED';'COLORFULL';'COLORRED';'COLORGREEN';'COLORBLUE';'COLORNONE';'NO_OF_SENSOR_TYPES';};

%% Determine sensor type
try
    name = sensorname{byte + 1};
catch
    name = 'unknown';
    %TODO some kind of warning here to notice the user of this unknown type/mode?
end%try

end%function







