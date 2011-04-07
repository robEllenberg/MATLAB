function [status SleepTimeLimit] = NXT_SendKeepAlive(ReplyMode, varargin)
% Sends a KeepAlive packet. Optional: requests sleep time limit.
%  
% Syntax
%   [status SleepTimeLimit] = NXT_SendKeepAlive(ReplyMode) 
%
%   [status SleepTimeLimit] = NXT_SendKeepAlive(ReplyMode, handle)
%
% Description
%   [status SleepTimeLimit] = NXT_SendKeepAlive(ReplyMode) sends a KeepAlive packet to the NXT
%   Brick to get the current sleep time limit of the Brick in milliseconds. By the ReplyMode
%   one can request an acknowledgement for the packet transmission. The two strings 'reply' and
%   'dontreply' are valid. status indicates if an error occures by the packet transmission.
%   Function checkStatusBytes is interpreting this information per default. The value
%   SleepTimeLimit contains the time in milliseconds after the NXT brick will turn off
%   automatically. The variable will only be set if ReplyMode is 'reply'. The sleep time limit
%   setting can only  be modified using the on-screen-menu on the brick itself.
%
%   Using 'dontreply' will just send a keep-alive packet. This means, the NXT internal counter when
%   to shut down automatically (this is a setting that can only be accessed directly on the NXT)
%   will be reset. This counter is not an inactivity counter: Bluetooth traffic will NOT stop the
%   NXT from turning off. E.g. if the sleep limit is set to 10 minutes, the only way to keep the NXT
%   Brick from turning off is to send a keep-alive packet within this time.
%
%   If you use replymode 'reply', SleepTimeLimit tells you the current setting on the brick, in
%   milliseconds. 0 means sleep timer is disabled. -1 is an invalid answer: You obviously didn't use
%   'reply' and still tried to get an answer.
% 
%   [status SleepTimeLimit] = NXT_SendKeepAlive(ReplyMode, handle) uses the given NXT
%   connection handle. This should be a struct containing a serial handle on a PC system and a file handle on a Linux
%   system. 
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
%   For more details see the official LEGO Mindstorms communication protocol.
%
% Note:
%   This function is also called by COM_OpenNXT(). Then a keep-alive packet is send and the
%   answer will be received to check for a correctly working bidirectional bluetooth connection.
%
% Examples
%   [status SleepTimeLimit] = NXT_SendKeepAlive('reply');
%
%   NXT_SendKeepAlive('dontreply');
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   [status SleepTimeLimit] = NXT_SendKeepAlive('reply', handle);
%
% See also: COM_OpenNXT, NXT_GetBatteryLevel
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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

%% Parameter check
% check if bluetooth handle is given. if not use default one
if nargin > 1
        handle = varargin{1};
else
    handle = COM_GetDefaultNXT;
end%if


%% Build bluetooth command
[type cmd] = name2commandbytes('KEEPALIVE');


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, ReplyMode, []);
%textOut(sprintf('+ Sending keep alive packet...\n'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);


%% Collect bluetooth packet if reply 
if strcmpi(ReplyMode, 'reply')

    % find out expected cmd
    [dontcare ExpectedCmd] = name2commandbytes('KEEPALIVE');
    
    % Collect bluetooth packet
    [type cmd status content] = COM_CollectPacket(handle);

    % check status
    if (cmd ~= ExpectedCmd) || (status ~= 0)
        warning('MATLAB:RWTHMindstormsNXT:Bluetooth:discardingUnexpectedPacket', 'Received packed not expected. Discarding and trying to continue...');
        SleepTimeLimit = 0;
        return
    end%if
    
    SleepTimeLimit = wordbytes2dec(content, 4);
    
else
    status = 0;
    SleepTimeLimit = -1;
end%if

end%function
