function SwitchLamp(port, mode, varargin)
% Switches the LEGO lamp on or off (has to be connected to a motor port)
%
% Syntax
%   SwitchLamp(port, mode)
%
%   SwitchLamp(port, mode, handle)
%
% Description
%   SwitchLamp(port, mode) turns the LEGO lamp on or off. 
%   The given port number specifies the used motor port. The value port can be
%   addressed by the symbolic constants MOTOR_A , MOTOR_B and MOTOR_C analog to
%   the labeling on the NXT Brick. The value mode supports two modes 'on' and 'off' to turn
%   the lamp on and off.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%   This function simply sets power 100 to the specified motor port to turn
%   on the lamp, or sets power 0 to turn it off. Note that dimming is not
%   possible, even a power of just 1 will be enough to switch the lamp to
%   full brightness (after a short while).
%
%   A StopMotor command with parameter 'off' will also turn off the lamp, but it is
%   recommended to use this function when working with lamps for better readability.
%
% Examples
%   SwitchLamp(MOTOR_B, 'on');
%
%   SwitchLamp(MOTOR_A, 'off');
%
% See also: NXTMotor, StopMotor, MOTOR_A, MOTOR_B, MOTOR_C
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

%% Parameter check

% check if handle is given; if not use default one
if nargin > 2
    h = varargin{1};
else
    h = COM_GetDefaultNXT;
end%if

% also accept strings as port-number:
if ischar(port)
    % map 'all' to 255
    if strcmpi(port, 'all')
        port = 255;
    else
        port = str2double(port);
    end%if
end%if

% check if port number is correct
if (((port < 0) || (port > 2)) && (port ~= 255)) || isnan(port)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'MotorPort must be 0, 1, 2, or 255 for all motors');
end%if

% check if mode is correct
if strcmpi(mode, 'off')
    power = 0;
else
    if strcmpi(mode, 'on')
        power = 100;
    else
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidLampMode', 'Invalid argument. Use ''on'' or ''off''!');
    end
end


if power == 0 
    % basically turn electric power to motor off, COAST mode
    NXT_SetOutputState(port, ...
        0, ...      % power
        false, ...  % motoron
        false, ...  % brake
        'IDLE', ... % regulation
        0, ...      % turnratio
        'IDLE', ... % runstate
        0, ...      % tacho limit
        'dontreply', h); % replymode
else
    % just set full power to the port...
    NXT_SetOutputState(port,100,true,true,...
            'IDLE',0,'RUNNING',0,'dontreply', h);
end%if



end%function
