function OpenSwitch(port, varargin)
% Initializes the NXT touch sensor, sets correct sensor mode
%
% Syntax
%   OpenSwitch(port)
%
%   OpenSwitch(port, handle)
%
% Description
%   OpenSound(port) initializes the input mode of NXT switch / touch sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   For more complex settings the function NXT_SetInputMode can be used.
%
% Example
%   OpenSwitch(SENSOR_4);
%   switchState = GetSwitch(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: NXT_SetInputMode, GetSwitch, CloseSensor, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
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


% We're using RAWMODE here, because BOOLEAN mode would be nice, but isn't
% really necessary. We can use the .NormalizedADVal from GetInputValues, as
% we ALLWAYS have this variable. If we were to use BOOLEAN mode, and then
% use the .ScaledVal (what we had to do in this case because that is where
% the BOOLEAN mode val is effectively stored), we'd take away ourselves the
% possibility to use PERIODCNTMODE later on to detect "taps" or something
% else. 
% Also RAWMODE seems to react quicker than other modes (in terms of how
% long / how many packets still have .Valid set to false after
% SetInputMode).
%


%% check parameters

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


%% Set correct variables
    % invalid sensorport will be catched by NXT_ functions
    
    sensortype = 'SWITCH';  % switch sensor
    sensormode = 'RAWMODE'; % see above why we use raw...

%% Call NXT_SetInputMode function   
    NXT_SetInputMode(port, sensortype, sensormode, 'dontreply', handle); 
    
end%function    
    