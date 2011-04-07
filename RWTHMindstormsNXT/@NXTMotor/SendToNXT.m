function SendToNXT(obj, handle)
% Send motor settings to the NXT brick
%
% Syntax
%   OBJ.SendToNXT
%
%   OBJ.SendToNXT(HANDLE)
%
% Description
%     OBJ.SendToNXT sends the motor settings in OBJ to
%     the NXT brick. 
%
%     OBJ.SendToNXT(HANDLE) uses HANDLE to
%     identifiy the connection to use for this command. This is optional.
%     Otherwise the defaul handle (set using COM_SetDefaultNXT) will be
%     used. 
%
%   For a valid list of properties and how they affect the motors'
%   behaviour, see the documentation for the class constructor NXTMotor.
%
% Limitations
%
%   With ActionAtTachoLimit = 'Coast' and synchronous driving (two motors),
%   the motors will stay synced after movement (even after .WaitFor() has
%   finished). This is by design. To disable the synchonization, just use
%   .Stop.
%
%   If you send a command to the NXT without waiting for the previous motor
%   operation to have finished, the command will be dropped (the NXT
%   indicates this with a high and low beep tone). Use the motor-objects
%   method .WaitFor to make sure the motor is ready for new commands, or
%   stop the motor(s) using .Stop.
%
%
% Example
%        motor = NXTMotor('A', 'Power', 50, 'TachoLimit', 200);
%        motor.SendToNXT();
%        motor.WaitFor();
%        NXT_PlayTone(400,500);
%
% See also: NXTMotor, ReadFromNXT, Stop, WaitFor, DirectMotorCommand
%
% Signature
%   Author: Linus Atorf, Aulis Telle, Alexander Behrens (see AUTHORS)
%   Date: 2009/07/12
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


%% check parameter
    if ~isa(obj,'NXTMotor')
        error('MATLAB:RWTHMindstormsNXT:InvalidObject',...
            'No NXTMotor object.');
    end

    % We do not have to check here if there are more than two ports
    % specified in obj.Port because we check that in the set function


%% check handle

    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end

    % % check for "insane" parameter combinations
    % if (obj.TachoLimit == 0) && (obj.BrakeAtTachoLimit)
    %     warning('MATLAB:RWTHMindstormsNXT:Motor:brakeAtTachoLimitWithNoTachoLimit', 'With TachoLimit == 0, using BrakeAtTachoLimit == true makes no sense!')
    % end%if

    % check for impossible parameter combinations
    if (numel(obj.Port) > 1) && (obj.SpeedRegulation == true)
        error('MATLAB:RWTHMindstormsNXT:Motor:invalidSpeedRegulation', 'SpeedRegulation cannot be enabled when using multiple motors together (since they are operated synchronized). Set SpeedRegulation to false or use a single motor!');
    end%if

    if isfield(handle, 'UseNXCMotorControl') && handle.UseNXCMotorControl 
        % with tacholimit
        if obj.TachoLimit ~= 0 
            NXC_MotorControl(obj.Port, obj.Power, obj.TachoLimit, obj.SpeedRegulation, obj.ActionAtTachoLimit, obj.SmoothStart, handle);
        else % no tacholimit 
            
            NXC_MotorControl(obj.Port, obj.Power, 0, obj.SpeedRegulation, 'Coast', false, handle);
            
            %TODO replace this by NXC command?!!?
            %if length(obj.Port) < 2
            %    DirectMotorCommand(obj.Port, obj.Power, 0, BoolToOnOff(obj.SpeedRegulation), 'off', 0, 'off', handle);    
            %else
            %    DirectMotorCommand(obj.Port(1), obj.Power, 0, 'off', obj.Port(2), 0, 'off', handle)    
            %end%if

        end%if
    else   
        error('MATLAB:RWTHMindstormsNXT:Motor:embeddedMotorControlRequiredForMotorClass', 'The class NXTMotor needs the embedded NXC program MotorControl to be running on the NXT, and according to the currently used NXT-handle, this program is not running. Make sure you download MotorControl.rxe (compile from MotorControl.nxc) to your brick and do not disable the automatic launch when calling COM_OpenNXTEx. Otherwise, you have to use the function DirectMotorCommand with limited functionality!')
    end%if


end%function


