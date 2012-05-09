function SetTurnRatio(NewRatio)
% Sets the turn ratio of the current active motor
%  
% Syntax
%   SetTurnRatio(ratio) 
%
% Description
%   SetTurnRatio(ratio) sets the turn ratio of the current active motor which can be controlled
%   by SendMotorSettings. The value ratio has to be wihtin the Integer interval -100...100.
%   The value specifies the ratio of power distribution between two motors (e.g. left and right
%   wheel of the robot).
%   The ratio setting takes only affect with the next SendMotorSettings command and if two
%   motors are synchronied with SyncToMotor. 
%
%   According to the LEGO Mindstorms communication protocol documentation, a ratio of 0 means equal
%   power to both motors. Set 50 if you want one wheel spinning and the other stopped. Turn ratio of
%   100 will turn one wheel in the opposite direction (i.e. reverse) and the other forward, hence
%   giving the maximum "turn around on the spot" effect. Set values between 1 and 49 to get nice
%   curves or circles driven by your robot. 
%
% Note:
%   When using several motor commands with SyncToMotor statements,
%   unexpected behaviour can occur, due to the NXTs internal error correction counters.
%   Sometimes it can help to issue the commands NXT_ResetMotorPosition(port, true),
%   NXT_ResetMotorPosition(port, false) and StopMotor(port, 'off') for each of both 
%   motors. Although this seems like a waste of packets, this can do the trick, especially
%   when working with certain turn ratios.
%
% Example
%   SetMotor(MOTOR_B);
%   	SyncToMotor(MOTOR_A);
%   	SetPower(76);
%   	SetTurnRatio(50);
%   SendMotorSettings();
%
% See also: SendMotorSettings, SyncToMotor, SetMotor, SetPower
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

if ischar(NewRatio)
    NewRatio = str2double(NewRatio);
end%if

if abs(NewRatio) > 100
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidTurnRatio', 'TurnRatio must be between -100 and 100')
end%if


%% get default handle & motorstate
h = COM_GetDefaultNXT();
NXTMOTOR_State = h.NXTMOTOR_getState();


whatmotor = h.NXTMOTOR_getCurrentMotor();


%% Set turn ratio
if whatmotor == 255 
    % feel the power of vectors :-)
    NXTMOTOR_State(1:3).TurnRatio = NewRatio .* [1; 1; 1];
else
    NXTMOTOR_State(whatmotor + 1).TurnRatio = NewRatio;
    if NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
        NXTMOTOR_State(NXTMOTOR_State(whatmotor + 1).SyncedToMotor + 1).TurnRatio = NewRatio;
    end%if
end%if


%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
