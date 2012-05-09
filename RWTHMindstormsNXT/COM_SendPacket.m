function COM_SendPacket(Packet, handle)
% Sends a communication protocol packet (byte-array) via a USB or Bluetooth
%
% Syntax
%   COM_SendPacket(Packet, handle)
%
% Description
%   COM_SendPacket(Packet, handle) sends the given byte-array Packet (column vector),
%   (which can easily be created by the function COM_CreatePacket) over the USB or Bluetooth
%   channel specified by the given handle (struct) created by the function COM_OpenNXT or 
%   COM_OpenNXTEx, or obtained from COM_GetDefaultNXT. 
%
% Note:
%
%   In the case of a Bluetooth connection this function uses the specific settings from the
%   ini-file that was specified when opening the handle. Parameters used here are
%   SendSendPause and SendReceivePause, which will cause this function to wait a certain
%   amount of milliseconds between each consecutive send or receive operation to avoid packet
%   loss or buffer overflows inside the blutooth stack.
%
% Example
%   COM_MakeBTConfigFile();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%
%   [type cmd] = name2commandbytes('KEEPALIVE');
%   content = [];  % no payload in NXT command KEEPALIVE
%   packet = COM_CreatePacket(type, cmd, 'dontreply', content);
%
%   COM_SendPacket(packet, bt_handle);
%
% See also: COM_CreatePacket, COM_CollectPacket, COM_OpenNXT, COM_GetDefaultNXT, COM_MakeBTConfigFile
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


%% Check handle
    checkHandleStruct(handle)


