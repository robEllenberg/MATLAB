function StopMotor(whatmotor, brakemode, varargin)
% Stops / brakes specified motor. (Synchronisation will be lost after this)
%  
% Syntax
%   StopMotor(port, mode) 
%
%   StopMotor(port, mode, handle) 
%
% Description
%   StopMotor(port, mode) stops the motor connected to the given port. The value port can be
%   addressed by the symbolic constants MOTOR_A, MOTOR_B, MOTOR_C and 'all' (all motor at at
%   the same time) analog to the labeling on the NXT Brick. The argument mode can be equal to
%   'off' (or 'nobrake' or false) which cuts off the electrical power to the specific motor, so called "COAST" mode. The
%   option 'brake' (or 'on' or true) will actively halt the motor at the current position (until the next command).
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Note:
%   The value port equal to 'all' can be used to stopp all motors at the same time using only
%   one single Bluetooth packet. After a StopMotor command the motor snychronization will be lost.
%
%   With mode equal to 'off', the motor will slowly stop spinning, but using 'brake' applies
%   real force to the motor to stand still at the current position, just like a real brake. 
%
%   Using the active brake (e.g. StopMotor(MOTOR_A, 'brake')) can be very power
%   consuming, so watch your battery level when using this functionality for
%   long periods of time.
%   
% Limitations:
%   When working with a motor object that contains multiple motors (e.g.
%   created by NXTMotor('BC')), stopping only one motor (in this case
%   with e.g. StopMotor(MOTOR_B, 'off')) can lead to unexpected behavior.
%   When working with synchronized motors, always stop those motors
%   together. It's generally recommended to use the motor object's method
%   Stop if possible.
%
% Example
%   % regular stop
%   StopMotor(MOTOR_B, 'brake');
%
%   % imagine we have all motors moving at once:
%   m1 = NXTMotor('A',  'Power', 80);
%   m2 = NXTMotor('BC', 'Power', 50);
%   m1.SendToNXT();
%   m2.SendToNXT();
%
%   % a great way to stop all motors at once at the same time now:
%   StopMotor('all', 'off');
%
%   % the other possibility would not stop movement at precisely
%   % the same moment:
%   m1.Stop();
%   m2.Stop();
%
%
% See also: NXTMotor, Stop, NXT_SetOutputState, MOTOR_A, MOTOR_B, MOTOR_C
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2009/08/24
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


%% Interpret Parameter
% check if handle is given; if not use default one
if nargin > 2
    h = varargin{1};
else
    h = COM_GetDefaultNXT;
end%if


if ischar(whatmotor)
    if strcmpi(whatmotor, 'all')
        whatmotor = 255;
    else
        whatmotor = str2double(whatmotor);
    end%if
end%if


%% Check Parameter
if (whatmotor < 0 || whatmotor > 2) && (whatmotor ~= 255)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'Input argument for motor port must be 0, 1 or 2 or ''all''.');
end%if

brakemode = lower(brakemode);
    
% allow also other string, although this was actually never intended and is
% not wanted...
switch(brakemode)
    case {'nobrake', 'off', 0, false}
        brakemode = 'off';
    case {'brake', 'on', 1, true}
        brakemode = 'brake';
    otherwise
        error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Invalid parameter: Input argument brakemode has to be ''brake'' or ''off'' or true or false!')
end%switch



%% get motorstate
NXTMOTOR_State = h.NXTMOTOR_getState();

%% reset regulation state
h.NXTMOTOR_resetRegulationState(whatmotor);


%% Wait if necessary
% this dynamic wait here is needed to avoid the following problem:
%   m.SendToNXT;
%   m.Stop;
%   %something else
% only with this wait the whole thing works...
delay = 0.015; %#NXCDELAY
if whatmotor ~= 255    
    while toc(NXTMOTOR_State(whatmotor+1).LastMsgToNXCSentTime) < delay 
        % wait ^^
    end%while
else
    % wait for all 3
    for j = 1 : 3
        while toc(NXTMOTOR_State(j).LastMsgToNXCSentTime) < delay
            %wait
        end%while
    end%for
end%if



%% Turn Off Mode (Coast mode)
if strcmpi(brakemode, 'off')
    
    
    % basically turn electric power to motor off, COAST mode
    NXT_SetOutputState(whatmotor, ...
        0, ...      % power
        false, ...  % motoron
        false, ...  % brake
        'IDLE', ... % regulation
        0, ...      % turnratio
        'IDLE', ... % runstate
        0, ...      % tacho limit
        'dontreply', h); % replymode
  
        
%% Brake Mode
elseif strcmpi(brakemode, 'brake')
    
    
    % set speed regulation mode
    if whatmotor == 255
        NXTMOTOR_State(1).SyncedToSpeed = true;
        NXTMOTOR_State(2).SyncedToSpeed = true;
        NXTMOTOR_State(3).SyncedToSpeed = true;
    else
        NXTMOTOR_State(whatmotor+1).SyncedToSpeed = true;
    end%if
    
    % set to power 0 with speed regulation
    NXT_SetOutputState(whatmotor, ...
        0, ...      % power
        true, ...   % motoron
        true, ...   % brake
        'SPEED', ...% regulation
        0, ...      % turnratio
        'RUNNING', ... % runstate
        0, ...      % tacho limit
        'dontreply', h); % replymode    


%% Error    
else
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidBrakeMode', ...
         ['Input argument for brake mode must either be ''off'' (motor will be turned off) ' ...
          'or ''brake'' (motor will be actively halted at speed 0)']); 
end%if



%% remember timestamp to delay next NXC command if necessary...
if whatmotor == 255
    NXTMOTOR_State(1).LastStopCmdSentTime = tic();
    NXTMOTOR_State(2).LastStopCmdSentTime = tic();
    NXTMOTOR_State(3).LastStopCmdSentTime = tic();
else
    NXTMOTOR_State(whatmotor+1).LastStopCmdSentTime = tic();
end%if

        
   


%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);



end%function

