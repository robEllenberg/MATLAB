function SetPower(NewPower)
% Sets the power of the current active motor
%  
% Syntax
%   SetPower(power) 
%
% Description
%   SetPower(power) sets the power value of the current active motor which can be controlled
%   by SendMotorSettings. The value power has to be an Integer value within the interval
%   -100...100. It specifies the percentage of the maximal available power. Negative values
%   indicates a reverse rotation direction. The power setting takes only affect with the next
%   SendMotorSettings command. 
%
% Example
%   SetMotor(MOTOR_B);
%   	SetPower(-55);
%   	SetAngleLimit(1200);
%   SendMotorSettings();
%
% See also: SendMotorSettings, SetMotor
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
if ischar(NewPower)
    NewPower = str2double(NewPower);
end%if

if abs(NewPower) > 100
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPower', 'Power must be between -100 and 100')
end%if

%% Get handle & motorstate
h = COM_GetDefaultNXT();
NXTMOTOR_State = h.NXTMOTOR_getState();

whatmotor = h.NXTMOTOR_getCurrentMotor();


%% Set power values
if whatmotor ~= 255
    NXTMOTOR_State(whatmotor + 1).Power = NewPower;

    % if synced, apply to both motors!
    if NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
        NXTMOTOR_State(NXTMOTOR_State(whatmotor + 1).SyncedToMotor + 1).Power = NewPower;
    end%if

else
    % is there a more elegant way to do this??? (1:3) doesnt work
    NXTMOTOR_State(1).Power = NewPower;
    NXTMOTOR_State(2).Power = NewPower;
    NXTMOTOR_State(3).Power = NewPower;
end%if

%% save state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
