function status = NXT_SetInputMode(InputPort, SensorTypeDesc, SensorModeDesc, ReplyMode, varargin)
% Sets a sensor mode, configures and initializes a sensor to be read out
%  
% Syntax
%   status = NXT_SetInputMode(port, SensorTypeDesc, SensorModeDesc, ReplyMode) 
%
%   status = NXT_SetInputMode(port, SensorTypeDesc, SensorModeDesc, ReplyMode, handle)
%
% Description
%   status = NXT_SetInputMode(InputPort, SensorTypeDesc, SensorModeDesc, ReplyMode) sets mode,
%   configures and initializes the given sensor port to be ready to be read out. The value port
%   can be addressed by the symbolic constants SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4
%   analog to the labeling on the NXT Brick. The value SensorTypeDesc determines the sensor type.
%   See all valid types below. SensorModeDesc represents the sensor mode. It specifies what mode
%   the .ScaledVal from NXT_GetInputValues should be. Valid parameters see below. By the
%   ReplyMode one can request an acknowledgement for the packet transmission. The two strings
%   'reply' and 'dontreply' are valid. The return value status indicates if an error occures
%   by the packet transmission.
%
%   status = NXT_SetInputMode(InputPort, SensorTypeDesc, SensorModeDesc, ReplyMode, handle)
%   uses the given NXT connection handle. This should be a struct containing a serial handle on a PC system and
%   a file handle on a Linux system.
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% Input:
%   *SensorTypeDesc:*  Valid types are (all strings):
%
%                      NO_SENSOR       (nothing, use to close sensor port)
%
%                      SWITCH          (NXT touch sensor, "binary")
%
%                      LIGHT_ACTIVE    (NXT light sensor, red LED is on)
%
%                      LIGHT_INACTIVE  (NXT light sensor, red LED is off)
%
%                      SOUND_DB        (NXT sound sensor, unit dB)
%
%                      SOUND_DBA       (NXT sound sensor, unit dBA)
%
%                      LOWSPEED        (NXT, passive digital sensor)
%
%                      LOWSPEED_9V     (NXT, active digital sensor, e.g. UltraSonic)
%
%                      HIGHSPEED       (NXT, probably digital sensor on highspeed port 4)
%
%                      TEMPERATURE     (old RCX sensor)
%
%                      REFLECTION      (old RCX sensor)
%
%                      ANGLE           (old RCX sensor)
%
%                      COLORFULL       (NXT 2.0 Color sensor, full RGB mode)
%
%                      COLORRED        (NXT 2.0 Color sensor, red LED only)
%
%                      COLORGREEN      (NXT 2.0 Color sensor, green LED only)
%
%                      COLORBLUE       (NXT 2.0 Color sensor, blue LED only)
%
%                      COLORNONE       (NXT 2.0 Color sensor, no LED)
%
%
%   *SensorModeDesc:*  Valid modes are (all strings):
%
%                      RAWMODE            (Fastest. RawADVal will be used)
%
%                      BOOLEANMODE        (1 if above 45% threshold, else 0)
%
%                      TRANSITIONCNTMODE  (count transitions of booleanmode)
%
%                      PERIODCOUNTERMODE  (count periods (up and down
%                                           transition) of boolean mode)
%
%                      PCTFULLSCALEMODE   (normalized percentage between 0
%                                            and 100, use .NormalizedADVal
%                                            instead!)
%
%
%                      More exotic modes are:
%                      CELSIUSMODE        (RCX temperature only)
%
%                      FAHRENHEITMODE     (RCX temperature only)
%
%                      ANGLESTEPSMODE     (RCX rotation only)
%
%                      SLOPEMASK          (what's this???)
%
%                      MODEMASK           (what's this???)
%
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   status = NXT_SetInputMode(SENSOR_1, 'SOUND_DB', 'RAWMODE', 'dontreply');
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   status = NXT_SetInputMode(SENSOR_3, 'LIGHT_ACTIVE', 'RAWMODE', 'dontreply', handle);
%
% See also: NXT_GetInputValues, OpenLight, OpenSound, OpenSwitch, OpenUltrasonic, CloseSensor, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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

%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin > 4
    handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if

% check if port number is valid
if InputPort < 0 || InputPort > 3 
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort %d invalid! It has to be 0, 1, 2 or 3', InputPort);
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('SETINPUTMODE');

SensorTypeByte = sensortype2byte(SensorTypeDesc);
SensorModeByte = sensormode2byte(SensorModeDesc);

content = [InputPort; SensorTypeByte; SensorModeByte];


%% Packet bluetooth command
packet = COM_CreatePacket(type, cmd, ReplyMode, content);


%% Send bluetooth packet
COM_SendPacket(packet, handle);


%% Receive status packet if reply mode is used
if strcmpi(ReplyMode, 'reply')
    [type cmd status content] = COM_CollectPacket(handle);
else
    status = 0; %ok
end%if

end%function

