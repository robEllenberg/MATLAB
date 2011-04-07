function OpenSound(f_sensorport, f_mode, varargin)
% Initializes the NXT sound sensor, sets correct sensor mode
%
% Syntax
%   OpenSound(port, mode)
%
%   OpenSound(port, mode, handle)
%
% Description
%   OpenSound(port, mode) initializes the input mode of NXT sound sensor specified by the sensor
%   port and the sound mode. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The
%   mode represents one of two modes 'DB' (dB measurement) and 'DBA' (dBA measurement)
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   For more complex settings the function NXT_SetInputMode can be used.
%
% Examples
%   OpenSound(SENSOR_1, 'DB');
%   sound = GetSound(SENSOR_1);
%   CloseSensor(SENSOR_1);
%
% See also: NXT_SetInputMode, GetSound, CloseSensor, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2010/09/14
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

%% Check Parameter
    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    if ~strcmpi(f_mode, 'DB') && ~strcmpi(f_mode, 'DBA')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Sound sensor mode has to be ''DB'' or ''DBA''');
    end

    % also accept strings as input
    if ischar(f_sensorport)
        f_sensorport = str2double(f_sensorport);
    end%if
    
	% invalid sensorport will be catched by NXT_ function
    
%% Set correct variables
    f_mode = upper(f_mode);
    sensortype = ['SOUND_' f_mode]; % switch sensor
    sensormode = 'RAWMODE'; % raw Mode
    
%% Call NXT_SetInputMode function    
    NXT_SetInputMode(f_sensorport, sensortype, sensormode, 'dontreply', handle); 
    
    % NOTE: We know out of experience the sound sensor needs about 300ms until
    % the returned values turn valid. This will lead to GetSound waiting.
    % This in turn is uncool if somebody uses a loop to quickly collect all
    % sound values (thir first ones will be ~ 300ms apart). On the other
    % hand, if we wait here, the whole MATLAB user program blocks..
    % Then again, this is done for the Gyro sensor, since it definitely has
    % a documented bootup time. We'll make a trade off: Let's wait 200ms in
    % here, and the rest can happen during GetSound or whenever...
    pause(0.2);

end%function  
