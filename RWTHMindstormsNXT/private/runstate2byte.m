function byte = runstate2byte(name)
% Determines runstate byte from given runstate mode
%
% Syntax
%   byte = runstate2byte(name)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
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
if ~ischar(name)
    error('MATLAB:RWTHMindstormsNXT:inputArgumentNotAString', 'Input argument must be a string')
end%if

%% Interpret regulation mode
if strcmpi(name, 'IDLE')
    byte = 0;
elseif strcmpi(name, 'RAMPUP')
    byte = 16;
elseif strcmpi(name, 'RUNNING')
    byte = 32;
elseif strcmpi(name, 'RAMPDOWN')
    byte = 64;
else
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidRunstateName', 'Input argument must be ''IDLE'' or ''RAMPUP'' or ''RUNNING'' or ''RAMPDOWN''')
end%if

end%function
