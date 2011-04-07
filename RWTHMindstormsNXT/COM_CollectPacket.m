function [type cmd statusbyte content] = COM_CollectPacket(handle, varargin)
% Reads data from a USB or serial/Bluetooth port, retrieves exactly one packet
%
% Syntax
%   [type cmd statusbyte content] = COM_CollectPacket(handle)
%
%   [type cmd statusbyte content] = COM_CollectPacket(handle, 'dontcheck')
%
% Description
%   [type cmd statusbyte content] = COM_CollectPacket(handle) reads one packet on the communication
%   channel specified by the handle struct (PC system: handle struct containing e.g. serial
%   handle, Linux system: handle struct containing file handle). The USB / Bluetooth handle
%   struct can be obtained by the COM_OpenNXT or COM_GetDefaultNXT  command. The return
%   value type specifies the telegram type according to the LEGO Mindstorms communication
%   protcol. The cmd value determines the specific command. status indicates if an error
%   occured on the NXT brick. The function checkStatusByte is interpreting this information
%   per default. The content column vector represents the remaining payload of the whole return packet. E.g. it 
%   contains the current battery level in milli volts, that then has to be converted to a valid
%   integer from its byte representation (i.e. using wordbytes2dec). 
%
%   [type cmd statusbyte content] = COM_CollectPacket(handle, 'dontcheck') disables the validation
%   check of the status value by function checkStatusBytes.
%
%               varargin : set to 'dontcheck' if the status byte should not
%                          automatically be checked. Only use this if you
%                          expect error messages. Possible usage is for
%                          LSGetStatus, where this can happen...
%
%   For more details about the syntax of the return packet see the LEGO Mindstorms communication protocol.
%
% Note:
%
%   This function uses the specific Bluetooth settings from the ini-file
%   that was specified when opening the handle. Parameters used here are
%   SendSendPause and SendReceivePause, which will cause this function
%   to wait a certain amount of milliseconds between each consecutive send
%   or receive operation to avoid packet loss or buffer overflows inside
%   the blutooth stack.
%
% Example
%   COM_MakeBTConfigFile();
%
%   handle = COM_OpenNXT('bluetooth.ini');
%
%   [type cmd] = name2commandbytes('KEEPALIVE');
%   content = [];  % no payload in NXT command KEEPALIVE
%   packet = COM_CreatePacket(type, cmd, 'reply', content);
%
%   COM_SendPacket(packet, handle);
%
%   [type cmd statusbyte content] = COM_CollectPacket(handle);
%   % Now you could check the statusbyte or interpret the content.
%   % Or maybe check for valid type and cmd before...
%
% See also: COM_CreatePacket, COM_SendPacket, COM_OpenNXT, COM_GetDefaultNXT,
% COM_MakeBTConfigFile, checkStatusByte
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/08/31
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
   
%% Check handle
    checkHandleStruct(handle);
    

%% Parse varargin
    CheckStatusByte = true;
    if nargin > 1
        if ischar(varargin{1}) && strcmpi(varargin{1}, 'dontcheck')
            CheckStatusByte = false;
        end%if
    end%if

%% Collect!

    if handle.ConnectionTypeValue == 1 % USB
        if (handle.OSValue == 1) || (handle.OSValue == 3) % Windows and Mac
            [type cmd statusbyte content] = USB_CollectPacket_Windows(handle);
        else % Linux
            [type cmd statusbyte content] = USB_CollectPacket_Linux(handle);
        end%if
    else % BT
        [type cmd statusbyte content] = BT_CollectPacket(handle);
    end%if
        
%% Convert uints to double

% note that we leave content untouched!
    type        = double(type);
    cmd         = double(cmd);
    statusbyte  = double(statusbyte);
    
    
%% Check status byte
    if CheckStatusByte
        [err errmsg] = checkStatusByte(statusbyte);

        % only display warning / error if desired
        if err 
            oldstate = DebugMode();
            DebugMode on; 
            % TODO It is probably better to display a real warning here instead
            % of a "debug" textOut message that will be deactivated most of the
            % time. However this is a very rare condition that should not occur
            % using correctly implemented protocol commands anyway.
            textOut(sprintf('Packet (reply to %s) contains error message %d: "%s"\n' ,commandbyte2name(cmd), statusbyte, errmsg));
            DebugMode(oldstate);
            % increase handle's error-count by 1
            handle.TransmissionErrors(1);
        end%if
    end%if

end%function


