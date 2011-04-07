function [degree] = GetCompass(port, varargin)
% Reads the current value of the HiTechnic compass sensor
%
% Syntax
%   degree = GetCompass(port)
%
%   degree = GetCompass(port, handle)
%
% Description
%   degree = GetCompass(port) returns the current heading value of the
%   HiTechnic magnetic compass sensor ranging from 0 to 360 where 0 is north and
%   counterclockwise (90 = west etc.).
%   The given port number specifies the connection port. The value port can be addressed by the
%   symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on
%   the NXT Brick. 
%
%   For more complex settings the functions NXT_LSRead and NXT_LSWrite can be used.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   OpenCompass(SENSOR_4);
%   degree = GetCompass(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: OpenCompass, CalibrateCompass, CloseSensor, COM_ReadI2C
%
% Signature
%   Author: Rainer Schnitzler, Alexander Behrens (see AUTHORS)
%   Date: 2008/08/01
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

    % check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    % initialize
    degree = NaN;

    % alternative register address 0x42,  Read bytes 2 bytes 42/43: 2*<42>+<43>
    % alternative register address 0x44,  alternative word 44/45:  LSB(44) / MSB(45)   
    % see http://www.hitechnic.com for more register information
    % retrieve 2 bytes from device 0x02, register 0x44    
    data = COM_ReadI2C(port, 2, uint8(2), uint8(68), handle);

    if ~isempty(data)
        % degree = data(1)*2 + data(2); (for register address 0x42)
        degree = wordbytes2dec(data,2); % alternative with LSB/MSB
        degree = 360 - degree; % counterclockwise orientation
    end

end%function
