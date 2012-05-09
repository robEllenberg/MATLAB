function bytes = COM_CreatePacket(CommandType, Command, ReplyMode, ContentBytes)
% Generates a valid Bluetooth packet ready for transmission (i.e. sets length)
%
% Syntax
%   bytes = COM_CreatePacket(CommandType, Command, ReplyMode, ContentBytes)
%
% Description
%   bytes = COM_CreatePacket(CommandType, Command, ReplyMode, ContentBytes) creates a valid
%   Bluetooth packet conform to the LEGO Mindstorms communication protocol. The CommandType
%   specifies the telegram type (direct or system command (see the
%   LEGO Mindstorms communication protocol documentation for more details)). This type is determined
%   from the function name2commandbytes. The Command specifies the actual command according to
%   the LEGO Mindstorms communication protocol. By the ReplyMode one can request an
%   acknowledgement for the packet transmission. The two strings 'reply' and 'dontreply' are
%   valid. The content byte-array is given by the ContentBytes.
%
%   The return value bytes represents the complete Bluetooth packet conform to the LEGO Mindstorms
%   Communication protocol.
%
% Note:
%   The activated ReplyMode should only be used if it is necessary. According to the official
%   LEGO statement "Testing during development has shown that the Bluetooth Serial Port
%   communication has some disadvantages when it comes to streaming data. ... One problem is a time
%   penalty (of around 30ms) within the Bluecore chip when switching from receive-mode to
%   transmit-mode. ... To handle the problem of the time penalty within the Bluecore chip, users
%   should send data using Bluetooth without requesting a reply package. This will mean that the
%   Bluecore chip won't have to switch direction for every received package and will not incur a
%   30ms penalty for every data package."
%
% Example
%   [type cmd] = name2commandbytes('PLAYTONE');
%   content(1:2) = dec2wordbytes(frequency, 2);
%   content(3:4) = dec2wordbytes(duration, 2);
%
%   packet = COM_CreatePacket(type, cmd, 'dontreply', content);
%
% See also: COM_SendPacket, COM_CollectPacket, name2commandbytes, dec2wordbytes
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/09
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

%% Set packet length
% preallocate: length = lengthbytes, type, command, content
PayloadLen = 1 + 1 + length(ContentBytes);      % type, command, content
PacketLen  = 2 + PayloadLen;                    % + 2 bytes for payload size
bytes      = zeros(PacketLen, 1);


%% Pack bluetooth packet
% this is the point where we can add USB-support. For valid
% USB-Packets, leave out the length information (payload size), resulting
% in a valid packet 2 bytes shorter than the corresponding
% bluetooth-version.

% 2 bytes for payload size
bytes(1:2) = dec2wordbytes(PayloadLen, 2);

% 1 byte for telegram type (dontreply, reply)
NoReplyBit = 128; % hardcoded the old hex2dec('80') version for performance improvement
if strcmpi(ReplyMode, 'dontreply')
    bytes(3) = bitor(CommandType, NoReplyBit);
elseif strcmpi(ReplyMode, 'reply')
    bytes(3) = CommandType;
else
    error('MATLAB:RWTHMindstormsNXT:Bluetooth:invalidReplyModeParameter', 'ReplyMode must either be ''reply'' or ''dontreply''');
end%if

% Command byte
bytes(4) = Command;

% Content bytes
bytes(5:PacketLen) = ContentBytes;

end%function