%% --- FUNCTION BT_CollectPacket
function [type cmd statusbyte content] = BT_CollectPacket(h)
% Reads data from serial/Bluetooth port and retrieves exactly one packet
%
% Syntax
%   |[type cmd statusbyte content] = BT_CollectPacket(handle)|
%
%   |[type cmd statusbyte content] = BT_CollectPacket(handle, 'dontcheck')|
%
% Description
%   |[type cmd statusbyte content] = BT_CollectPacket(handle)| reads one packet on the communication
%   channel specified by the Bluetooth |handle| (PC system: serial handle, Linux system: file
%   handle). The Bluetooth handle can be obtained by the |BT_OpenHandle| or |BT_GetDefaultHandle| 
%   command. The return value |type| specifies the telegram type according to the LEGO Mindstorms
%   communication protcol. The |cmd| value determines the specific command. |status| indicates if an
%   error occured on the NXT brick. The function |checkStatusByte| is interpreting this information per default.
%   The |content| column vector represents the remaining payload of the whole return packet. E.g. it
%   contains the current battery level in milli volts, that then has to be converted to a valid integer from
%    its byte representation (i.e. using |wordbytes2dec|).
%
%   |[type cmd statusbyte content] = BT_CollectPacket(handle, 'dontcheck')| disables the validation
%   check of the |status| value by function |checkStatusBytes|.
%
%               varargin : set to 'dontcheck' if the status byte should not
%                          automatically be checked. Only use this if you
%                          expect error messages. Possible usage is for
%                          LSGetStatus, where this can happen...
%
%   For more details about the syntax of the return packet see the LEGO Mindstorms communication protocol.
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
%+   packet = BT_CreatePacket(type, cmd, 'reply', content); 
%+
%+   BT_SendPacket(packet, bt_handle);
%+
%+   [type cmd statusbyte content] = BT_CollectPacket(bt_handle); 
%+   % Now you could check the statusbyte or interpret the content.
%+   % Or maybe check for valid type and cmd before...
%
% See also: COM_CreatePacket, COM_SendPacket, COM_OpenHandle,
%   BT_GetDefaultHandle, BT_MakeConfigFile, checkStatusByte, wordbytes2dec
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
%   Copyright: 2007-2010, RWTH Aachen University
%


%TODO This complete BT_CollectPacket function is crucial to bluetooth
% performance. It should be carefully analyzed and optimized. At the moment
% we use a "synchronous" or "blocking" concept. It might be worth looking
% into MATLAB's readasync() command to develop asynchronous / non-blocking
% bluetooth transmission functions!




%% Initalize Variables
    % statusbyte = 1 is a marker we use for "empty packet", if it stay like
    % this, it'll cause checkStatusByte to display an error message...
    % same goes for cmd = 255, as cmd = 0 means STARTPROGRAM
    type = 0; cmd = 255; statusbyte = 1; content = [];

    textOut('Collecting BT packet ');
    
    
    
%% Check if transfer status is busy
    timeout = 1000; % in ms to wait for data
    
    if h.OSValue == 1 % WINDOWS ONLY
        t = clock;
        % ------- This apparently never really happens, but we have this security
        % "wait time" anyway to make sure we don't "stress" the bluetooth adapter
        % when its not possible anyway...
        tmpSerial = h.Handle();
        while ~strcmpi(tmpSerial.TransferStatus, 'idle') && (etime(clock,t) * 1000) < timeout
            % wait for bluetooth-adapter to get ready 
        end%while

        if (etime(clock,t) * 1000) > 5
            textOut(sprintf('(waited %d ms) ', ceil(etime(clock,t) * 1000)));
        end%if
        % --------    
    end%if

%% Check if delay times are over
    % -------- Now our more sophisticated automatic wait time...

    if ~isempty(h.LastSendTime())
        % check for send<->receive pause
        while (toc(h.LastSendTime()) < (h.SendReceivePause / 1000))        
            %TODO add this pause below if CTRL+C breaking doesn't work great...
            % maybe add it only on Linux systems?
            %pause(0.001);
        end%while
    end%if

    % --------

