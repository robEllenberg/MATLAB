function out = GetSwitch(f_sensorport, varargin)
% Reads the current value of the NXT switch / touch sensor
%
% Syntax
%   switch = GetSwitch(port)
%
%   switch = GetSwitch(port, handle)
%
% Description
%   switch = GetSwitch(port) returns the current switch value switch of the NXT switch / touch
%   sensor. The measurement value switch represents the pressing mode of the switch / touch
%   sensor. true is returned if the switch / touch sensor is being pressed and false if it is
%   being released. The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   For more complex settings the function NXT_GetInputValues can be used.
%
%
% Example
%   OpenSwitch(SENSOR_4);
%   switchState = GetSwitch(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: NXT_GetInputValues, OpenSwitch, CloseSensor, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
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

% We're using RAWMODE here, because BOOLEAN mode would be nice, but isn't
% really necessary. We can use the .NormalizedADVal from GetInputValues, as
% we have this variable ALLWAYS. If we were to use BOOLEAN mode, and then
% use the .ScaledVal (what we had to do in this case because that is where
% the BOOLEAN mode val is effectively stored), we'd take away ourselves the
% possibility to use PERIODCNTMODE later on to detect "taps" or something
% else. 
% Also this function would stop working if someone used NXT_SetInputMode
% with something other then BOOLEANMODE. And we certainly want to save
% the possibility to do so later on. That's why we take the
% .NormalizedADVal and compare it against the empirically found
% threshold...
%

%% check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if


%% Call NXT_GetInputValues function
    in = NXT_GetInputValues(f_sensorport, handle);
    
%% Check valid-flag, re-request data if necessary
    if ~in.Valid
        % init timeout-counter
        startTime = clock();
        timeOut = 0.3; % in seconds
        % loop until valid
        while (~in.Valid) && (etime(clock, startTime) < timeOut)
            in = NXT_GetInputValues(f_sensorport, handle);
        end%while
        % check if everything is ok now...
        if ~in.Valid
            warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidData', ...
                   ['Returned sensor data marked invalid! ' ...
                    'Make sure the sensor is properly connected and configured to a supported mode. ' ...
                    'Disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:invalidData'')']);
        end%if
    end%if
        
%% Do threshold decision
    % 511 should be ok, being right in the middle between both "peaks"
    if in.NormalizedADVal > 511
        % note how this val is "inverted"...
        out = false;
    else
        out = true;
    end%if

end    
    