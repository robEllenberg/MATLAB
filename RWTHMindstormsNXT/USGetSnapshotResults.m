function snaps = USGetSnapshotResults(port, varargin)
% Retrieves up to eight echos (distances) stored inside the US sensor
%
% Syntax
%   echos = USGetSnapshotResults(port)
%
%   echos = USGetSnapshotResults(port, handle)
%
% Description
%   echos = USGetSnapshotResults(port) retrieves the echos originating
%   from the ping that was sent out with USMakeSnapshot(port) for the ultrasonic 
%   sensor connected to port. In order for this to work, the sensor must
%   have been opened in snapshot mode using OpenUltrasonic(port, 'snapshot').
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   The return-vector echos always contains exactly 8 readings for up to 
%   8 echos that were recorded from one single signal. Depending on the 
%   structure and reflections, this can only be one valid echo, or a lot of
%   interference. The values are distances, just as you'd expect from
%   GetUltrasonic. The values are sorted in order of appearance, so they
%   should also be sorted with increasing distances.
%
%   It is not known how exactly the measurements are to be interpreted!
%
%   Please make sure that after calling USGetSnapshotResults, there is a
%   little time period for the sound waves to travel, to be reflected, and
%   be recorded by the sensor. You can estimate this using the speed of
%   sound and the maximum distance you expect to measure.
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
% See also: OpenUltrasonic, GetUltrasonic, USMakeSnapshot, CloseSensor
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


    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if
    
    % check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    snaps = ones(8, 1) * -1; % initialize 8 results
    
    % old command:
    %I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
    %I2Cdata(2) = hex2dec('42'); % READ!
    %NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply');

    % retrieve 8 bytes from device 0x02, register 0x42
    data = COM_ReadI2C(port, 8, uint8(2), uint8(66), handle);
    
    if ~isempty(data)
        % important to convert to double!!!
        snaps = double(data);
    end%if
    
    
end    
    