%% Read bluetooth packet length
    t = clock;
    
    PayloadLenBytes = fread(h.Handle(), 2, 'uchar');
    
    %TODO: check length(PayloadLenBytes)! If < 2, ERROR OR WARNING here!
    %      or maybe just return here, without doing "any damage" (aka
    %      ignore missing data). Will have to test & evaluate later.
    %      UPDATE: It seems that the above mentioned check may not be the
    %      best solution after all. When calling fread() with a certain
    %      amount of n bytes to read, it will wait the specified time out
    %      period until data has arrived. If not we get the warning
    %      mentioned below. The whole concept has to be carefully tweaked
    %      or maybe even adapted for high-quality and low-quality bluetooth
    %      environments...
    %
    %NOTE Note that we get a message on the command window from fread() 
    %     when this happens. It's not a "real" warning, but it says:
    %     "Warning: The specified amount of data was not returned within the Timeout period."
    %
    % Basically we can say at this point, that the bluetooth connection is
    % not working properly, if BT_CollectPacket() was called correctly
    % (after a packet was requested). This also seems the point where
    % packet loss can occur (or already HAS occured, and we can detect it).
    % Also fread() seems to hang (aka wait) the specified TimeOut period,
    % until it continues execution. If no data has arrived until then, we
    % get this "Warning: ..." message printed...

    %TODO by checking the following condition, we might be able to detect if a
    %Bluetooth connection is already "closed" (i.e. NXT is turned off),
    %when the handle is still valid. This is something we would otherwise
    %never catch. So with careful redesign of error messages, this could be
    %pointed out to the user...
    if (length(PayloadLenBytes) < 2) 
        % new change, LA, 11.9.2008
        % Problem: if we issue a warning here, it will always show up when
        % BT_OpenHandle (from COM_OpenNXTEx) can't connect. And that looks
        % nasty inside the command window. So we check if this happens
        % during connection establishing phase, and only then show the
        % warning.
        % This really was a problem, since a whole chain of warnings
        % would've otherwise confusd the user...
        
        if  ~h.Connected()
            warning('MATLAB:RWTHMindstormsNXT:Bluetooth:incompletePacketData', ...
            ['Received packet not complete yet, there are less bytes available ' ...
             'than expected. This is due to a bluetooth lag. You might want to ' ... 
             'try changing the Timeout period setting inside the inifile. On ' ...
             'slow machines you could also increase the SendReceivePause ' ...
             'setting or disable this warning.'])
             return;
        else
            % We have to create an error now. This function gets called
            % during connecting-phase from NXT_KeepAlive. We put that
            % statement into a try-catch block, so some sort of error is
            % needed to indicate failure. If we don't do anything now,
            % wordbytes2dec will fail with an empty PayloadLenBytes (just
            % in case no BT connection can be opened). This did the trick
            % until now, but it is better to raise an explicit error here
            % (we never know how "robust" wordbytes2dec may get, and it
            % would be stupid to rely on its crashing/error)...
            error('MATLAB:RWTHMindstormsNXT:Bluetooth:emptyPacket', 'No packet was received or the received packet is empty.');
        end%if
    end%if
    
    PayloadLen = wordbytes2dec(PayloadLenBytes, 2);
    textOut(sprintf('(PayloadLen = %d, ', PayloadLen));

    if PayloadLen < 3
        textOut(sprintf('packet seems too short)... done??? (took %d ms)\n', ceil(etime(clock,t) * 1000)));
        return;
    end%if 
    

%% Read actual bluetooth packet

    if h.OSValue == 1 % WINDOWS code for SERIAL PORT VERSION ---------------------------
        tmpSerial = h.Handle();
        if tmpSerial.BytesAvailable < PayloadLen 
            warning('MATLAB:RWTHMindstormsNXT:Bluetooth:incompletePacketData', ...
                    ['Received packet not complete yet, there are less bytes available ' ...
                     'than expected. This is due to a bluetooth lag. You might want to ' ... 
                     'try changing the Timeout period setting inside the inifile. On ' ...
                     'slow machines you could also increase the SendReceivePause ' ...
                     'setting or disable this warning.'])
        end%if
    end%if
        
    packet = fread(h.Handle(), PayloadLen, 'uchar'); %NOTE is uchar cool? is uint8 maybe less ambigous?



%% Interpret content

    type = packet(1);
    cmd = packet(2);
    statusbyte = packet(3);

    content = packet(4:PayloadLen);

    if type == 2, typedesc = 'reply'; else typedesc = 'something (but not a reply)'; end
    cmddesc = commandbyte2name(cmd);
    textOut(sprintf('%s to %s)... ', typedesc, cmddesc));
    textOut(sprintf('done. (took %d ms)\n', ceil(etime(clock,t) * 1000)));

%% Update last receiving time

    h.LastReceiveTime(tic);
    
%% Statistics

    h.BytesReceived(PayloadLen + 2);
    h.PacketsReceived(1);
    
end%function


%% --- FUNCTION USB_CollectPacket_Windows
function [type cmd statusbyte content] = USB_CollectPacket_Windows(h)

%% Initalize Variables
    % for explanation on values, see above
    cmd = 255; statusbyte = 1; content = [];

    % hardcode reply-byte, needed later down.
    % pretty useless, but since right now we are emulating/faking BT
    % packets, that's what we do...
    type = 2;

    ReceivedPacketQueue = h.getReceivedPacketQueue();

