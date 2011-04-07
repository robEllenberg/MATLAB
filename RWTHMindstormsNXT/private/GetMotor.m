function n = GetMotor()
% Reads the current motor set by SetMotor(). Raises an error if no motor was set
%  
% Syntax
%   number = GetMotor() 
%
% Description
%   number = GetMotor() returns the current motor number set by function SetMotor. The value
%   number can be 0, 1 or 2.
%
% Example
%   SetMotor(MOTOR_B);
%   number = GetMotor();
%
% See also: SetMotor
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

% get default handle & motorstate
h = COM_GetDefaultNXT();
n = h.NXTMOTOR_getCurrentMotor();

end%function