function USMakeSnapshot(port, varargin)
% Causes the ultrasonic sensor to send one snapshot ("ping") and record the echos
%
% Syntax
%   USMakeSnapshot(port)
%
%   USMakeSnapshot(port, handle)
%
% Description
%   Call USMakeSnapshot(port) to make the specific ultrasonic sensor
%   connected to port send out one single signal (called "ping"). In
%   contrast to the US sensor's continous mode (that is invoked by a normal
%   OpenUltrasonic without the 'snapshot' parameter), the sensor will
%   only send out ultrasonic signals when this function is called. Up to 8
%   multiple echos will be recorded, and the according distances stored in
%   the sensor's internal memory. Use USGetSnapshotResults to retrieve
%   those 8 readings in one step!
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   *Note:* When the US sensor is opened in snapshot mode, the function
%   GetUltrasonic does not work correctly!
%
% Example
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
% % You should also try the file Example_4_NextGenerationUltrasound.m
% % from the demos-folder
%
% See also: OpenUltrasonic, GetUltrasonic, USGetSnapshotResults, CloseSensor
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2008/01/08
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



%% Build hex command and send it with NXT_LSWrite   
    %----------------------------------------------------------------------
    % (see LEGO Mindstorms NXT Ultrasonic Sensor - I2C Communication Protocol)
        
   
    RequestLen = 0; % -> No reply expected

    I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
    I2Cdata(2) = hex2dec('41'); % STATE_COMMAND
    I2Cdata(3) = hex2dec('01'); % SINGLE_SHOT

    NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply', handle);

    
    %--------------------------------------------------------------------
    

end    
    

