function byte = outputmode2byte(varargin)
% Determines mode byte bit field from given output mode
%
% Syntax
%   byte = outputmode2byte(varargin)
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

%% Create look up table
NXT__MOTORON   = uint8(1);
NXT__BRAKE     = uint8(2);
NXT__REGULATED = uint8(4);

byte = uint8(0);

%% Check parameter
if nargin == 0
    return
end%if

%% Interpret output mode
for j = 1 : nargin
    if ~ischar(varargin{j})
        error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter', 'Input arguments must be a combination of these strings: ''MOTORON'', ''BRAKE'', ''REGULATED''')
    end%if
    if strcmpi(varargin{j}, 'MOTORON')
        byte = bitor(byte, NXT__MOTORON);
    elseif strcmpi(varargin{j}, 'BRAKE')
        byte = bitor(byte, NXT__BRAKE);
    elseif strcmpi(varargin{j}, 'REGULATED')
        byte = bitor(byte, NXT__REGULATED);
    else
        % changed 27.5.08 by LA (was: TODO Raise error here to announce unknown outputmode?)
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidOutputModeName', 'Input arguments must be a combination of these strings: ''MOTORON'', ''BRAKE'', ''REGULATED''');
    end%if
end%for

% although the function is called outputmode2 _BYTE_, we return a double,
% as we do so in the other *2byte functions as well (with one exception:
% dec2wordbytes?)
byte = double(byte);

% so we dont get type mismatches (apparently, MATLAB has no auto conversion
% from uint* to double?)

end%function
