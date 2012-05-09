function ret = isdebug
% Returns the current debug setting for textOut() as boolean
%  
% Syntax
%   ret = isdebug; 
%
% Description
%   Used as a fast alternative to strcmpi(DebugMode(), 'on'), this function
%   returns true if the current debug state for textOut() is 'on', and false
%   if it is 'off'.
%
%   Since string handling takes CPU time, sometimes you might want to omit
%   generating large or complex debug messages that would be discarded anyway. You
%   can check this by putting an if isdebug before the actual textOut
%   statement.
% 
%   Note: isdebug can return [] if textOut() has never been called before.
%   This is not a problem, since if isdebug still works like expected. Be
%   careful though!
%
% Example
%   if isdebug
%      % only generate this debug message if it will be displayed
%      textOut(sprintf('Current packet: %s \n', ...
%              horzcat(dec2hex(Packet, 2),  blanks(length(Packet))')'));
%   end%if
%
% See also: textOut, DebugMode
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
    
    %careful with empty var?
    global DisableScreenOut
    ret = ~DisableScreenOut;
    
end%function