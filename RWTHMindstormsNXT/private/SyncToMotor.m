function SyncToMotor(OtherMotor)
% Enables synchronization regulation for current active and specified motor
%  
% Syntax
%   SyncToMotor(OtherMotor) 
%
% Description
%   SyncToMotor(OtherMotor) sets the synchronization mode to the curren active motor (set by
%   SetMotor) and the given motor port OtherMotor. The value OtherMotor can be addressed by
%   the symbolic constants MOTOR_A , MOTOR_B and MOTOR_C analog to the labeling on the NXT
%   Brick. The synchronization mode can be set off if the value OtherMotor is set equal to
%   'off'. The synchronization setting takes only affect with the next SendMotorSettings command.  
%
%   This means that both motors will act as if they were connected through an axle. Motors with more
%   load on them (rough underground) will automatically be corrected and regulated for example. This
%   "synchronization regulation" is the setting you want to use when driving with your robot. Also
%   turning (SetTurnRatio) only affects motors that are synced.
%
% Note:
%   One motor can not be synchronized to itself. The synchronization mode and the speed regulation
%   mode can be set only together at one time. Once a motor is synced to another motor, all
%   settings set to it will be applied to both motors (until synchronisation is lost of course).
%   Once 2 motors are synced, you effectively control 2 motors with 1 set of commands. This means,
%   when calling SendMotorSettings, in fact 2 packets will be send to the 2 synced motors, hence
%   you will experience about twice the lag than usual. Take this into consideration...
%
%   When using several motor commands with SyncToMotor statements,
%   unexpected behaviour can occur, due to the NXTs internal error correction counters.
%   Sometimes it can help to issue the commands NXT_ResetMotorPosition(port, true),
%   NXT_ResetMotorPosition(port, false) and StopMotor(port, 'off') for each of both 
%   motors. Although this seems like a waste of packets, this can do the trick, especially
%   when working with certain turn ratios (see SetTurnRatio).
%
% Example
%   SetMotor(MOTOR_B);
%   	SyncToMotor(MOTOR_C);
%   	SetPower(76);
%   SendMotorSettings();
%
% See also: SendMotorSettings, SetMotor, SetPower, SetTurnRatio
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


%% Check parameter

% check function argument
if ischar(OtherMotor)
    if (~strcmpi(OtherMotor, 'off') && isnan(str2double(OtherMotor)))
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidSyncParameter', 'Given parameter has to be a motor number or the string "off"!');
    end
end

%% get default handle & motorstate
h = COM_GetDefaultNXT();
NXTMOTOR_State = h.NXTMOTOR_getState();

whatmotor = h.NXTMOTOR_getCurrentMotor();

%% Set synchronization mode

% check if synchronization has to be turned off
if strcmpi(OtherMotor, 'off')
    NXTMOTOR_State(1).SyncedToMotor = -1;
    NXTMOTOR_State(2).SyncedToMotor = -1;
    NXTMOTOR_State(3).SyncedToMotor = -1;
else

    if ischar(OtherMotor)
        OtherMotor = str2double(OtherMotor);
    end%if

    if OtherMotor < 0 || OtherMotor > 2
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'Other motor to sync to must be 0, 1 or 2.')
    end%if

    if OtherMotor == whatmotor
        error('MATLAB:RWTHMindstormsNXT:Motor:syncToSelf', ...
              ['You are trying to sync a motor to itself, which is not possible. ' ...
              'The current motor cannot be the other motor you want to sync to.'])
    end%if

    if NXTMOTOR_State(whatmotor + 1).SyncedToSpeed
        warning('MATLAB:RWTHMindstormsNXT:Motor:simultaneousSyncAndSpeedRegulationWarning', ...
               ['You are activating synchronization for an already speed-regulated motor. ' ...
                'This will automatically turn off speed regulation. Make sure to call ' ...
                'SpeedRegulation(''off'') first to disable this warning.']);
    end%if


    % check if synced to the other other motor (^^) before:
    % what i mean: we've got 3 motors. now 1 is to be synced to another one.
    % if the this new target was synced before to the 3rd motor, we must detect
    % it now and set free the 3rd, as now the other two are synced. ok?
    % whatever, it IS necessary...

    % ok we solved the above mentioned problem very easy now:
    NXTMOTOR_State(1).SyncedToMotor = -1;
    NXTMOTOR_State(2).SyncedToMotor = -1;
    NXTMOTOR_State(3).SyncedToMotor = -1;


    % again, careful with the indices now:

    % disable/overwrite speed syncing
    NXTMOTOR_State(whatmotor + 1).SyncedToSpeed = false;
    NXTMOTOR_State(OtherMotor + 1).SyncedToSpeed = false;

    % now write both states
    NXTMOTOR_State(OtherMotor + 1).SyncedToMotor = whatmotor;
    NXTMOTOR_State(whatmotor + 1).SyncedToMotor = OtherMotor;

    % copy property settings from whatmotor to OtherMotor
    NXTMOTOR_State(OtherMotor + 1).Power        = NXTMOTOR_State(whatmotor + 1).Power;
    NXTMOTOR_State(OtherMotor + 1).AngleLimit   = NXTMOTOR_State(whatmotor + 1).AngleLimit;    
    NXTMOTOR_State(OtherMotor + 1).TurnRatio    = NXTMOTOR_State(whatmotor + 1).TurnRatio;
    NXTMOTOR_State(OtherMotor + 1).RunStateName = NXTMOTOR_State(whatmotor + 1).RunStateName;        
   
    % this works, as we just set what we want, the submit method will figure
    % out the difference between the current state and the wanted state...

    % that's the plan at least

end%if

%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);



end%function
