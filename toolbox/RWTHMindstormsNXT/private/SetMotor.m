function SetMotor(port)
% Sets the current motor to use for motor setting commands
%  
% Syntax
%   SetMotor(port) 
%
% Description
%   SetMotor(port) sets the current motor on the given port as the current active motor which can be controlled
%   by SendMotorSettings. Changing motor settings take only an effect on the active motor. The
%   value port can be addressed by the symbolic constants MOTOR_A , MOTOR_B and MOTOR_C
%   analog to the labeling on the NXT Brick.
%
%   The current motor setting can be returned by function GetMotor.
%
% Example
%   SetMotor(MOTOR_C);
%   	SetPower(76);
%   	SetAngleLimit(720);
%   SendMotorSettings();
%
% See also: GetMotor, SendMotorSettings, MOTOR_A, MOTOR_B, MOTOR_C
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
if ischar(port)
    port = str2double(port);
end%if

if (((port < 0) || (port > 2)) && (port ~= 255)) || isnan(port)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'MotorPort must be 0, 1, 2, or 255 for all motors');
end%if

%% Set motor
h = COM_GetDefaultNXT();
h.NXTMOTOR_setCurrentMotor(port);

end%function
