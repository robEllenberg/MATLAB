function ResetPosition(obj, handle)
% Resets the position counter of the given motor(s).
%
% Syntax
%    OBJ.ResetPosition()
%
%    OBJ.ResetPosition(HANDLE)
%
% Description
%     Reset the position of the motor specified in OBJ.
%     Only the internal states of the NXT brick corresponding to 
%     the specified motor(s) are reset. The motor is
%     not moved. This resets the field .Position you can read out using
%     .ReadFromNXT.
%
%     Specify HANDLE (optional) to identifiy the connection to use for
%     this command. Otherwise the defaul handle (set using
%     COM_SetDefaultNXT) will be used.
%
% Note:
%
%  For advanced users: The field Position maps to the NXT firmware's
%  register / IOmap counter RotationCount. It can also be reset using
%  NXT_ResetMotorPosition(port, false). That's in fact what this method
%  does.
%
% Example:
%     motorC = NXTMotor('C', 'Power', -20, 'TachoLimit', 120);
%     motorC.SendToNXT();
%     motorC.WaitFor();
%     data = motorC.ReadFromNXT()
%     %>> data =
%     %            Port: 2
%     %           Power: 0
%     %       IsRunning: 0
%     % SpeedRegulation: 0
%     %      TachoLimit: 120
%     %      TachoCount: -120
%     %        Position: -120
%
%     motorC.ResetPosition();
%     data = motorC.ReadFromNXT()
%     %>> data =
%     %            Port: 2
%     %           Power: 0
%     %       IsRunning: 0
%     % SpeedRegulation: 0
%     %      TachoLimit: 120
%     %      TachoCount: -120
%     %        Position: 0
%
% See also: NXTMotor, ReadFromNXT, NXT_ResetMotorPosition, NXT_GetOutputState, NXC_ResetErrorCorrection
%
% Signature
%   Author: Aulis Telle, Linus Atorf (see AUTHORS)
%   Date: 2009/08/25
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

%% check input parameters
if ~isa(obj,'NXTMotor')
    error('MATLAB:RWTHMindstormsNXT:invalidObject',...
        'No NXTMotor object.');
end

%% call NXT_ResetMotorPosition (reset the RotationCount!)
for k = 1:numel(obj.Port)
    if exist('handle', 'var')
        NXT_ResetMotorPosition(obj.Port(k), 0, handle);
    else
        NXT_ResetMotorPosition(obj.Port(k), 0);
    end
end
