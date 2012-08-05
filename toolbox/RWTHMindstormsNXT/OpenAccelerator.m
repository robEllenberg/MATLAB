function OpenAccelerator(port, varargin)
% Initializes the HiTechnic acceleration sensor, sets correct sensor mode
%
% Syntax
%   OpenAccelerator(port)
%
%   OpenAccelerator(port, handle)
%
% Description
%   OpenAccelerator(port) initializes the input mode of NXT accelerator sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Examples
%   OpenAccelerator(SENSOR_4);
%   acc_Vector = GetAccelerator(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: GetAccelerator, CloseSensor, COM_ReadI2C, NXT_LSGetStatus, NXT_LSRead
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/09/25
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
    
    NXT_SetInputMode(port, 'LOWSPEED_9V', 'RAWMODE', 'dontreply', handle);
    pause(0.1); % let sensor "power up"...
    
% %% Build hex command and send it with NXT_LSWrite   
%     %----------------------------------------------------------------------
%     % (see LEGO Mindstorms NXT Ultrasonic Sensor - I2C Communication Protocol)
%     
%     RequestLen = 0; % -> No reply expected
% 
%     I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
%     I2Cdata(2) = hex2dec('41'); % STATE_COMMAND
%     I2Cdata(3) = hex2dec('02'); % CONTINUOUS_MEASUREMENT
% 
%     NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply');
%     
    %--------------------------------------------------------------------
    
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
end
