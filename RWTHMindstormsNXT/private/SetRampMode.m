function SetRampMode(UpOrDown)
% Sets the runstate of the current active motor
%  
% Syntax
%   SetRampMode(mode) 
%
% Description
%   SetRampMode(mode) sets the ramp mode of the current active motor which can be controlled
%   by SendMotorSettings. The value mode can be either 'off', 'up' or 'down'. In the case
%   of 'off' no ramp up mode is used fo rthe current active motor. 'up' provides the motor to
%   accelerate from the current power speed to the next power speed set by SetPower during the
%   next rotation angle in degrees set by SetAngleLimit. 'down' provides a deceleration, respectively.  
%   The mode setting takes only affect with the next SendMotorSettings command. 
%
% Examples
%   SetMotor(MOTOR_B);
%   	SetPower(76);
%   	SetAngleLimit(3600);
%   	SetRampMode('up');
%   SendMotorSettings();
%
% See also: SendMotorSettings, SetPower, SetAngleLimit
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2007/10/15
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


%% get default handle & motorstate
h = COM_GetDefaultNXT();
NXTMOTOR_State = h.NXTMOTOR_getState();

whatmotor = h.NXTMOTOR_getCurrentMotor();


%% Set ramp mode
if strcmpi(UpOrDown, 'up')
    NXTMOTOR_State(whatmotor + 1).RunStateName = 'RAMPUP';
elseif strcmpi(UpOrDown, 'down')
    NXTMOTOR_State(whatmotor + 1).RunStateName = 'RAMPDOWN';
elseif strcmpi(UpOrDown, 'off')
	NXTMOTOR_State(whatmotor + 1).RunStateName = 'RUNNING';
else
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidRampMode', 'Argument for SetRampMode must either be ''up'' or ''down'' or ''off''');
end%if

% if synced, set other motor as well
if NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
    NXTMOTOR_State(NXTMOTOR_State(whatmotor + 1).SyncedToMotor + 1).RunStateName = NXTMOTOR_State(whatmotor + 1).RunStateName; 
end%if


%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
