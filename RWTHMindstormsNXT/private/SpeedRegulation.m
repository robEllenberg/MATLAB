function SpeedRegulation(OnOrOff)
% Enables / disables the speed regulation mode of the current active motor
%  
% Syntax
%   SpeedRegulation(mode) 
%
% Description
%   SpeedRegulation(mode) enables or disabled the speed regulation mode of the current active
%   motor which can be controlled by SendMotorSettings. The value mode can be equal to 'on' or
%   'off' which enables or disables the speed regulation.
%   The speed regulation setting takes only affect with the next SendMotorSettings command. 
%
%   The speed regulation provides the motor to rotate speed controlled. So rotations at low speeds
%   (powers) can be achieved.
%
% Note:
%   In case the motor was previously synced to another motor, both these synchronisation modes will
%   be disabled by activating the speed regulation to one of the motors (as speed regulation and
%   motor synchronisation are not possible both together at one time). 
%
% Example
%   SetMotor(MOTOR_A);
%   	SetPower(12);
%   	SpeedRegulation('on');
%   SendMotorSettings();
%
% See also: SendMotorSettings, SetMotor, SetPower
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

%% Check parameter

% this catches errors if SetMotor wasn't called before
whatmotor = h.NXTMOTOR_getCurrentMotor();


%% Set speed regulation
if strcmpi(OnOrOff, 'on')
    
 
    
    % disable other things before
    h.NXTMOTOR_resetRegulationState(whatmotor); % this can cope with whatmotor == 255...
 
    if whatmotor ~= 255
       % check if SyncToMotor was properly turned off before:
        if NXTMOTOR_State(whatmotor + 1).SyncedToMotor ~= -1
            warning('MATLAB:RWTHMindstormsNXT:Motor:simultaneousSyncAndSpeedRegulationWarning', ...
                   ['You are activating SpeedRegulation for an already synced motor. ' ...
                    'This will automatically turn off synchronization. Make sure to call ' ...
                    'SyncToMotor(''off'') first to disable this warning.']);
        end%if
        NXTMOTOR_State(whatmotor + 1).SyncedToSpeed = true; % this cant ;-)
    else
        % is there a more elegant way to do this??? (1:3) doesnt work
        NXTMOTOR_State(1).SyncedToSpeed = true; % this works now
        NXTMOTOR_State(2).SyncedToSpeed = true; 
        NXTMOTOR_State(3).SyncedToSpeed = true; 
    end%if
    
elseif  strcmpi(OnOrOff, 'off')

    if whatmotor ~= 255
        NXTMOTOR_State(whatmotor + 1).SyncedToSpeed = false;
    else
        % is there a more elegant way to do this??? (1:3) doesnt work
        NXTMOTOR_State(1).SyncedToSpeed = false;
        NXTMOTOR_State(2).SyncedToSpeed = false; 
        NXTMOTOR_State(3).SyncedToSpeed = false; 
    end%if
    
    
else
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidSpeedRegulation', 'Argument for SpeedRegulation must either be ''on'' or ''off''');
end%if

%% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end%function
