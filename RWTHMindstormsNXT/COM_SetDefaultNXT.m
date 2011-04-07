function COM_SetDefaultNXT(h)
% Sets global default NXT handle (will be used by other functions as default)
%
% Syntax
%   COM_SetDefaultNXT(h)
%
% Description
%   COM_SetDefaultNXT(h) sets the given handle h to the global NXT handle, which is used
%   by all NXT-Functions per default if no other handle is specified. To
%   create and open an NXT handle (Bluetooth or USB), the functions
%   COM_OpenNXT and COM_OpenNXTEx can be used. To retrieve the global default handle
%   user COM_GetDefaultNXT.
%
% Example
%   MyNXT = COM_OpenNXT('bluetooth.ini');
%   COM_SetDefaultNXT(MyNXT);
%
% See also: COM_GetDefaultNXT, COM_OpenNXT, COM_OpenNXTEx
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/07
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


checkHandleStruct(h);

global NXTHANDLE_Default;
NXTHANDLE_Default = h;



end%function
