function h = COM_GetDefaultNXT()
% Returns the global default NXT handle if it was previously set
%
% Syntax
%   h = COM_GetDefaultNXT()
%
% Description
%   h = COM_GetDefaultNXT() returns the global default NXT handle h if it was previously 
%   set. The default global NXT handle is used by all NXT-Functions per default if no other
%   handle is specified. To set this global handle the function COM_SetDefaultNXT is used.
%
% Example
%   handle = COM_OpenNXT('bluetooth.ini');
%   COM_SetDefaultNXT(handle);
%   MyNXT = COM_GetDefaultNXT();
%   % now MyNXT and handle refer to the same device
%
% See also: COM_SetDefaultNXT, COM_OpenNXT, COM_OpenNXTEx
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



global NXTHANDLE_Default

if isempty(NXTHANDLE_Default)
    error('MATLAB:RWTHMindstormsNXT:Bluetooth:defaultHandleNotSet','Global default NXT handle not set, but expected to use. Use COM_SetDefaultNXT().');
end%if

h = NXTHANDLE_Default;


% below is another version to achieve exactly the same as this does, but
% faster. it turns out the global command is quite slow. so this code tried
% to replace global with persistent, in order to have only 1 function with
% 2 sets of input arguments. it turns out it's not worth it, but for
% further optimizations, maybe it should be reconsidered...
%
% persistent DefaultHandle
% 
% if nargin == 2
%     if isnan(varargin{1}) % random security code
%         DefaultHandle = varargin{2};
%     end%if
% end%if
% 
% if isempty(DefaultHandle)
%     error('MATLAB:RWTHMindstormsNXT:Bluetooth:defaultHandleNotSet','Global default NXT handle not set, but expected to use. Use COM_SetDefaultNXT().');
% end%if
% 
% h = DefaultHandle;


end%function
