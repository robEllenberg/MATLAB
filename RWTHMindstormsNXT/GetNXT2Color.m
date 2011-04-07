function out = GetNXT2Color( f_sensorport, varargin )
%  Reads the current value of the color sensor from the NXT 2.0 set
%
% Syntax
%   out = GetNXT2Color(port)
%
%   out = GetNXT2Color(port, handle)
%
% Description
%   This functions retrieves the current value of the LEGO NXT 2.0 Color sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%   This function is intended for the Color sensor that comes with the NXT 2.0
%   set. It has the label "RGB" written on the front, 3 LED openings (1 black
%   empty spot, the light sensor and a clear lens with tiny red, green, blue LEDs behind it).
%   It is not to be confused with the HiTechnic Color sensors (V1 and V2),
%   for those please see the functions OpenColor and GetColor.
%
%   The sensor has to be opened with OpenNXT2Color() before this function
%   can be used.
%   
%   Depending on the mode the color sensor was opened in,
%   the return value of this function can have one of the following two
%   formats
% * *In full color mode* (sensor was opened with mode = 'FULL'), the return
%   value will consist of one of the following strings:
%   'BLACK', 'BLUE', 'GREEN', 'YELLOW', 'RED', 'WHITE'. If an
%   error occured, the return value may be 'UNKNOWN' (unlikely though).
% * *In all other modes*, i.e. 'RED', 'GREEN', 'BLUE', 'NONE', the
%   returned value will be an integer between 0 and 1023, indicating the
%   amount of reflected / detected light. This is very similar to the
%   behaviour of GetLight.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%
% Limitations
%   The sensor is influenced by ambient light. It reacts differently on
%   daylight than on artificial light. The modes 'RED' and 'NONE' are
%   similar to the Light sensor's modes 'ACTIVE' and 'INACTIVE', but the
%   sensors are not perfectly compatible.
% 
%
% Examples
%  port = SENSOR_1;
%  OpenNXT2Color(port, 'FULL');
%  color = GetNXT2Color(port);
%  if strcmp(color, 'BLUE')
%      disp('Blue like the ocean');
%  else
%      disp(['The detected color is ' color]);
%  end%if
%  CloseSensor(port);
%
%  port = SENSOR_2;
%  OpenNXT2Color(port, 'NONE');
%  colorVal = GetNXT2Color(port);
%  if colorVal > 700
%      disp('It''s quite bright!')
%  end%if
%  CloseSensor(port);
%
% See also: OpentNXT2Color, CloseSensor, OpenColor, GetColor, OpenLight, GetLight, COM_ReadI2C
%
% Signature
%   Author: Nick Watts, Linus Atorf (see AUTHORS)
%   Date: 2010/09/21
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


%% check parameters

    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
  
%% call NXT_GetInputValues
  
    in = NXT_GetInputValues( f_sensorport, handle );
    
%% check for valid data, re-request if necessary
    % init timeout-counter
    startTime = clock();
    timeOut = 0.5; % in seconds
    % loop until valid
    while (~in.Valid) && (etime(clock, startTime) < timeOut)
        in = NXT_GetInputValues(f_sensorport, handle);
    end%while
    
    % nice check, we could've actually done that everwhere else...
    if strcmp(in.TypeName,'NO_SENSOR')
        error('MATLAB:RWTHMindstormsNXT:Sensor:noSensorOpened', 'No sensor configured / opened for this port')
    end%if
    
    
    % check if everything is ok now...
    if ~in.Valid
        warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidData', ...
               ['Returned sensor data marked invalid! ' ...
                'Make sure the sensor is properly connected and configured to a supported mode. ' ...
                'Disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:invalidData'')']);
    end%if
    

    
%% format output
    % for a list of values see here:
    % http://bricxcc.sourceforge.net/nbc/nxcdoc/nxcapi/group___input_color_value_constants.html
    if in.TypeByte == 13 %strcmp(in.TypeName, 'COLORFULL')
        colors = {'BLACK';'BLUE';'GREEN';'YELLOW';'RED';'WHITE'};
        try
            out = colors{ in.ScaledVal };
        catch
            out = 'UNKNOWN';
        end%try
    else
        % after various tests it was decided to do the same as for the
        % light sensor:
        out = double(in.NormalizedADVal);
    end%if

end%function

