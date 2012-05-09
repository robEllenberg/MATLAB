function [message localInboxReturn statusByte] = NXT_MessageRead(localInbox, remoteInbox, removeFromRemote, handle)
% Retrieves a "NXT-to-NXT message" from the specified inbox
%  
% Syntax
%   [message localInboxReturn] = NXT_MessageRead(LocalInbox, RemoteInbox, RemoveFromRemote) 
%
%   [message localInboxReturn] = NXT_MessageRead(LocalInbox, RemoteInbox, RemoveFromRemote, handle) 
%
%   [message localInboxReturn statusByte] = NXT_MessageRead(LocalInbox, RemoteInbox, RemoveFromRemote) 
%
%   [message localInboxReturn statusByte] = NXT_MessageRead(LocalInbox, RemoteInbox, RemoveFromRemote, handle) 
%
% Description
%   This function reads a NXT-to-NXT bluetooth message from a mailbox queue
%   on the NXT. LocalInbox and RemoteInbox are the mailbox numbers and
%   must be between 0 and 9. The difference between local and remote
%   mailbox is not fully understood, so it's best to use the same value for
%   both parameters. For more details see the official LEGO Mindstorms
%   communication protocol.
%
%   Set RemoveFromRemote to true to clear the just retrieved message
%   from the NXT's mailbox (and free occupied memory). Set it to false to
%   just "look into" the message while it will still remain on the NXT's
%   message queue.
%   
%   message contains the actual message (string) that has been retrieved.
%   localInboxReturn is just the mailbox number that the message was read
%   from (again, see official Mindstorms communication protocol).
%
%   Optionally, the packet's statusbyte is returned in the output argument
%   statusByte, if requested. Warning from this functions will then be
%   supressed (i.e. no warnings are raised then).
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
%
% Note:
%   This command can only be used when an external program (e.g. written in NXT-G,
%   NXC or NBC) is running on the NXT. Otherwise a warning will be thrown
%   (and an empty message will be returned).
%
%   Use this function to read data locally stored on the NXT. There are 10 usable
%   mailbox queues, each with a certain size (so be careful to avoid
%   overflows). Maximum message limit is 58 bytes / chars. This function
%   can be used to communicate with NXC programs (the NXC-function
%   "SendMessage" can be used to write the data on the NXT).
%
%
% Examples
% NXT_MessageWrite('Test message', 0);
% pause(1)
% % an NXC program will process this message from inbox 0
% % and generate / "send" an answer to inbox 1 for us
% reply = NXT_MessageRead(1, 1, true);
%
% See also: NXT_MessageWrite
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/08/31
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


%% Handle given?
if ~exist('handle', 'var')
    handle = COM_GetDefaultNXT();
end%if

%% Parameter check
if (localInbox < 0) || (localInbox > 9)
    error('MATLAB:RWTHMindstormsNXT:invalidInputArgument', 'localInbox must be an integer between 0 and 9')
end%if  
if (remoteInbox < 0) || (remoteInbox > 19)
    error('MATLAB:RWTHMindstormsNXT:invalidInputArgument', 'remoteInbox must be an integer between 0 and 19')
end%if  

%% Create packet
[type, cmd] = name2commandbytes('MESSAGEREAD');
content = [uint8(remoteInbox); uint8(localInbox); uint8(removeFromRemote)];
packet = COM_CreatePacket(type, cmd, 'reply', content);

%% Send packet
COM_SendPacket(packet, handle);

%% Collect answer
[type receivedCmd status content] = COM_CollectPacket(handle, 'dontcheck'); % dont check because of error 64

%% initialize return var already
message = '';

%% Check if packet is the right one
if receivedCmd ~= cmd
    warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
    localInboxReturn = NaN;
    return
end%if   

%% Check for errors
statusByte = status;
[err errmsg] = checkStatusByte(status);
if err
    
    if nargout < 3
        % ignore error 64: "Specified mailbox queue is empty"
        if status ~= 64 
            % special error 236: "No active program"
            % received when indeed no program is running
            % apparently MessageRead only works when an NXC
            % program is running at the same time?!
            if status == 236
                warning('MATLAB:RWTHMindstormsNXT:messageReadWithNoActiveProgram', 'NXT_MessageRead was called while no program (NXT-G / NXC / NBC) is being executed on the NXT brick. Apparently, the direct command MessageRead will not work then. You can safely ignore this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:messageReadWithNoActiveProgram'')');
            else
                oldstate = DebugMode();
                DebugMode on; 
                % TODO It is probably better to display a real warning here instead
                % of a "debug" textOut message that will be deactivated most of the
                % time. However this is a very rare condition that should not occur
                % using correctly implemented protocol commands anyway.
                textOut(sprintf('Packet (reply to %s) contains error message %d: "%s"\n' ,commandbyte2name(cmd), status, errmsg));
                DebugMode(oldstate);
                % increase handle's error-count by 1
                handle.TransmissionErrors(1);
            end%if
        end%if
    end%if
    
    localInboxReturn = double(content(1));
    return
end%if

%% Intepret content 
localInboxReturn = double(content(1));
messageSize = content(2);

if (messageSize < 0) || (messageSize > 59) || (messageSize > length(content) - 2)
    warning('MATLAB:RWTHMindstormsNXT:MessageRead:invalidMessageSize', 'The received answer to MessageRead contains an invalid size. Discarding and trying to continue...');
end%if
    
message = char(content(3:1+messageSize)');