%% Do receiving emulation (collect from queue)
    if isempty(ReceivedPacketQueue)
        % nothing we can do here, will probably crash later, but let's try to
        % continue
        warning('MATLAB:RWTHMindstormsNXT:USB:Windows:receiveQueueEmpty', 'The USB received-packet-queue is empty, but you are trying to collect a packet. Ignoring this and moving on...')
        return
    else

        cmd = ReceivedPacketQueue(1);
        len = getReplyLengthFromCmdByte(cmd);
        
        if len > length(ReceivedPacketQueue)
            % nothing good can happen, but maybe it's a problem for only one
            % packet, let's try to continue
            len = length(ReceivedPacketQueue);
            warning('MATLAB:RWTHMindstormsNXT:USB:Windows:receivedPacketIncomplete', 'The USB received-packet-queue does not contain enough data. Current packet seems incomplete...')
        end%if
        
        packet = ReceivedPacketQueue(1:len);
        
        if length(ReceivedPacketQueue) > len
            % delete the current one we took
            h.setReceivedPacketQueue(ReceivedPacketQueue(len+1:end));
        else
            % got the last packet, only one
            h.setReceivedPacketQueue([]);
        end%if
                
    end%if
        
    % statistics
    h.PacketsReceived(1);
    h.BytesReceived(len);
    
    
%% Interpret content
    
    % remember we already set type = 2
    cmd = packet(1);
    statusbyte = packet(2);

    content = packet(3:end);

    
end%function


%% --- FUNCTION USB_CollectPacket_Linux
function [type cmd statusbyte content] = USB_CollectPacket_Linux(h)

%% Libusb params
    %sendingEndpoint     = 1;
    receivingEndpoint   = 130;  % hex2dec('82')
    timeout             = 1000; % ms
    maxPacketSize       = 64;


%% Initalize Variables
    % for explanation on values, see above
    type = 0; cmd = 255; statusbyte = 1; content = [];

%% Retrieve data
    % Various tests were necessary to find out how exactly data retrieval works
    % with usb_bulk_read from libusb in MATLAB. The problem is that this libusb
    % function uses a zero-terminated "string" (char-array) as data type for real
    % binary data. Now MATLAB is very nice and converts this for us, back to a
    % real string data type in MATLAB. But, only until the first 0 gets
    % discovered, after all it's a zero-terminated string. So, after the first 0
    % inside the packet, we don't get any data. I've worked around this at the
    % moment by changing the datatype in the original .h header file, which is the
    % template / master for the prototype m-file. 
    
    %buffer = blanks(maxPacketSize);
    %buffer = uint8(zeros(getReplyLengthFromCmdByte(packet(2)), 1));
    %buffer = [blanks(maxPacketSize - 1) 0];
    %buffer = uint8(zeros(maxPacketSize, 1));
    buffer = uint8(zeros(maxPacketSize, 1));
    
      
    %[ret something reply] = calllib('libusb', 'usb_bulk_read', hNXT, receivingEndpoint, char(buffer'), length(buffer), timeout);    
    [status something reply] = calllib('libusb', 'usb_bulk_read', h.Handle(), receivingEndpoint, buffer, length(buffer), timeout);    
    if status < 0
        msg = ['Libusb error ' num2str(status) ' while receiving data: ' getLibusbErrorString(status)];
        warning('MATLAB:RWTHMindstormsNXT:USB:Windows:libusbErrorWhileReceivingData', msg);
    end%if

        
%% Interpret content

    if length(reply) < 2
        % basically we've lost, nothing we can do anymore...
        warning('MATLAB:RWTHMindstormsNXT:USB:Linux:receivedPacketIncomplete', 'The received packet does not contain enough data. Current packet seems incomplete...')
        return
    end%if

    cmd = reply(2);
    
    % we can only use the private helper function getReplyLengthFromCmdByte
    % for those packets with static well known lengths. for the case of
    % ReadIOMap, we peek inside the packet to read the amount of following
    % bytes...
    if (cmd == 148) % special case for READ IO MAP
        % retrieve length from READ IO MAP package
        %TODO check if package is at least 9 bytes long?
        len = 9 + wordbytes2dec(reply(8:9), 2) ;
    else
        len = getReplyLengthFromCmdByte(cmd) + 1;
    end%if
    
    
    if length(reply) < len
        % this won't end good, but let's try to continue
        len = length(reply);        
        warning('MATLAB:RWTHMindstormsNXT:USB:Linux:receivedPacketIncomplete', 'The received packet does not contain enough data. Current packet seems incomplete...')
    end%if
    
    % extract packet from reply (which might be padded)
    packet = reply(1:len);
    
    % statistics
    h.PacketsReceived(1);
    h.BytesReceived(len);
    
    
%% Interpret content

    % note that we return uint8, NOT double!
    % this is what the other functions (BT, fantom) do as well!

    type = packet(1);
    cmd = packet(2);
    statusbyte = packet(3);

    content = packet(4:end);

    %TODO please check if content has to be made double!
    
end%function


