function checkHandleStruct(h)
% Private helper to check the integrity of an NXT handle struct
%
% Syntax
%   checkHandleStruct(h)
%
% Description
%   This functions tries to validate a given handle-struct. It get's called
%   before using a handle by the communication layer, or before setting a
%   default handle. Of course the functions cannot check all aspects, so
%   deliberate manipulations of handles can still lead to crashes (this is
%   expected).
%   The function does not return a value but raises an error if
%   appropriate.
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/01
%   Copyright: 2007-2010, RWTH Aachen University
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


% this whole function is somewhat, hmmm... "useless"?
% we can never check the integrity of a full handle, that would be far to
% complex to check all function pointers, handles, numbers, etc.
% on the other hand, if we cannot check all properties and check only a few
% of them, we could reduce this to just one (faster) check...
% well, whatever, this seems like a fair trade-off right now.

% but still, if someone messes around with a handle, there's not much we
% can do about it. but it will produce error messages sooner or later
% anyway.

valid = false;
try
    %NOTE: optimized, old version was:
    %if isstruct(h) && h.Connected()
    if h.Connected()
        actualHandle = h.Handle(); % cache for performance...
        if ~isempty(h.CreationTime) && ~isempty(actualHandle)
            if h.OSValue == 1 % Windows
                if h.ConnectionTypeValue == 1 % USB
                    if isfloat(actualHandle)
                        valid = true;
                    end%if
                else % BT
                    if isa(actualHandle, 'serial')
                        valid = true;
                    end%if
                end%if
            elseif h.OSValue == 2 % Linux
                if h.ConnectionTypeValue == 1 % USB
                     if ~isnumeric(actualHandle) % also possible: isa('libpointer') ?
                         valid = true;
                     end%if
                else % BT
                    if isfloat(actualHandle)
                        valid = true;
                    end%if
                end%if
            else % Mac
                if h.ConnectionTypeValue == 1 % USB, Windows part for USB
                    if isfloat(actualHandle)
                        valid = true;
                    end%if
                else % BT, Linux part for BT
                    if isfloat(actualHandle)
                        valid = true;
                    end%if
                end%if
            end%if
        end%if
    end%if
catch
    % so that didn't work out
    valid = false;
end%try

if ~valid 
    error('MATLAB:RWTHMindstormsNXT:invalidNXTHandle', 'This handle is not a valid NXT handle struct (or was already closed)! Please make sure to create one with COM_OpenNXT or COM_OpenNXTEx, and don''t modify it!')
end%if