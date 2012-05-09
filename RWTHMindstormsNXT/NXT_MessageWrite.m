function NXT_MessageWrite(varargin)
% Writes a "NXT-to-NXT message" to the NXT's incoming BT mailbox queue
%
% Syntax:
%   NXT_MessageWrite(message)
%
%   NXT_MessageWrite(message, mailbox)
%
%   NXT_MessageWrite(message, mailbox, handle)
%
% Description:
%   NXT_MessageWrite(message) sends given message to the NXT brick
%
%   NXT_MessageWrite(message, mailbox) stores message in the specified
%     mailbox. If no mailbox is specified, default one is 0 (zero)
%
%   NXT_MessageWrite(message, mailbox, handle) uses the given NXT
%   connection handle. If no handle is specified, the default one
%   (COM_GetDefaultNXT()) is used.
%
% Note:
%   Use this function to store data locally on the NXT. There are 10 usable
%   mailbox queues, each with a certain size (so be careful to avoid
%   overflows). Maximum message limit is 58 bytes / chars. This function
%   can be used to communicate with NXC programs (the NXC-function
%   "ReceiveRemoteString" can be used to read the data on the NXT).
%
% Examples:
%  NXT_MessageWrite('F010045');
%
%  NXT_MessageWrite('F010045', 1);
%
%  handle = COM_OpenNXT();
%  NXT_MessageWrite('F010045', 0, handle);
%
% See also: NXT_MessageRead
%
% Signature
%   Author: Laurent Vaylet, The MathWorks SAS (France), Alexander Behrens (see AUTHORS)
%   Date: 2008/12/17
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

% Check number and values of input arguments
error(nargchk(1, 3, nargin)) % at least 1 and at most 3 arguments
% Define default values for input arguments
inArgs = {...
  '', ...                 % message
  0, ...                  % mailbox
  NaN ... % handle
  };
% Replace default input arguments with specified ones
inArgs(1:nargin) = varargin;
% Set input arguments to their values
[msg, mailbox, handle] = deal(inArgs{:});

%TODO check if the isstruct check can be omitted for performance... it
%doesn't seem necessary...
if ~isstruct(handle)
    if isnan(handle)
        handle = COM_GetDefaultNXT();
    end
end

% Build full message to send (use 8-byte unsigned integers) 
content = [ ...
  uint8(mailbox); ...         % mailbox
  uint8(length(msg) + 1); ... % message length (+1 accounts for final '0')
  uint8(msg)'; ...            % message
  uint8(0)];                  % final '0' = end of string (like in C)
% Transform it into a known packet format
[type, cmd] = name2commandbytes('MESSAGEWRITE');
packet = COM_CreatePacket(type, cmd, 'dontreply', content);

if isdebug
    textOut(sprintf('  Message to send: "%s"\n', msg));
end%if

% Send it to the brick
COM_SendPacket(packet, handle);
