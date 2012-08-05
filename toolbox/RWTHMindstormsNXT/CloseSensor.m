function CloseSensor(port, varargin)
% Closes a sensor port (e.g. turns off active light of the light sensor)
%
% Syntax
%   CloseSensor(port)
%
%   CloseSensor(port, handle)
%
% Description
%   CloseSensor(port) closes the sensor port opened by the Open... functions. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick. Closing the light sensor deactives the active light
%   mode (the red light is turned off), closing the Ultrasonic sensor stops sending out ultrasound.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Examples
%   OpenLight(SENSOR_3, 'ACTIVE');
%   light = GetLight(SENSOR_3);
%   CloseSensor(SENSOR_3);
%
% See also: NXT_SetInputMode, OpenLight, OpenSound, OpenSwitch, OpenUltrasonic, SENSOR_1, SENSOR_2,
% SENSOR_3, SENSOR_4
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
    % invalid sensorport will be catched by NXT_ function

    sensortype = 'NO_SENSOR'; % this is basically our "close" command...
    sensormode = 'RAWMODE'; % boolean

%% Call NXT_SetInputMode function       
    NXT_SetInputMode(port, sensortype, sensormode, 'dontreply', handle); 

end%function
