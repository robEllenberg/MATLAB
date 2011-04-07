function OpenEOPD(port, range, handle)
% Initializes the HiTechnic EOPD sensor, sets correct sensor mode
%
% Syntax
%   OpenEOPD(port, range)
%
%   OpenEOPD(port, range, handle)
%
% Description
%   OpenEOPD(port, range) initializes the HiTechnic EOPD sensor on the specified sensor
%   port. This sensor can be used to accurately detect objects and small
%   changes in distance to a target. It works by measuring the light
%   returned from its own light source, so it can also be used to detect
%   the "shinyness" and color of a surface.
%
%   range can be set to either 'SHORT', which covers a range of about
%   10cm, or it can be set to 'LONG', which enables increased sensitivity
%   for up to 20cm.
%
%   The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   Before the sensor can be used, CalibrateEOPD should be called,
%   otherwise only raw values will be usable. Values can be retrieved using
%   GetEOPD.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Note:
%   For more details on calibration, see help text and examples of
%   CalibrateEOPD.
%
%   Since each EOPD sensor uses a slightly different pulse frequency for
%   the LED, multiple sensor can be used at once without influencing each
%   other.
%
% Limitations
%   It is normal that the red LED always stays on once the sensor is connected.
%   The LED cannot be turned off using CloseSensor.
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
% See also: CalibrateEOPD, GetEOPD, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/09/17
%   Copyright: 2007-2010, RWTH Aachen University
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

    if ~strcmpi(range, 'SHORT') && ~strcmpi(range, 'LONG')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'EOPD sensor range has to be ''SHORT'' or ''LONG''!');
    end
    
    if strcmpi(range, 'SHORT')
        type = 'LIGHT_INACTIVE';
    else
        type = 'LIGHT_ACTIVE';
    end%if
    
    
    NXT_SetInputMode(port , type, 'RAWMODE', 'dontreply', handle);
    % give sensor some bootup time
    % measured was about 25ms
    pause(0.05);

end%function
