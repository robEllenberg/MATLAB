function OpenRFID(port, varargin)
% Initializes the Codatex RFID sensor, sets correct sensor mode
%
% Syntax
%   status = OpenRFID(port)
%
% Description
%   OpenRFID(port) initializes the input mode of Codatex RFID sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   The RF ID Sensor works with 125 kHz transponders compatible with EM4102
%   modulation type. With this sensor you can read 5-byte-long transponder numbers into the NXT.
%   Since the NXT RFID sensor is a digital sensor (that uses the I²C protocol),
%   the function NXT_SetInputMode cannot be used as for analog sensors.
%
% Note:
%    Opening the sensor can take a while. Via Bluetooth, delays of more
%    than 1 second are not uncommon.
%
% Example
%   OpenRFID(SENSOR_2);
%   transID = GetRFID(SENSOR_2,'single');
%   CloseSensor(SENSOR_2);
%
% See also: GetRFID, CloseSensor
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
    
%% Set sensor mode    
    NXT_SetInputMode(port, 'LOWSPEED_9V', 'RAWMODE', 'dontreply', handle);

    
%% Flushing data memory (unkown procedure)
    % the following command sequence is not clearly documented but was
    % found to work well!
	NXT_LSGetStatus(port, handle); % flush out data with Poll
    % we request the status-byte so that it doesn't get checked.
    % errors that can occur here are:
    %Packet (reply to LSREAD) contains error message 221: "Communication bus error"
    %Packet (reply to LSREAD) contains error message 224: "Specified
    %channel/connection not configured or busy"
	[a b c] = NXT_LSRead(port, handle);      % flush out data with Poll?

    
%% Boot the sensor
    % request nothing, send data 0x81 (BOOT) to register 0x41 (COMMAND)
    I2Cdata = hex2dec(['04'; '41'; '81']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);    
    
    waitUntilI2CReady(port, handle)
    
    
% %% Start the sensor
%     % request nothing, send data 0x83 (START) to register 0x41 (COMMAND)
%     I2Cdata = hex2dec(['04'; '41'; '83']);
%     NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);        
%     
%     %waitUntilI2CReady(port, handle)
%     
%     
% %% Wake up sensor by dummy call...
%     waitUntilI2CReady(port, handle)
%     % request nothing, send data 0x00 to 0x00
%     I2Cdata = hex2dec(['04'; '00'; '00']);
%     NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);



end%function

