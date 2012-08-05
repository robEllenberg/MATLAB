function [] = OpenUltrasonic(port, varargin)
% Initializes the NXT ultrasonic sensor, sets correct sensor mode
%
% Syntax
%   OpenUltrasonic(port)
%
%   OpenUltrasonic(port, mode)
%
%   OpenUltrasonic(port, mode, handle)
%
% Description
%   OpenUltrasonic(port) initializes the input mode of NXT ultrasonic sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   OpenUltrasonic(port, mode) can enable the snapshot mode if the value mode is equal to the string
%   'snapshot'. This mode provides the snap shot mode (or SINGLE_SHOT mode) of the NXT ultrasonic sensor,
%   which provides several sensor readings in one step. See
%   USMakeSnapshot for more information.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
% 
%   Since the NXT ultrasonic sensor is a digital sensor (that uses the I²C protocol),
%   the function NXT_SetInputMode cannot be used as for analog sensors.
%
% Note:
%
%   When the US sensor is opened in snapshot mode, the function
%   GetUltrasonic does not work correctly!
%
% Limitations
%   Since the Ultrasonic sensors all operate at the same frequency,
%   multiple US sensors will interfere with each other! If multiple US
%   sensors can "see each other" (or their echos and reflections),
%   results will be unpredictable (and probably also unusable). You can
%   avoid this problem by turning off US sensors, or operating them in
%   snapshot mode (see also USMakeSnapshot and USGetSnapshotResults).
%
%
% Examples
%   OpenUltrasonic(SENSOR_4);
%   distance = GetUltrasonic(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
%  port = SENSOR_4;
%  OpenUltrasonic(port, 'snapshot');
%  % send out the ping
%  USMakeSnapshot(port);
%  % wait some time for the sound to travel
%  pause(0.1); % 100ms is probably too much, calculate using c_sound ;-)
%  % retrieve all the echos in 1 step
%  echos = USGetSnapshotResults(port);
%  CloseSensor(SENSOR_4);
%
% See also: GetUltrasonic, USMakeSnapshot, USGetSnapshotResults, CloseSensor
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2008/01/08
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
    if nargin > 2
        handle = varargin{2};
    else
        handle = COM_GetDefaultNXT;
    end%if

    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if

    
    SnapshotMode = false;
    if nargin > 1
        if ischar(varargin{1}) && strcmpi(varargin{1}, 'snapshot')
            SnapshotMode = true;                
        end%if
    end%if
    
    
    NXT_SetInputMode(port, 'LOWSPEED_9V', 'RAWMODE', 'dontreply', handle);
    pause(0.05); % let sensor "power up"...

%% Build hex command and send it with NXT_LSWrite   
    %----------------------------------------------------------------------
    % (see LEGO Mindstorms NXT Ultrasonic Sensor - I2C Communication Protocol)
        
    
    if SnapshotMode
        
        RequestLen = 0; % -> No reply expected
                
        I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
        I2Cdata(2) = hex2dec('41'); % STATE_COMMAND
        I2Cdata(3) = hex2dec('01'); % SINGLE_SHOT
        
        NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply', handle);
        
    else
        
        RequestLen = 0; % -> No reply expected
                
        I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
        I2Cdata(2) = hex2dec('41'); % STATE_COMMAND
        I2Cdata(3) = hex2dec('02'); % CONTINUOUS_MEASUREMENT
        
        NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply', handle);
    end%if
    

    
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

end%function
    


