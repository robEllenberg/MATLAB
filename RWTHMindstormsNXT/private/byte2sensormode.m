function name = byte2sensormode(byte)
% Determines sensor mode parameter from given byte
%
% Syntax
%   name = byte2sensormode(byte)
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
sensormode = {'RAWMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'BOOLEANMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'TRANSITIONCNTMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'PERIODCOUNTERMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'PCTFULLSCALEMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'CELSIUSMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'FAHRENHEITMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];'ANGLESTEPSMODE';[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];[];};

%% Determine mode
name = sensormode{byte + 1};

%% Check name
if (length(name) == 0) %#ok<ISMT>
    name = 'unknown';
    %TODO some kind of warning here to notice the user of this unknown type/mode?
end%if

end%function
