function [index r g b] = GetColor(port, mode, varargin)
% Reads the current value of the HiTechnic Color V1 or V2 sensor
%
% Syntax
%   [index r g b] = GetColor(port, mode)
%
%   [index r g b] = GetColor(port, mode, handle)
%
% Description
%   This function returns the color index and the RGB-values of the
%   HiTechnic Color sensor. There are two different hardware versions of the sensor. 
%
% * The old Color sensor V1 has a single weak LED which is always on once
%   connected. You can spot little red, green and blue lights behind the
%   milky lens. This sensor can be calibrated using the function
%   CalibrateColor. It has sometimes trouble getting accurate results.
%   You can use all values for mode. Try which one works best for you.
%
% * The new Color sensor V2 has a single bright white LED which is always flashing
%   once connected. The lens is relatively clear. This sensor gives great
%   accuary for most colors, even at some distance. Only mode = 0 is
%   supported. Other modes will return wrong values. The sensor works fine 
%   as it comes, it SHOULD NOT BE CALIBRATED.
%
%
%   The color index values roughly correspond to the following
%   table (when using modes 0 and 1):
%	    0 = black 
%	    1 = violet
%	    2 = purple
%	    3 = blue
%	    4 = green
%	    5 = lime
%	    6 = yellow
%	    7 = orange
%	    8 = red
%	    9 = crimson
%	    10 = magenta
%	    11 to 16 = pastels 
%	    17 = white
%
%   The RGB-Values will be returned depending on the mode parameter.
% * mode = 0 : RGB = the current detection level for the color components red, green and blue
%                  in an range of 0 to 255. Use this setting for color sensor V2
%
% * mode = 1 : RGB = the current relative detection level  for the color components red, green and blue
%                  in an range of 0 to 255. The highest value of red, green and blue is set to 255 and
%                  the other components are adjusted proportionally. Only
%                  V1.
% * mode = 2 : RGB = the analog signal levels for the three
%                  color components red, green and blue with an accurancy
%                  of 10 bit (0 to 1023). Only V1.
% * mode = 3 : RGB = the current relative detection level  for the color components red, green and blue
%                  in an range of 0 to 3. Only V1.
%
%   The color index (0..63) for mode 2 and mode 3 will return a 6 bit color index number, which encodes
%   red in bit 5 and 4, green in bit 3 and 2 and blue in bit 1 (?). 
%
%   The given port number specifies the connection port. The value port can be addressed by the
%   symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on
%   the NXT Brick. 
%
%   For more complex settings the function COM_ReadI2C can be used.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Limitations
%   It's by design that the white LED of the Color sensors cannot be turned
%   off by calling CloseSensor. It's always on when the sensor is
%   connected. The V2 hardware version of the sensor performs significantly
%   better than the V1 version.
%
% Example
%   OpenColor(SENSOR_4);
%   [index r g b] = GetColor(SENSOR_4, 0);
%   CloseSensor(SENSOR_4);
%
% See also: OpenColor, CalibrateColor, CloseSensor, OpenNXT2Color, GetNXT2Color, COM_ReadI2C
%
% Signature
%   Author: Rainer Schnitzler, Linus Atorf (see AUTHORS)
%   Date: 2010/09/16
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

    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    % initialize
    index = NaN;
    r = NaN;
    g = NaN;
    b = NaN;

    % see http://www.hitechnic.com for more register information
    % retrieve 14 bytes from device 0x02, register 0x42 - 0x4F 
    % in mode 0 only the first 4 bytes are needed
    lng = 14;
    if mode == 0
       lng = 4;
    end
    
    %waitUntilI2CReady(port, handle);
    data = COM_ReadI2C(port, lng, uint8(2), uint8(66), handle);

    if ~isempty(data)

       if mode == 0
          % 42h: Index 
          index = data(1); 
          % 43h-45h: RGB (0-255)
          r = data(2);
          g = data(3);
          b = data(4);
       else
          if mode == 2
             % 4Ch: color index number (6 bits)
             index = data(11);
             % 46h/47h 48h/49h 4Ah/4Bh: RGB (10-Bit) analog values MSB/LSB
             r = data(5)*256+data(6); 
             g = data(7)*256+data(8); 
             b = data(9)*256+data(10); 
          else
             if mode == 1
                % 42h: Index 
                index = data(1); 
                % 4Dh-4Fh: normalized RGB (0-255)
                r = data(12);
                g = data(13);
                b = data(14);
             else
                if mode == 3
                  % 4Ch: color index number (6 bits)
                  index = data(11);
                  x = index;
                  b = bitand(x,3); % Bit 0+1: blue;
                  x = bitshift(x,-2);
                  g = bitand(x,3); % Bit 2+3: green;
                  x = bitshift(x,-2);
                  r = bitand(x,3); % Bit 4+5: red;
                else
                  error('MATLAB:RWTHMindstormsNXT:illegalInputArgument', 'Mode has to be 0, 1, 2, or 3.');
                end
             end
          end
       end             
    end
    
    % convert to double so that users can use normal operators without
    % confusion
    index = double(index);
    r = double(r);
    g = double(g);
    b = double(b);

end%function
