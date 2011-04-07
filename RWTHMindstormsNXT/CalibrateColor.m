function [] = CalibrateColor(port, mode, varargin)
% Enables calibration mode of the HiTechnic color sensor V1
%
% Syntax
%  CalibrateColor(port, mode)
%
%  CalibrateColor(port, mode, handle)
%
% Description
%   Do not use this function with the HiTechnic Color Sensor V2. It has a
%   bright white flashing LED.
%   This function is intended for the HiTechnic Color Sensor V1 (milky,
%   weak white LED).
%
%   Calibrate the color sensor with white and black reference value.
%   It's not known whether calibration of the color sensor makes sense.
%   HiTechnic doku says nothing, some people say it is necessary,
%   but it works and has effect ;-). The sensor LEDs make a short flash
%   after successful calibration. When calibrated, the sensor keeps this
%   information in non-volatile memory.
%   There are two different modes for calibration: 
% * mode = 1: white balance calibration
%          Puts the sensor into white balance calibration mode. For best results
%          the sensor should be pointed at a diffuse white surface at a distance
%          of approximately 15mm before calling this method. After a fraction of
%          a second the sensor lights will flash and the calibration is
%          done. 
% * mode = 2: black level calibration
%          Puts the sensor into black/ambient level calibration mode. For best
%          results the sensor should be pointed in a direction with no obstacles
%          for 50cm or so. This reading the sensor will use as a base level for
%          other readings. After a fraction of a second the sensor lights will
%          flash and the calibration is done. When calibrated, the sensor keeps
%          this information in non-volatile memory.
%
%   The color sensor has to be opened (using OpenColor) before execution.
% 
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4
%   analog to the labeling on the NXT Brick. 
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%     % color must be open for calibration
%     OpenColor(SENSOR_2);
%
%     % white calibration mode
%     CalibrateColor(SENSOR_2, 1);
%     % pause for changing position
%     pause(5);
%     % black calibration mode
%     CalibrateColor(SENSOR_2, 2);
%
% See also: OpenColor, GetColor, CloseSensor
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

%% Check Parameter
    if nargin < 2
        error('MATLAB:RWTHMindstormsNXT:notEnoughInputArguments', 'Two function parameters are required, port and white/black mode');
    end
    
    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
%% Check whether we're working with the right sensor
   
   % found registers by trial & error, since V1 spec wasn't online
   data = COM_ReadI2C(port, 8, 2, 16, handle);
   data = strtrim(char(data'));
   if ~strcmp(data, 'Color')
       % thats bad, not a color sensor V1
       if strcmp(data, 'ColorPD')
           error('MATLAB:RWTHMindstormsNXT:Sensor:colorCalibrationForV2', ...
                ['You''re trying to calibrate a HiTechnic Color V2 sensor. ' ...
                 'This is not necessary for the V2 sensor hardware, and clearly ' ...
                 'NOT RECOMMENDED if the sensor is working correctly. If you''re ' ...
                 'absolutely sure you want to call the calibration anyway (and maybe ' ...
                 'permanently deteriorate the sensor''s performance), ' ...
                 'you''ll find a way around this error.']);
       else
           error('MATLAB:RWTHMindstormsNXT:Sensor:colorCalibrationForUnknown', ...
                ['You''re trying to use color calibration for the HiTechnic ' ...
                 'Color sensor V1. It seems this sensor is not connected to ' ...
                 'the according port. Make sure sensor, hardware version (Color V1) ' ...
                 'and port match, then try again.']);
       end%if
   end%if
   

    
    
%% create this I2C command to start calibration
    if mode == 1
        waitUntilI2CReady(port, handle);
        I2Cdata = hex2dec(['02'; '41'; '43']); % Command (41): White calibration (43) 
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle); 
	elseif mode == 2
        waitUntilI2CReady(port, handle);
        I2Cdata = hex2dec(['02'; '41'; '42']); % Command (41): Black calibration (42) 
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle); 
    else
        error('MATLAB:RWTHMindstormsNXT:invalidInputArgument', 'Mode has to be 1 for white or 2 for black calibration');
    end
         
end%function
