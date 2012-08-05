function [angularVelocity] = GetGyro(port, handle)
% Reads the current value of the HiTechnic Gyro sensor
%
% Syntax
%   angularVelocity = GetGyro(port)
%
%   angularVelocity = GetGyro(port, handle)
%
% Description
%   angularVelocity = GetGyro(port) returns the current rotational speed detected by
%   the HiTechnic Gyroscopic sensor. Maximum range is from -360 to 360 degrees per second
%   (according to HiTechnic documentation), however greater values have
%   been observed. Returned values are accurate to +/- 1 degree.
%
%   Integration over time gives the rotational position (in degrees). Tests give quite good
%   results.  The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   Before using this function, the gyro sensor must be initialized using OpenGyro 
%   and calibrated using CalibrateGyro.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   OpenGyro(SENSOR_2);
%   CalibrateGyro(SENSOR_2, 'AUTO');
%   speed = GetGyro(SENSOR_2);
%   CloseSensor(SENSOR_2);
%
% See also: OpenGyro, CalibrateGyro, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Linus Atorf, Rainer Schnitzler (see AUTHORS)
%   Date: 2010/09/14
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

    % we have to check port number here as an exception (we usually don't
    % do it, as it gets checked by NXT_ "lower level" functions later on
    % anyway), because we use port as an index in handle.GyroSensorOffset()
    
    % except strings as input
    if ischar(port)
        port = double(port);
    end%if
    if port < 0 || port > 3 
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort must be between 0 and 3 (use constants 0SENSOR_1 to SENSOR_4)', port);
    end%if
    
%% Obtain gyro offset
    % save to use the port now...
    tmp = handle.GyroSensorOffset(port);
    % tmp(1) = offset, tmp(2) = bool initialized
    if ~tmp(2)
        warning('MATLAB:RWTHMindstormsNXT:Sensor:gyroNotCalibrated', 'The HiTechnic Gyro sensor on this port has not been calibrated yet. Use CalibrateGyro() after OpenGyro() or disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:gyroNotCalibrated'')');
    end%if
    offset = tmp(1);
    
%% Call NXT_GetInputValues function
    in = NXT_GetInputValues(port, handle);

%% Check valid-flag, re-request data if necessary
    if ~in.Valid
        % init timeout-counter
        startTime = clock();
        timeOut = 0.3; % in seconds
        % loop until valid
        %invalidCountGetGyro = 0;
        while (~in.Valid) && (etime(clock, startTime) < timeOut)
            in = NXT_GetInputValues(port, handle);
            %invalidCountGetGyro = invalidCountGetGyro + 1;
        end%while
        %invalidCountGetGyro
        % check if everything is ok now...
        if ~in.Valid
            warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidData', ...
                   ['Returned sensor data marked invalid! ' ...
                    'Make sure the sensor is properly connected and configured to a supported mode. ' ...
                    'Disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:invalidData'')']);
        end%if
    end%if
    
    
%% Finally, return gyro data after offset substraction
    angularVelocity = double(in.RawADVal) - offset;
      
    
end%function
