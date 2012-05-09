function OpenNXT2Color(port, mode, varargin)
% Initializes the LEGO color sensor from the NXT 2.0 set, sets correct sensor mode 
%
% Syntax
%   OpenNXT2Color(port, mode)
%
%   OpenNXT2Color(port, mode, handle)
%
% Description
%   This function initializes the input mode of the LEGO NXT 2.0 Color sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%   This function is intended for the Color sensor that comes with the NXT 2.0
%   set. It has the label "RGB" written on the front, 3 LED openings (1 black
%   empty spot, the light sensor and a clear lens with tiny red, green, blue LEDs behind it).
%   It is not to be confused with the HiTechnic Color sensors (V1 and V2),
%   for those please see the functions OpenColor and GetColor.
%
%   With GetNXT2Color(port) you can receive the detected brightness or color.
%   
%   mode specifies the operating mode of the sensor, the following values
%   are allowed:
% * 'FULL' - The red, green, and blue LEDs are constantly on (actually
%   flashing at a high frequency), and the sensor will try to detect one of
%   6 predefined colors.
% * 'RED' - The red LED is constantly on, the sensor outputs reflected
%   light / brightness. This is similar to the LEGO Light sensor mode
%   'ACTIVE'. See OpenLight.
% * 'GREEN' - The green LED is constantly on, the sensor outputs reflected
%   light / brightness.
% * 'BLUE' - The blue LED is constantly on, the sensor outputs reflected
%   light / brightness.
% * 'NONE' - All LEDs are constantly off, the sensor outputs ambient
%   light / brightness. This is similar to the LEGO Light sensor mode
%   'INACTIVE'. See OpenLight.
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
% See also: GetNXT2Color, CloseSensor, OpenColor, GetColor, OpenLight, GetLight, COM_ReadI2C
%
% Signature
%   Author: Nick Watts, Linus Atorf (see AUTHORS)
%   Date: 2010/09/21
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


%% check parameters

    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if

%% check and set mode

    sensormode = 'RAWMODE';
    if strcmpi(mode, 'RED')
        sensortype = 'COLORRED';
    elseif strcmpi(mode, 'GREEN')
        sensortype = 'COLORGREEN';
    elseif strcmpi(mode, 'BLUE')
        sensortype = 'COLORBLUE';
    elseif strcmpi(mode, 'FULL')
        sensortype = 'COLORFULL';
    elseif strcmpi(mode, 'NONE')
        sensortype = 'COLORNONE';
    else
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'NXT 2.0 Color sensor mode has to be ''FULL'', ''RED'', ''GREEN'', ''BLUE'', or ''NONE''');
    end%if
  
%% call NXT_SetInputMode function

    NXT_SetInputMode( port, sensortype, sensormode, 'dontreply', handle );
  
    % it was measured the NXT 2.0 color sensor takes about 170ms until
    % values turn valid. The LEDs light up a tiny moment earlier...
    % in here we wait the biggest amount of time:
    pause(0.130);
    % the rest will be waited inside GetNXT2Color dynamically as needed
    
    
end%function

