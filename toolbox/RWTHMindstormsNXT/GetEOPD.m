function [calcedDist rawVal] = GetEOPD(port, handle)
% Reads the current value of the HiTechnic EOPD sensor
%
% Syntax
%   [calcedDist rawVal] = GetEOPD(port)
%
%   [calcedDist rawVal] = GetEOPD(port, handle)
%
% Description
%   This function returns both a calculated distance and the measured raw
%   value from the HiTechnic EOPD sensor.
%
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   Returned raw values are always between 0 and 1023 and indicate
%   reflected light intensity. In 'SHORT' range mode, the values are
%   usually very low, i.e. < 100 or < 200. For increased sensitivity
%   ('LONG' range mode), they can also be higher. This mostly depends on the
%   target surface material.
%
%   The rawVal output argument is always valid. calcedDist however will
%   only have a meaningful value if the sensor is correctly calibrated using CalibrateEOPD.
%   Otherwise values might not make sense or are NaN. If rawVal is 0,
%   calcedDist will be set to Inf.
%
%   More on how to
%   interpret the EOPD sensor values, and a detailed explanation of the calibration
%   formula can be found here:
%   http://www.hitechnic.com/blog/eopd-sensor/eopd-how-to-measure-distance/#more-178
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   port = SENSOR_2;
%   OpenEOPD(port, 'SHORT');
%
%   % set calibration matrix
%   calibMatrix = [3 91; 9 19];
%   CalibrateEOPD(port, 'SETMATRIX', calibMatrix);
%
%   % now the sensor can be used
%   [dist raw] = GetEOPD(port);
%
%   % clean up, as usual. LED stays on anyway
%   CloseSensor(port);
%
% See also: OpenEOPD, CalibrateEOPD, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2010/09/17
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



%% Parameter check

    % NXT handle given?
    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end

    % we have to check port number here as an exception (we usually don't
    % do it, as it gets checked by NXT_ "lower level" functions later on
    % anyway), because we use port as an index in handle.xxx()
    
    % except strings as input
    if ischar(port)
        port = double(port);
    end%if
    if port < 0 || port > 3 
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort must be between 0 and 3 (use constants SENSOR_1 to SENSOR_4)');
    end%if
    
%% Obtain EOPD calibration

    calibrated = false;
    
    % it's save to use the port now...
    calibMatrix = handle.EOPDSensorMatrix(port);
    % careful integrity check
    if nnz(isnan(calibMatrix)) == 0 && isfloat(calibMatrix) && nnz(size(calibMatrix) == [2 2]) == 2 && nnz(calibMatrix > 0) == 4
        
        % now follow http://www.hitechnic.com/blog/eopd-sensor/eopd-how-to-measure-distance/#more-178
        nearDist = calibMatrix(1, 1);
        nearEOPD = calibMatrix(1, 2);
        farDist  = calibMatrix(2, 1);
        farEOPD  = calibMatrix(2, 2);
       
        kScale = (farDist - nearDist) / (1 / sqrt(farEOPD) - 1 / sqrt(nearEOPD));
        kError = kScale / sqrt(nearEOPD) - nearDist; % they call it error, it's basically an offset
                
        calibrated = true;
    end%if

%% Call NXT_GetInputValues function
    in = NXT_GetInputValues(port, handle);

%% Check valid-flag, re-request data if necessary
    if ~in.Valid
        % init timeout-counter
        startTime = clock();
        timeOut = 0.5; % in seconds
        % loop until valid
        while (~in.Valid) && (etime(clock, startTime) < timeOut)
            in = NXT_GetInputValues(port, handle);
        end%while
        % check if everything is ok now...
        if ~in.Valid
            warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidData', ...
                   ['Returned sensor data marked invalid! ' ...
                    'Make sure the sensor is properly connected and configured to a supported mode. ' ...
                    'Disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:invalidData'')']);
        end%if
    end%if
    
    
%% Finally, calc & return data
    % this is what is done in NXC etc., too
    rawVal = 1023 - double(in.RawADVal);
    
    if calibrated
        if rawVal == 0
            calcedDist = Inf;
        end%if
        calcedDist = kScale / sqrt(rawVal) - kError;
        if calcedDist < 0
            calcedDist = 0;
        end%if
    else
        calcedDist = NaN;
    end%if
    
end%function
