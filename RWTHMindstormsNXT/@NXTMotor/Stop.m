function Stop( obj , brakemode, handle)
% Stops or brakes specified motor(s)
%
% Syntax
%   OBJ.Stop()
%
%   OBJ.Stop(BRAKEMODE)
%
%   OBJ.Stop(BRAKEMODE, HANDLE)
%
% Description
%     OBJ.Stop() is the same as OBJ.Stop('off').
%
%     OBJ.Stop(BRAKEMODE) stops the motor specified in OBJ with the
%     brakemode specified in BRAKEMODE:
%
%     BRAKEMODE can take the following values:
%
%      'nobrake', 'off', 0, false: The electrical power to the specified
%                                  motor is simply disconnected, the
%                                  so-called "COAST" mode. Motor will keep
%                                  spinning until it comes to a soft stop.
%
%      'brake',   'on',  1, true: This will actively halt the motor at the
%                                 current position (until the next movement
%                                 command); it's a "hard brake".
%
%     Use HANDLE to identify the connection to use for this command (optional).
%
% 
% Note:
%
% To stop all motors at precisely the same time, please see the command
% StopMotor. It can be called with the syntax StopMotor('all', 'off')
% or StopMotor('all', 'brake'). When comparing this to the obj.Stop method,
% it acts more precise when wanting to stop multiple motors at the same
% time...
%
% Using the active brake (e.g. .Stop('brake')) can be very power
% consuming, so watch your battery level when using this functionality for
% long periods of time.
%
%
% Example:
%      motorC = NXTMotor('C', 'Power', -100, 'TachoLimit', 0);
%      motorC.SendToNXT();
%      pause(4);      % wait 4 seconds
%      motorC.Stop('brake');
%
% See also: NXTMotor, WaitFor, StopMotor
%
%
% Signature
%   Author: Aulis Telle, Linus Atorf (see AUTHORS)
%   Date: 2009/07/20
%   Copyright: 2007-2010, RWTH Aachen University
%
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

%% check input parameters
if ~isa(obj,'NXTMotor')
    error('MATLAB:RWTHMindstormsNXT:invalidObject',...
        'No NXTMotor object.');
end

if ~exist('brakemode', 'var')
    brakemode = 'off';
end

%% stop motor according to specific brakemode
brakemode = mapBrakeMode(brakemode);

% Parameter checking is done in StopMotor
for k = 1:numel(obj.Port)
    if exist('handle', 'var')
        StopMotor(obj.Port(k), brakemode, handle);
    else
        StopMotor(obj.Port(k), brakemode);
    end
end

end


%% make various brakemode values to relevant string
function out = mapBrakeMode(mode)
    if ~ischar(mode) && ~isfloat(mode) && ~islogical(mode)
        error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Invalid parameter: Input argument brakemode has to be ''brake'' or ''off'' or true or false!')
    end%if
    
    mode = lower(mode);
    
    switch(mode)
        case {'nobrake', 'off', 0, false}
            out = 'off';
        case {'brake', 'on', 1, true}
            out = 'brake';
        otherwise
            error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Invalid parameter: Input argument brakemode has to be ''brake'' or ''off'' or true or false!')
    end
end %% FUNCTION MAPBRAKEMODE