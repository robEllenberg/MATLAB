function [direction rawData] = GetInfrared(port, varargin)
% Reads the current value of the Hitechnic infrared sensor (infrared seeker)
%
% Syntax
%   [direction rawData] = GetInfrared(port)
%
%   [direction rawData] = GetInfrared(port, handle)
%
% Description
%   [direction rawData] = GetInfrared(port) returns the current direction an the raw data of the
%   detected infrared signal. direction represents the main direction (1-9) calculated based on
%   the measured raw data given in the rawData vector (1x5). Five sensors are provided by the
%   infrared seeker. For more information see http://www.hitechnic.com
%
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   OpenInfrared(SENSOR_4);
%   [direction rawData] = GetInfrared(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: OpenInfrared, CloseSensor, COM_ReadI2C
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/09/25
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
    direction = NaN;
    rawData = [NaN; NaN; NaN; NaN; NaN];


    % retrieve 6 bytes from device 0x02, register 0x42
    data = COM_ReadI2C(port, 6, uint8(2), uint8(66), handle);
    
    if ~isempty(data)
        % this double() is so important!!!
        data = double(data);
        
        direction = data(1);
        rawData = data(2:6);    

    end%if

end%function
