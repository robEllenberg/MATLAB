function varargout = DebugMode(varargin)
% Gets or sets debug state (i.e. if textOut prints messages to the command window)
%  
% Syntax
%   state = DebugMode(); 
%
%   DebugMode(state); 
%
%
% Description
%   The function textOut can be used to display text messages inside the command
%   window. These messages can optionally be logged to a file (see textOut for
%   details) or the output can be disable. To turn off those debug messages, the
%   global variable DisableScreenOut had to be modified in earlier toolbox
%   versions. Now the function DebugMode provides easier access.
%
%   state = DebugMode(); returns the current debug state, the return value is
%   either 'on' or 'off'.
%
%   DebugMode(state); is used to switch between displaying messages and silent
%   mode. The paramter state has to be 'on' or 'off'.
%
%
%   Note: If you need a fast alternative to strcmpi(DebugMode(), 'on'), please
%   consider the private toolbox function isdebug.
%
% Example
%  % enable debug messages
%  DebugMode on
%
%  % remember old setting
%  oldState = DebugMode();
%  DebugMode('on');
%     % do something with textOut(), it will be displayed!
%  % restore previous setting
%  DebugMode(oldState);
%
%
% See also: textOut, isdebug (private)
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/04
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

    global DisableScreenOut
    
    % initialize if necessary
    if isempty(DisableScreenOut)
        DisableScreenOut = true;
    end%if
    
    if nargin == 0
        if DisableScreenOut
            varargout{1} = 'off';
        else
            varargout{1} = 'on';
        end%if
    else
        if ~ischar(varargin{1})
            error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Input argument must be ''on'' or ''off''!')
        end%if
        if strcmpi(varargin{1}, 'on')
            DisableScreenOut = false;
            %textOut(sprintf('Debug mode enabled.\n'));
        elseif strcmpi(varargin{1}, 'off')
            DisableScreenOut = true;
        else
            error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Input argument must be ''on'' or ''off''!)')
        end%if
    end%if


end%function