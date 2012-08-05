function [transpID datahex] = GetRFID(port, varargin)
% Reads the transponder ID detected by the Codatex RFID sensor
%
% Syntax
%   transpID = GetRFID(port)
%
%   transpID = GetRFID(port, handle)
%
% Description
%   transpID = GetRFID(port) returns a 5-byte transponder ID (datatype is
%   uint64).
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Note:
%   The RFID-tag should be placed in a distance of about 1 to 3cm from the
%   RFID sensor. If the transponder was successfully detected, the orange
%   LED of the sensor will flash. Very rarely, when operating with multiple
%   ID tags close to each other, an ID might not be read correctly (in this
%   case it's usually easy to spot, as it looks very different from the
%   "usual" tag IDs).
%
%   Please also note that this function returns about 3 to 5 readings per
%   second when used with USB. Bia Bluetooth however, a single function call
%   can take as long as 1 second, depending on connection quality.
%
%
% Example
%   OpenRFID(SENSOR_2);
%   transID = GetRFID(SENSOR_2);
%   CloseSensor(SENSOR_2);
%
% See also: OpenRFID, CloseSensor
%
% Signature
%   Author: Linus Atorf, Rainer Schnitzler (see AUTHORS)
%   Date: 2008/12/1
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
 
% This code is based on
%
% - RFID library for NXC, Daniele Benedettelli
%   http://www.codatex.com/picture/upload/en/RFID_NXC_lib.zip
%
% - Using the Codatex RFID sensor, Ralph Hempel
%   http://www.hempeldesigngroup.com/lego/pbLua/tutorial/pbLuaRFIDSensor.html

%% Parameter check

    % check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if

%% Wake up sensor by dummy call...
    % request nothing, send data 0x00 to register 0x00
    I2Cdata = hex2dec(['04'; '00'; '00']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
    
    
%% Set sensor to poll  
    waitUntilI2CReady(port, handle);
    % register 0x41 = command, data 0x02 = POLL
    I2Cdata = hex2dec(['04'; '41'; '02']); 
 	NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
    
    
    
%% Check sensor status!
    waitUntilI2CReady(port, handle);
    % read 1 byte from 0x32 (a register called STATUS)
    status = COM_ReadI2C(port, 1, uint8(4), uint8(50), handle);
    
    if (status == 0)
        pause(0.25);
    end%if
    
    
    
%% Get sensor data
    waitUntilI2CReady(port, handle);
    % read 5 bytes from register 0x42
    data = COM_ReadI2C(port, 5, uint8(4), uint8(66));
    datahex = dec2hex(data);

    
    
%% Convert data to ID

    transpID = uint64(0);
    if length(data) > 4 
       transpID = typecast(uint8([flipud(data); 0; 0; 0]), 'uint64');
    % this warning is for debug purposes only...
%     else
%        warning('RFID didn''t work')
    end%if


%% Wait!

    pause(0.2)
    
    
end%function