%% Distinguish between connection types
    if handle.ConnectionTypeValue == 1 % USB

        if isdebug          
            try
                cmd = commandbyte2name(Packet(4));
            catch
                cmd = 'unknown / corrupt';
            end%if
            textOut(sprintf('Sending USB packet (%s), total len = %d bytes... ', cmd, length(Packet) - 2));
            textOut(sprintf('\n  USB packet: %s \n', horzcat(dec2hex(Packet(3:end), 2), blanks(length(Packet(3:end)))')'));
        end%if
        
        if (handle.OSValue == 1) || (handle.OSValue == 3) % Windows32 and Mac
            USB_SendAndCollectPacket_Windows(Packet(3:end), handle);
        else % Linux and Win64
            USB_SendPacket_Linux(Packet(3:end), handle);
        end%if
        
    else % Bluetooth
        BT_SendPacket(Packet, handle)
    end%if


end%function



%% --- FUNCTION BT_SendPacket
function BT_SendPacket(Packet, h)
% Sends a Bluetooth packet (byte-array) via a Bluetooth channel (serial port)
%
% Syntax
%   |BT_SendPacket(Packet, handle)|
%
% Description
%   |BT_SendPacket(Packet, handle)| sends the given byte-array |Packet| (column vector),
%   (which can easily be created by the function |BT_CreatePacket|) over the Bluetooth channel
%   specified by the given |handle| (PC system: serial handle, Linux system: file handle) created
%   by the function |BT_OpenHandle| or obtained from |BT_GetDefaultHandle|.
%
% Note
%   This function uses the specific Bluetooth settings from the ini-file
%   that was specified when opening the handle. Parameters used here are
%   |SendSendPause| and |SendReceivePause|, which will cause this function
%   to wait a certain amount of milliseconds between each consecutive send
%   or receive operation to avoid packet loss or buffer overflows inside
%   the blutooth stack.
%
% Example
%+   BT_MakeConfigFile();
%+
%+   bt_handle = BT_OpenHandle('bluetooth.ini');
%+
%+   [type cmd] = name2commandbytes('KEEPALIVE');
%+   content = [];  % no payload in NXT command KEEPALIVE
%+   packet = BT_CreatePacket(type, cmd, 'dontreply', content); 
%+
%+   BT_SendPacket(packet, bt_handle);
%
% See also: COM_CreatePacket, COM_CollectPacket, COM_OpenNXT, COM_OpenNXTEx
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
%   Copyright: 2007-2011, RWTH Aachen University
%


%TODO This complete BT_SendPacket function is crucial to bluetooth
% performance. It should be carefully analyzed and optimized. At the moment
% we use a "synchronous" or "blocking" concept. It might be worth looking
% into MATLAB's readasync() command to develop asynchronous / non-blocking
% bluetooth transmission functions!


% Check command byte
try
    cmd = commandbyte2name(Packet(4));
catch
    % we don't need a warning here, commandbyte2name would do that for us
    % if wanted... However:
    
    % TODO remove this try-catch structure and work out a proper warning
    % concept (warning raised in commandbyte2name OR here, but not in both
    % functions). Consider deactivating the whole "look up command bytes and
    % names in packets" thing and leaving it optional for debugging ->
    % performance improvement.
    cmd = 'unknown and strange';
end%try


%% Check if delay times are over
if ~isempty(h.LastSendTime())
    % check for send<->send pause
    % wait until ready to send again
    while (toc(h.LastSendTime()) < (h.SendSendPause / 1000))        
        %TODO add this pause below if CTRL+C breaking doesn't work great...
        % maybe add it only on Linux systems?
        %pause(0.001);
    end%while   
end%if

if ~isempty(h.LastReceiveTime())
    % check for receive<->send pause
    while (toc(h.LastReceiveTime()) < (h.SendReceivePause / 1000))        
        %TODO add this pause below if CTRL+C breaking doesn't work great...
        % maybe add it only on Linux systems?
        %pause(0.001);
    end%while    
end%if


%% Send bluetooth packet
textOut(sprintf('Sending BT packet (%s), total len = %d bytes... ', cmd , length(Packet)));
textOut(sprintf('\n  BT packet: %s \n', horzcat(dec2hex(Packet, 2), blanks(length(Packet))')'));
t = clock;
noError = true;
try
    fwrite(h.Handle(), Packet', 'uchar');
    textOut(sprintf(' done. (took %d ms)\n', ceil(etime(clock,t) * 1000)));
catch
    textOut(sprintf(' failed. (after %d ms)\n', ceil(etime(clock,t) * 1000)));
    noError = false;
end%try


%% Update sending time
    h.LastSendTime(tic);

    % statistics
    if noError
        h.PacketsSent(1);
        h.BytesSent(length(Packet));
    end%if
    
end%function


%% --- FUNCTION USB_SendPacket_Linux
function USB_SendPacket_Linux(packet, h)


    sendingEndpoint     = 1;
    %receivingEndpoint   = 130;  % hex2dec('82')
    timeout             = 1000; % ms
    %maxPacketSize       = 64;

    % be very careful to send uint8(packet) !!!!!!
    ret = calllib('libusb', 'usb_bulk_write', h.Handle(), sendingEndpoint, uint8(packet), length(packet), timeout);
    
    if ret < 0
        msg = ['Libusb error ' num2str(ret) ' while sending data: ' getLibusbErrorString(ret)];
        warning('MATLAB:RWTHMindstormsNXT:USB:Linux:libusbErrorWhileSendingData', msg);
    else % success
        h.PacketsSent(1);
        h.BytesSent(length(packet));
    end%if



end%function


%% --- FUNCTION USB_SendAndCollectPacket_Windows
function USB_SendAndCollectPacket_Windows(packet, h)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Temporary USB construction site for the RWTH - Mindstorms NXT Toolbox
%           http://www.mindstorms.rwth-aachen.de
%
% Based on the code by Vital van Reeven
%           http://forums.nxtasy.org/index.php?showtopic=2018
%           http://www.vitalvanreeven.nl/page156/fantomNXT.zip
%
% Linus Atorf, 29.3.2008
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


    NoReplyBit = 128; % hardcoded the old hex2dec('80') version for performance improvement
    % find out if packet requests a reply
    NeedReply = (bitand(packet(1), NoReplyBit) == 0);

    % preallocate reply buffer
    if NeedReply
        reply = uint8(zeros(getReplyLengthFromCmdByte(packet(2)), 1)); % need to know the reply packet size
    else
        reply = [];
    end%if

    % find out if we've got a system or direct command
    % remember: direct commands: 0x00, 0x80 (reply needed)
    %           system command:  0x01, 0x81 (reply needed)
    % so check the least significant bit
    if bitand(packet(1), 1) == 1
        % the reason: at the moment we cannot send system commands!
        warning('MATLAB:RWTHMindstormsNXT:notYetImplementedWarning', 'Cannot send system command (not yet implemented). At the moment only direct commands can be sent via USB on Windows. Use Bluetooth on Windows or Linux. Discarding packet, trying to continue...');        
        return
    end%if

    %FIXME Shouldn't it be "length(packet) - 1", because we only send packet(2:end) ???
    %FIXME Never touch a running system! Maybe it's ok because of the header/command byte?
    [whatever command reply status] = calllib('fantom', 'nFANTOM100_iNXT_sendDirectCommand', h.Handle(), NeedReply, packet(2:end)', length(packet), reply, length(reply), 0);

    % add packet to temporary queue here to process it later
    if NeedReply
        h.addtoReceivedPacketQueue(reply);
    end%if


    if status
        msg = ['VISA error ' num2str(status) ' while sending / receiving data: ' getVISAErrorString(status)];
        warning('MATLAB:RWTHMindstormsNXT:USB:Windows:VISAErrorWhileSendingData', msg);
    else % success
        h.PacketsSent(1);
        h.BytesSent(length(packet) - 1); % we actually sent packet(2:end)
    end%if

end%function