function [ varargout ] = ReadFromNXT( obj , handle) 
% Reads current state of specified motor(s) from NXT brick
%
% Syntax
%    DATA = OBJ.ReadFromNXT
%
%    DATA = OBJ.ReadFromNXT(HANDLE)
%
%    [DATA1 DATA2] = OBJ.ReadFromNXT
%  
%    [DATA1 DATA2] = OBJ.ReadFromNXT(HANDLE)
% 
% Description
%    Request the current state of the motor object OBJ from the NXT brick.
%    NXTMotor object OBJ is not modified. DATA is a structure with
%    property/value pairs.
%
%    If the NXTMotor object OBJ controls two motors, DATA1 and DATA2 hold the parameters
%    of the first and the second motor respectively. If only one
%    output argument is given, the parameters of the first motor
%    are returned.
%
%    Use the optional parameter HANDLE to identifiy the connection to use
%    for this command. Otherwise  the default handle (see
%    COM_SetDefaultNXT) will be used.
%
%
%    The returned struct contains the following fields:
%
% * Port - The motor port these data apply to.
%
% * Power - The currently set power level (from -100 to 100).
%
% * Position - The motor's position in degrees (of the internal rotation
% sensor). These encoders should be accurate to +/- 1 degree. Values will
% increase positively during forward motion, and decrease during reverse
% motion. You can reset this counter by using the method .ResetPosition.
%
% * IsRunning - A boolean indicating whether the motor is currently
% spinning or actively braking (basically whether the motor _"is turned on or off"_). It
% will only be false once the motor is in free-running "coast" mode, i.e.
% when the power to this motor is turned off (e.g. after calling
% Stop('off') or when the set TachoLimit was reached). To clarify:
% if a motor was stopped using .Stop('brake'), or if
% .ActionAtTachoLimit was set to 'HoldBrake', IsRunning will keep
% returning true! Use the method .WaitFor to check wether a motor is
% ready to accept new commands!
%
% * SpeedRegulation - A boolean indicating wether the motor currently
% uses speed regulation. This is turned off during synchronous driving
% (when driving with 2 motors at the same time).
%
% * TachoLimit - The currently set goal for the motor to reach. If set to
% 0, the motor is spinning forever.
%
% * TachoCount - This counter indicates the progress of the motor for its
% current goal -- i.e. if a TachoLimit ~= 0 is set, TachoCount will
% count up to this value during movement.
%
%
% Note:
%  The values of TachoCount and TachoLimit (which can nicely be used as
%  progress indicators) are not guaranteed to keep being valid once motor
%  movement has finished. They can/will be cleared by the next
%  SendToNXT, Stop, StopMotor or maybe even DirectMotorCommand.
%
%  For advanced users: The field Position maps to the NXT firmware's
%  register / IOmap counter RotationCount, and TachoCount maps to
%  TachoCount as expected.
%
% Limitations:
%
%  Apart from the previously mentioned limitation of IsRunning (return
%  values slightly differ from what would be expected), the value of
%  SpeedRegulation can sometimes be unexpected: The DATA struct
%  returned by ReadFromNXT always returns the true state of the NXT's
%  firmware registers (it's basically just a wrapper for
%  NXT_GetOutputState). When using an NXTMotor object with
%  SpeedRegulation = true, the regulation will only be enabled during
%  driving. When the motor control starts braking, regulation will be
%  disabled, and this is what ReadFromNXT shows you. So don't worry when
%  you receive SpeedRegulation = false using this method, even though you
%  clearly enabled speed regulation. This is by design, and the motor did
%  in fact use speed regulation during its movement.
%
% Examples:
%
%  % Move motor A and show its state after 3 seconds
%  motorA = NXTMotor('A', 'Power', 50);
%  motorA.SendToNXT();
%  pause(3);
%  data = motorA.ReadFromNXT();
%
%  % Construct a NXTMotor object on port 'A' with a power of
%  % 50, TachoLimit of 1000, and send the motor settings to the NXT.
%  % Show the progress of the motor movement "on the fly".
%
%  motorA = NXTMotor('A', 'Power', 50, 'TachoLimit', 1000);
%  % this example wouldn't work with 'HoldBrake'
%  motorA.ActionAtTachoLimit = 'Brake';
%
%  motorA.SendToNXT();
%
%  % monitor during movement
%  data = motorA.ReadFromNXT();
%  while(data.IsRunning)
%      percDone = abs(data.TachoCount / data.TachoLimit) * 100;
%      disp(sprintf('Motor movement is %d % complete/n', percDone));
%      data = motorA.ReadFromNXT(); % refresh
%  end%while
%
%
%
% See also: NXTMotor, SendToNXT, ResetPosition, NXT_GetOutputState
%
% Signature
%   Author: Aulis Telle, Linus Atorf (see AUTHORS)
%   Date: 2008/11/12
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


%% check input parameters
if ~isa(obj,'NXTMotor')
    error('MATLAB:RWTHMindstormsNXT:invalidObject',...
          'No NXTMotor object.');
end

if ~exist('handle', 'var')
    handle = COM_GetDefaultNXT;
end%if    

if nargout > 2
    error('MATLAB:RWTHMindstormsNXT:wrongNumberOfParameters',...
          'Too many output parameters');
end

if nargout > numel(obj.Port)
    error('MATLAB:RWTHMindstormsNXT:wrongNumberOfParameters',...
          'Number of output parameters does not match number of ports');
end

if nargout == 0
    nout = 1;
else
    nout = nargout;
end
    
%% get NXT settings
settings = [];
for k = 1:nout
    % get setting from NXT_GetOutputState
    
    settings = NXT_GetOutputState(obj.Port(k), handle);
    
    % set data as output variable
    data.Port  = settings.Port;
    data.Power = settings.Power;
    
    % slow version with string-compare
%     if strcmp(settings.RunStateName, 'RUNNING') == 1
%         data.IsRunning = 1;
%     else
%         data.IsRunning = 0;
%     end 

    % faster version:
    data.IsRunning = (settings.RunStateByte ~= 0); % runstate 0 = IDLE

    if strcmpi(settings.RegModeName, 'SPEED') == 1
        data.SpeedRegulation = true;
    else
        data.SpeedRegulation = false;
    end
    
    data.TachoLimit = settings.TachoLimit;
    data.TachoCount = settings.TachoCount;
    data.Position   = settings.RotationCount;

    varargout{k} = data;
end
