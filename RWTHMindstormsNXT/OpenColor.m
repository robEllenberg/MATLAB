function OpenColor(port, varargin)
% Initializes the HiTechnic color V1 or V2 sensor, sets correct sensor mode 
%
% Syntax
%   OpenColor(port)
%
%   OpenColor(port, handle)
%
% Description
%   OpenColor(port) initializes the input mode of HiTechnic Color sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%   This function works for both HiTechnic Color sensors V1 and V2.
%
%   With GetColor(port) you can receive color values as RGB or Index.
%   
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   Since the Color sensor is a digital sensor (that uses the I²C protocol),
%   the function NXT_SetInputMode cannot be used as for analog sensors.
%
%
% Limitations
%   It's by design that the white LED of the Color sensors cannot be turned
%   off by calling CloseSensor. It's always on when the sensor is
%   connected. The V2 hardware version of the sensor performs significantly
%   better than the V1 version.
% 
%
% Examples
%   OpenColor(SENSOR_2);
%   [index r g b] = GetColor(SENSOR_2, 0);
%   CloseSensor(SENSOR_2);
%
% See also: GetColor, CalibrateColor, CloseSensor, OpenNXT2Color, GetNXT2Color, COM_ReadI2C
%
% Signature
%   Author: Rainer Schnitzler, Linus Atorf (see AUTHORS)
%   Date: 2010/09/16
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

    % check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if

    NXT_SetInputMode(port, 'LOWSPEED_9V', 'RAWMODE', 'dontreply', handle);
    pause(0.1); % let sensor "power up"...

%% Flushing data memory (unkown procedure)
    % the following command sequence is not clearly documented but was
    % found to work well!
	NXT_LSGetStatus(port, handle); % flush out data with Poll
    % we request the status-byte so that it doesn't get checked.
    % errors that can occur here are:
    %Packet (reply to LSREAD) contains error message 221: "Communication bus error"
    %Packet (reply to LSREAD) contains error message 224: "Specified
    %channel/connection not configured or busy"
	[a b c] = NXT_LSRead(port, handle);      % flush out data with Poll?
end%function
