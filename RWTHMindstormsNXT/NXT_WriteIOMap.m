function NXT_WriteIOMap(mod_id, offset, n_bytes, data, varargin)
% Writes the IO map to the given module ID
%  
% Syntax
%   NXT_WriteIOMap(mod_id, offset, n_bytes, data)
%
%   NXT_WriteIOMap(mod_id, offset, n_bytes, data, handle)
%
% Description
%   NXT_WriteIOMap(mod_id, offset, n_bytes, data) write the data bytes to the given module ID (mod_id).
%   The total number of bytes is given by n_bytes. The offset parameter determines the index
%   position of the first byte.
%
%   NXT_WriteIOMap(mod_id, offset, n_bytes, data, handle) sends the IO map write command
%   over the specific NXT handle handle (e.g. serial handle (PC) / file handle (Linux)).
%
%   If no NXT handle is specified the default one (COM_GetDefaultNXT) is used.
%
% For more details see the official LEGO Mindstorms communication protocol.
%
% Examples
%   OutputModuleID = 131073
%   NXT_WriteIOMap(OutputModuleID, 0, 30, bytes;
%
%   handle = COM_OpenNXT('bluetooth.ini');
%   OutputModuleID = 131073
%   NXT_WriteIOMap(OutputModuleID, 0, 30, bytes, handle);
%
% See also: NXT_ReadIOMap, COM_GetDefaultNXT
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/22
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
% check if number of input parameters are valid
if nargin < 4
    error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter','4 parameter are needed (module id, offset (first byte position), n_bytes (number of bytes to write), data to write'); 
end

% check if bluetooth handle is given; if not use default one
if nargin > 4
    if (ispc && isa(varargin{1}, 'serial')) || (isunix && isscalar(varargin{1}))
        handle = varargin{1};
    else
        error('MATLAB:RWTHMindstormsNXT:Bluetooth:invalidHandle', 'Optional NXT bluetooth handle specified, but not a valid serial port handle');
    end%if
else
    handle = COM_GetDefaultNXT;
end%if

% check offset parameter
if offset < 0
    error('MATLAB:RWTHMindstormsNXT:invalidModuleOffset','Offset byte has to be positive!'); 
end

% check number of bytes to read
if n_bytes <= 0
    error('MATLAB:RWTHMindstormsNXT:invalidModuleParameter','Number of total bytes to read has to be > 0!'); 
end

% check module IDs
% CommandModuleID  = 65537;  %hex2dec('00010001');
% OutputModuleID   = 131073; %hex2dec('00020001');
% InputModuleID    = 196609; %hex2dec('00030001');
% ButtonModuleID   = 262145; %hex2dec('00040001');
% CommModuleID     = 327681; %hex2dec('00050001');
% IOCtrlModuleID   = 393217; %hex2dec('00060001');
% SoundModuleID    = 524289; %hex2dec('00080001');
% LoaderModuleID   = 589825; %hex2dec('00090001');
% DisplayModuleID  = 655361; %hex2dec('000A0001');
% LowSpeedModuleID = 720897; %hex2dec('000B0001');
% UIModuleID       = 786433; %hex2dec('000C0001');
if (mod(mod_id-1, 65536) ~= 0) || (mod_id == 458753)
    warning('MATLAB:RWTHMindstormsNXT:unknownModuleID','Unknown module ID! Please reference to the known module ID list in this file.');
end


%% Build bluetooth command
[type cmd] = name2commandbytes('WRITE_IO_MAP');

content(1:4) = dec2wordbytes(mod_id, 4);
content(5:6) = dec2wordbytes(offset, 2);
content(7:8) = dec2wordbytes(n_bytes, 2);
content(9:9+n_bytes-1)  = dec2wordbytes(data, 1);


%% Pack bluetooth packet
packet = COM_CreatePacket(type, cmd, 'reply', content); 
textOut(sprintf('+ Write IO Map'));


%% Send bluetooth packet
COM_SendPacket(packet, handle);

[type cmd status content] = COM_CollectPacket(handle);

%mod_id   = content(1:4);
%n_bytes = content(5:6);

end%function
