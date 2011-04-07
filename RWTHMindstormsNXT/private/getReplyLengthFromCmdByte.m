function len = getReplyLengthFromCmdByte(byte)
% Simple lookup, retrieves length of reply packet to specific command
%
% Syntax
%   len = getReplyLengthFromCmdByte(byte)
%
% Description
%   This private helper function returns the number of bytes to expect 
%   inside a reply packet to a certain direct command. The first byte,
%   ("type") does not count (it is always 0x02 = "reply"). The 2 following
%   bytes, ("reply to what command" and the statuscode) do count, so a
%   reply is at least 2 bytes long.
%   
%   This information is needed by USB communication functions.
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/06/01
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



%% Check parameter 
% not needed anymore it seems, since this function now should also support
% system commands
% if (byte < 0) || (byte > 20)
%     % the warning below is correct, direct commands that need replies are
%     % indeed between bytes 0 and 20, but system commands are different,
%     % so we do not use this warning at the moment!
%     %warning('MATLAB:RWTHMindstormsNXT:invalidCommandByte', 'CommandByte must be between 0 and 20, trying to continue...');
%     
%     % no reply needed means length = 0, but this might change when
%     % implementing NXT_GetFirmwareVersion correctly...
%     len = 0;
%     return
% end%if

% init with an ok default value...
replylen = ones(255, 1) .* 2;

%% set for direct commands...
replylen(1:20) = [2 2 2 2 2 2 24 15 2 2 2 4 2 6 3 2 19 22 0 63];

% replylen(1)  = 2;    % NXT__STARTPROGRAM           = [0; 0];   %#ok<NASGU> %hex2dec(['00'; '00']);
% replylen(2)  = 2;    % NXT__STOPPROGRAM            = [0; 1];   %#ok<NASGU> %hex2dec(['00'; '01']);
% replylen(3)  = 2;    % NXT__PLAYSOUNDFILE          = [0; 2];   %#ok<NASGU> %hex2dec(['00'; '02']);
% replylen(4)  = 2;    % NXT__PLAYTONE               = [0; 3];   %#ok<NASGU> %hex2dec(['00'; '03']);
% replylen(5)  = 2;    % NXT__SETOUTPUTSTATE         = [0; 4];   %#ok<NASGU> %hex2dec(['00'; '04']);
% replylen(6)  = 2;    % NXT__SETINPUTMODE           = [0; 5];   %#ok<NASGU> %hex2dec(['00'; '05']);
% replylen(7)  = 24;   % NXT__GETOUTPUTSTATE         = [0; 6];   %#ok<NASGU> %hex2dec(['00'; '06']);
% replylen(8)  = 15;   % NXT__GETINPUTVALUES         = [0; 7];   %#ok<NASGU> %hex2dec(['00'; '07']);
% replylen(9)  = 2;    % NXT__RESETINPUTSCALEDVALUE  = [0; 8];   %#ok<NASGU> %hex2dec(['00'; '08']);
% replylen(10) = 2;    % NXT__MESSAGEWRITE           = [0; 9];   %#ok<NASGU> %hex2dec(['00'; '09']);
% replylen(11) = 2;    % NXT__RESETMOTORPOSITION     = [0; 10];  %#ok<NASGU> %hex2dec(['00'; '0A']);
% replylen(12) = 4;    % NXT__GETBATTERYLEVEL        = [0; 11];  %#ok<NASGU> %hex2dec(['00'; '0B']);
% replylen(13) = 2;    % NXT__STOPSOUNDPLAYBACK      = [0; 12];  %#ok<NASGU> %hex2dec(['00'; '0C']);
% replylen(14) = 6;    % NXT__KEEPALIVE              = [0; 13];  %#ok<NASGU> %hex2dec(['00'; '0D']);
% replylen(15) = 3;    % NXT__LSGETSTATUS            = [0; 14];  %#ok<NASGU> %hex2dec(['00'; '0E']);
% replylen(16) = 2;    % NXT__LSWRITE                = [0; 15];  %#ok<NASGU> %hex2dec(['00'; '0F']);
% replylen(17) = 19;   % NXT__LSREAD                 = [0; 16];  %#ok<NASGU> %hex2dec(['00'; '10']);
% replylen(18) = 22;   % NXT__GETCURRENTPROGRAMNAME  = [0; 17];  %#ok<NASGU> %hex2dec(['00'; '11']);
% replylen(20) = 63;   % NXT__MESSAGEREAD            = [0; 19];  %#ok<NASGU> %hex2dec(['00'; '13']);


%% some system commands

replylen(137)   =  6;      % GET_FIRMWARE_VERSION
%already inited...
%replylen(153) = 2;      % SET_BRICK_NAME
replylen(156)   = 32;      % GET_DEVICE_INFO
replylen(149)   = 8;     % WRITE_IO_MAP


len = replylen(byte + 1);


