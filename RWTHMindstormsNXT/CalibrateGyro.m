function offset = CalibrateGyro(port, calibrationMode, varargin)
% Calibrates the HiTechnic Gyro sensor (measures/sets an offset while in rest)
%
% Syntax
%   offset = CalibrateGyro(port, 'AUTO')
%
%   offset = CalibrateGyro(port, 'AUTO', handle)
%
%   offset = CalibrateGyro(port, 'MANUAL', manualOffset)
%
%   offset = CalibrateGyro(port, 'MANUAL', manualOffset, handle)
%
% Description
%   In order to use the HiTechnic Gyro Sensor, it has first to be opened
%   using OpenGyro. Then CalibrateGyro should be called (or a warning
%   will be issued). Only after this you can safely use GetGyro to
%   retrieve values.
%
%   This function will set (and return) the new offset (i.e. reading during
%   rest) of the according Gyro sensor. Normally users should use the
%   *automatic* calibration mode: offset = CalibrateGyro(port, 'AUTO')
%
%   The offset will be calculated automatically. During this function the Gyro sensor
%   value will be measured for at least 1 second (or for at least 5 times). During this
%   period, the sensor must be at full rest!
%
%   If you want to save time during your program with a well-known Gyro
%   sensor, or you cannot assure that the sensor is at rest during
%   calibration, you can use the automatic calibration once in the command
%   line and remember the determined offset value. Using manual
%   calibration, you can then set a hardcoded value manually (saving you
%   time and the calibration for this sensor in the future in that specific
%   program).
%    
%   Use CalibrateGyro(port, 'MANUAL', manualOffset) to achieve this, with
%   a correct offset obtained from automatic calibration. This call won't
%   require that the sensor doesn't move. Also the call is very fast (as
%   compared to at least 1 second in automatic mode). Use integers for
%   manualOffset, as the gyro sensor is only accurate to +/- 1 degree per
%   second anyway.
%   
%   The last optional argument (for both modes) can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Note:
%   Manual calibration only works for one specific sensor (i.e. one unique
%   piece of hardware). Other sensors might have different offsets. Also it
%   could be possible that the offset changes over time or is dependent on
%   your working environment (humidity, temperature, etc).
%
% Limitations
%   Calibration is stored inside the NXT handle, for a specific port. This
%   means after closing the NXT handle, or when connecting the sensor to
%   another port, calibration is lost. That is why you should either always
%   run the calibration at the begin of your program, or restore the
%   previous offset with the 'MANUAL' calibration mode.
%
% Examples
%   % in this example the gyro is used with automatic
%   % calibration, very straight forward
%
%   port = SENSOR_2;
%   OpenGyro(port);
%   CalibrateGyro(port, 'AUTO');
%
%   % now the gyro is ready to be used!
%   % do something, main program etc...
%   speed = GetGyro(port);
%
%   % do something else, loop etc...
%   % don't forget to clean up
%   CloseSensor(port);
%
%   % in this example we save the time and effort of
%   % automatic calibration each time the main program is run...
%   % on a command window, type:
%   h = COM_OpenNXT();
%   COM_SetDefaulNXT(h);
%   OpenGyro(SENSOR_1);
%   % now, once the automatic calibration:
%   offset = CalibrateGyro(SENSOR_1, 'AUTO');
%   % remember this value...
%
%   % our main program looks like this:
%   % always open gyro first:
%   OpenGyro(SENSOR_1);
%   % now use the offset value determined earlier:
%   CalibrateGyro(SENSOR_1, 'MANUAL', offset);
%   % ready to use GetGyro now...
%
% See also: OpenGyro, GetGyro, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/04/14
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


%% Settings
minCalibrationTime = 2; % in seconds
minCalibrationPasses = 20; % how many times at least


%% Parameter check
    
    % valid mode?
    if ~strcmpi(calibrationMode, 'AUTO') && ~strcmpi(calibrationMode, 'MANUAL')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Calibration mode for HiTechnic Gyro sensor has to be either ''AUTO'' or ''MANUAL''');
    end%if

    % determine WHICH mode
    autoCalibration = false;
    if strcmpi(calibrationMode, 'AUTO')
        autoCalibration = true;
    end%if
    
%% Assign parameters, get handle
    % check depending on mode, if last argument is handle
    if autoCalibration 
        if nargin > 2
            handle = varargin{1};
        else
            handle = COM_GetDefaultNXT;
        end%if
    else
        if nargin > 3
            handle = varargin{2};
        else
            handle = COM_GetDefaultNXT;
        end%if
        if nargin == 2 || ~isnumeric(varargin{1})
            error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'With manual calibration mode for Gyro sensor, a valid offset must be specified as argument after ''MANUAL''!');
        end%if
        manualOffset = double(varargin{1});
    end%if


    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if


%% Actual (automatic) calibration

    if autoCalibration
        
        % wait until values get valid...
        in = NXT_GetInputValues(port, handle); 
        invalidCount = 0;
        ticHandle = tic;
        while((~in.Valid) && (toc(ticHandle) < 1))
            in = NXT_GetInputValues(port, handle);
            invalidCount = invalidCount + 1;
        end%while
              
            
        
        % wait another bit. we do so to ensure the sensor values are valid (if
        % OpenGyro was called just before...)
        % this is easier, so we can ignore the .Valid flag in the
        % calibration loop later down...
        pause(0.05);
             
        j = 0;
        startTime = clock();
        tmpSum = 0;
        while(true)
            % ensure a minimum time and a minimum count of sensor values
            if (etime(clock(), startTime) >= minCalibrationTime) && (j >= minCalibrationPasses)
                break
            end%if
            
            j = j + 1;
            %NOTE we do not care if the values in here are valid...
            % we only add up...
            
            in = NXT_GetInputValues(port, handle);                                     
            tmpSum = tmpSum + double(in.RawADVal);           
             
        end%while
        
          
        % calc  average
        if j > 0
            newOffset = (tmpSum / j);
        else % avoid div by 0
            % apparently something went very wrong, no measurement
            % happened... probably never going to happen.
            % we retrieve the default/current value and set it back
            newOffset = handle.GyroSensorOffset(port);
        end%if
                     
        
        % and set
        handle.GyroSensorOffset(port, newOffset);
        
        % return value
        offset = newOffset;
        
    else        
%% manual "calibration"

        handle.GyroSensorOffset(port, manualOffset);
        % just replicate for return value:
        offset = manualOffset;
        
    end%if
end%function
