function OpenLight(f_sensorport, f_mode, varargin)
% Initializes the NXT light sensor, sets correct sensor mode
%
% Syntax
%   OpenLight(port, mode)
%
%   OpenLight(port, mode, handle)
%
% Description
%   OpenLight(port, mode) initializes the input mode of NXT light sensor specified by the sensor
%   port and the light mode. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The
%   mode represents one of two modes 'ACTIVE' (active illumination: red light on) and 'INACTIVE'
%   (passive illumination red light off). To deactive the active illumination the function
%   CloseSensor is used.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   For more complex settings the function NXT_SetInputMode can be used.
%
% Example
%   OpenLight(SENSOR_1, 'ACTIVE');
%   light = GetLight(SENSOR_1);
%   CloseSensor(SENSOR_1);
%
% See also: CloseSensor, GetLight, OpenNXT2Color, GetNXT2Color, NXT_SetInputMode, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
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

%% Check Parameter
    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if

    if ~strcmpi(f_mode, 'ACTIVE') && ~strcmpi(f_mode, 'INACTIVE')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Light sensor mode has to be ''ACTIVE'' or ''INACTIVE''');
    end
    
    % also accept strings as input
    if ischar(f_sensorport)
        f_sensorport = str2double(f_sensorport);
    end%if

    % invalid sensorport will be catched by NXT_ function

%% Set correct variables    
    f_mode = upper(f_mode);
    sensortype = ['LIGHT_' f_mode]; % switch sensor
    sensormode = 'RAWMODE'; % raw Mode
    
%% Call NXT_SetInputMode function
    NXT_SetInputMode(f_sensorport, sensortype, sensormode, 'dontreply', handle); 

end%function
