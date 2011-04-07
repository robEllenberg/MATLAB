function name = byte2runstate(byte)
% Determines run state parameter from given byte
%
% Syntax
%   name = byte2runstate(byte)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% SignatureCopyright: 2007-2009
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
%   , RWTH Aachen University
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

if byte == 0
    name = 'IDLE';
elseif byte == 16
    name = 'RAMPUP';
elseif byte == 32
    name = 'RUNNING';
elseif byte == 64
    name = 'RAMPDOWN';
else
    name = 'unknown';
    %TODO some kind of warning here to notice the user of this unknown runstate?
end%if

end%function
