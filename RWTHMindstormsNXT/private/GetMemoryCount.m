function memory = GetMemoryCount(number, varargin)
% Gets the internal NXT memory counter (manual mapping replica)
%  
% Syntax
%   memory = GetMemoryCount(port) 
%
%   memory = GetMemoryCount(port, handle) 
%
% Description
%   memory = GetMemoryCount(port) gets the internal NXT memory counter (maual mapping replica)
%   of the given motor port. The value port can be addressed by the symbolic constants
%   MOTOR_A, MOTOR_B and MOTOR_C analog to the labeling on the NXT Brick. The return value
%   memory contains the value of the NXT memory counter (maunal mapping replica).
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
%
% Note:
%   This function is *recommened for the advanced user*.
%
% Examples
%   memory = GetMemoryCount(MOTOR_A);
%
% See also: SetMemoryCount, MOTOR_A, MOTOR_B, MOTOR_C
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
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

% check if handle is given; if not use default one
if nargin > 1
    h = varargin{1};
else
    h = COM_GetDefaultNXT;
end%if

% get motorstate
NXTMOTOR_State = h.NXTMOTOR_getState();

memory = NXTMOTOR_State(number+1).MemoryCount;

end % end function