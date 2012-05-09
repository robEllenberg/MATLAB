function SetAngleLimit(NewLimit)
% Sets the angle limit (in degrees) of the current motor port
%  
% Syntax
%   SetAngleLimit(limt) 
%
% Description
%   SetAngleLimit(limt) sets the angle limit in degrees for the current motor, which is set by
%   function SetMotor. This setting takes only affect with the next SendMotorSettings command.
%
%   Use SetAngleLimit(0) to deactivate this limit (hence the motor will run forever).
%
% Note:
%   This commmand provides an automatically limited motor rotation. The NXT Brick will try to rotate
%   only to the angle which is set. Unfortunately if the power is set too high, the target angle
%   will be slightly missed, as the motor has still enough angular momentum to keep spinning a bit.
%   Ways around can be to slow down the motor before it approaches its angle limit and then keep
%   going very carefully, or to willingly miss the angle limit and then reverse back to where you
%   want to go precisely.
%
% Example
%   SetMotor(MOTOR_B);
%   	SetPower(76);
%   	SetAngleLimit(720);
%   SendMotorSettings();
%
% See also: SendMotorSettings, SetMotor, GetMotor
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


%% Check parameter
if ischar(NewLimit)
    NewLimit = str2double(NewLimit);
end%if

if NewLimit < 0 
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidAngleLimit', 'SetAngleLimit only takes values >= 0 as input.')
end%if


%% get default handle & motorstate
h = COM_GetDefaultNXT();
NXTMOTOR_State = h.NXTMOTOR_getState();

whatmotor = h.NXTMOTOR_getCurrentMotor();


%% Set angle limit
NXTMOTOR_State(whatmotor + 1).AngleLimit = NewLimit;

% if synced, apply to both motors!
if NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
    NXTMOTOR_State(NXTMOTOR_State(whatmotor + 1).SyncedToMotor + 1).AngleLimit = NewLimit;
end%if


%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
