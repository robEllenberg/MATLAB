function map = MAP_GetInputModule(port)
% Reads the IO map of the input module
%  
% Syntax
%   map = MAP_GetInputModule(port)
%
% Description
%   map = MAP_GetInputModule(port) returns the IO map of the input module at the given sensor
%   port. The sensor port can be addressed by SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%   and 'all'. The return value map is a struct variable or cell array ('all' mode).
%   It contains all input module information.  
%
% Output:
%     map.CustomZeroOffset   % custom sensor zero offset value of a sensor.
%
%     map.ADRaw              % raw 10-bit value last read from the ananlog to digital converter. Raw
%                                values produced by sensors typically cover some subset of the
%                                full 10-bit range. 
%
%     map.SensorRaw          % raw sensor value
%
%     map.SensorValue        % tacho/angle limit, 0 means none set
%
%     map.SensorType         % sensor value
%
%     map.SensorMode         % sensor mode
%
%     map.SensorBoolean      % boolean sensor value
%
%     map.DigiPinsDir        % digital pins direction value of a sensor
%
%     map.DigiPinsIn         % digital pins status value of a sensor ?
%
%     map.DigiPinsOut        % digital pins output level value of a sensor
%
%     map.CustomPctFullScale % custom sensor percent full scale value of the sensor.
%
%     map.CustomActiveStatus % custom sensor active status value of the sensor
%
%     map.InvalidData        % value of the InvalidData flag of the sensor
%
%
% Examples
%   map = MAP_GetInputModule(SENSOR_2);
%
%   map = MAP_GetInputModule('all');
%
% See also: NXT_ReadIOMap
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/23
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

% Information provided by
% Not eXactly C (NXC) Programmer's Guide 
% Version 1.0.1 b33, October 10, 2007
% by John Hansen
% http://bricxcc.sourceforge.net/nbc/nxcdoc/NXC_Guide.pdf
% - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Input Module Offsets              Value        Size
% InputOffsetCustomZeroOffset(p)   (((p)*20)+0)  2
% InputOffsetADRaw(p)              (((p)*20)+2)  2
% InputOffsetSensorRaw(p)          (((p)*20)+4)  2
% InputOffsetSensorValue(p)        (((p)*20)+6)  2
% InputOffsetSensorType(p)         (((p)*20)+8)  1
% InputOffsetSensorMode(p)         (((p)*20)+9)  1
% InputOffsetSensorBoolean(p)      (((p)*20)+10) 1
% InputOffsetDigiPinsDir(p)        (((p)*20)+11) 1
% InputOffsetDigiPinsIn(p)         (((p)*20)+12) 1
% InputOffsetDigiPinsOut(p)        (((p)*20)+13) 1
% InputOffsetCustomPctFullScale(p) (((p)*20)+14) 1
% InputOffsetCustomActiveStatus(p) (((p)*20)+15) 1
% InputOffsetInvalidData(p)        (((p)*20)+16) 1


%% Parameter check
% interpret and check sensor parameter
if ischar(port)
    if strcmpi(port, 'all')
        port = 255;
    else
        port = str2double(port);
    end%if
end%if

if (port < 0 || port > 3) && (port ~= 255)
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'Input argument for sensor port must be 0, 1, 2, 3 or ''all''.');
end%if


%% Get Input Module Map
InputModuleID = 196609; %#ok<NASGU> %hex2dec('00030001');

% one sensor port
if port ~= 255
    
    % return values of specified senor port
    bytes = NXT_ReadIOMap(InputModuleID, port*20, 17);

    map.CustomZeroOffset    = wordbytes2dec(bytes(1:2), 2); %unsigned
    map.ADRaw               = wordbytes2dec(bytes(3:4), 2); %unsigned
    map.SensorRaw           = wordbytes2dec(bytes(5:6), 2); %unsigned
    map.SensorValue         = wordbytes2dec(bytes(7:8), 2); %unsigned
    map.SensorType          = byte2sensortype(bytes(9));
    map.SensorMode          = byte2sensormode(bytes(10));
    map.SensorBoolean       = bytes(11);
    map.DigiPinsDir         = bytes(12);
    map.DigiPinsIn          = bytes(13);
    map.DigiPinsOut         = bytes(14);
    map.CustomPctFullScale  = bytes(15);
    map.CustomActiveStatus  = bytes(16);
    map.InvalidData         = bytes(17);

else
    
    % return values of all four sensor ports
    bytes = NXT_ReadIOMap(InputModuleID, 0, 80);
    
    for i = 0:1:3
        map{i+1}.CustomZeroOffset    = wordbytes2dec(bytes(20*i+1:20*i+2), 2); %unsigned
        map{i+1}.ADRaw               = wordbytes2dec(bytes(20*i+3:20*i+4), 2); %unsigned
        map{i+1}.SensorRaw           = wordbytes2dec(bytes(20*i+5:20*i+6), 2); %unsigned
        map{i+1}.SensorValue         = wordbytes2dec(bytes(20*i+7:20*i+8), 2); %unsigned
        map{i+1}.SensorType          = byte2sensortype(bytes(20*i+9));
        map{i+1}.SensorMode          = byte2sensormode(bytes(20*i+10));
        map{i+1}.SensorBoolean       = bytes(20*i+11);
        map{i+1}.DigiPinsDir         = bytes(20*i+12);
        map{i+1}.DigiPinsIn          = bytes(20*i+13);
        map{i+1}.DigiPinsOut         = bytes(20*i+14);
        map{i+1}.CustomPctFullScale  = bytes(20*i+15);
        map{i+1}.CustomActiveStatus  = bytes(20*i+16);
        map{i+1}.InvalidData         = bytes(20*i+17);
    end
end

end