function OpenGyro(port, handle)
% Initializes the HiTechnic Gyroscopic sensor, sets correct sensor mode
%
% Syntax
%   OpenGyro(port)
%
%   OpenGyro(port, handle)
%
% Description
%   OpenGyro(port) initializes the HiTechnic Gyro sensor on the specified sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   Before the sensor can be used, CalibrateGyro has to be called.   
%
%   With GetGyro(port) you can receive Gyro values up to a max. of +/- 360°
%   rotation rate per sec.
%   
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Note:
%   For more details on calibration, see help text and examples of
%   CalibrateGyro.
%
% Examples
%   OpenGyro(SENSOR_2);
%   CalibrateGyro(SENSOR_2, 'AUTO');
%   speed = GetGyro(SENSOR_2);
%   CloseSensor(SENSOR_2);
%
% See also: CalibrateGyro, GetGyro, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Rainer Schnitzler, Linus Atorf (see AUTHORS)
%   Date: 2009/08/31
%   Copyright: 2007-2011, RWTH Aachen University
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


% see private/createEmptyHandleStruct for hardcoded DEFAULT OFFSET VALUES


%% Parameter check

    % NXT handle given?
    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end

    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if

    NXT_SetInputMode(port, 'CUSTOM', 'RAWMODE', 'dontreply', handle);
    % specifications file (for XV-3500CB) mentions a startup-time of 240ms
    % we are generous today :-)
    % this is important, since working with a drifting gyro really is no
    % fun!
    pause(0.3);

end%function
