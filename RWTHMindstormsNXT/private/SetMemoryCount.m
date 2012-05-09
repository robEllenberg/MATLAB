function SetMemoryCount(number, angle, varargin)
% Sets the internal NXT memory counter (manual mapping replica)
%  
% Syntax
%   SetMemoryCount(port, angle) 
%
%   SetMemoryCount(port, angle, handle) 
%
% Description
%   SetMemoryCount(port, angle)) sets the internal NXT memory counter (maual mapping replica)
%   of the given motor port. The value port can be addressed by the symbolic constants
%   MOTOR_A, MOTOR_B and MOTOR_C analog to the labeling on the NXT Brick. The value angle
%   sets the value of the NXT memory counter (maunal mapping replica).
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%
% Note:
%
%   This function is *recommened for the advanced user*.
%
% Example
%   SetMemoryCount(MOTOR_B, 120);
%
% See also: SetMemoryCounter, MOTOR_A, MOTOR_B, MOTOR_C
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
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


% check if handle is given; if not use default one
if nargin > 2
    h = varargin{1};
else
    h = COM_GetDefaultNXT;
end%if

% get  motorstate
NXTMOTOR_State = h.NXTMOTOR_getState();

NXTMOTOR_State(number+1).MemoryCount = angle;

% save motor state back to handle
h.NXTMOTOR_setState(NXTMOTOR_State);


end % end function
