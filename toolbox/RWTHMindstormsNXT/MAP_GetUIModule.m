function map = MAP_GetUIModule()
% Reads the IO map of the user interface module
%  
% Syntax
%   map = MAP_GetUIModule()
%
% Description
%   map = MAP_GetUIModule() returns the IO map of the user interface module. The return
%   value map is a struct variable. It contains all user interface module information.  
%
% Output:
%     map.PMenu              % ?
%
%     map.BatteryVoltage     % battery voltage in mili volt. 
%
%     map.LMSfilename        % ?
%
%     map.Flags              % flag bitfield
%
%     map.State              % state value
%
%     map.Button             % button value
%
%     map.RunState           % VM run state
%
%     map.BatteryState       % battery level (0..4)
%
%     map.BluetoothState     % bluetooth state bitfield
%
%     map.UsbState           % USB state
%
%     map.SleepTimout        % sleep timeout value in minutes
%
%     map.SleepTimer         % current sleep timer in minutes
%
%     map.Rechargeable       % true if reachargeable battery is used
%
%     map.Volume             % volume level (0..4)
%
%     map.Error              % error value
%
%     map.OBPPointer         % on brick program pointer
%
%     map.ForceOff           % turn off brick if value is true
%
%
% Examples
%   map = MAP_GetUIModule();
%
% See also: NXT_ReadIOMap
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/23
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

% Information provided by
% Not eXactly C (NXC) Programmer's Guide 
% Version 1.0.1 b33, October 10, 2007
% by John Hansen
% http://bricxcc.sourceforge.net/nbc/nxcdoc/NXC_Guide.pdf
% - - - - - - - - - - - - - - - - - - - - - - - - - - 
% UI Module Offsets       Value    Size
% UIOffsetPMenu             0       4
% UIOffsetBatteryVoltage    4       2
% UIOffsetLMSfilename       6       20
% UIOffsetFlags             26      1
% UIOffsetState             27      1
% UIOffsetButton            28      1
% UIOffsetRunState          29      1
% UIOffsetBatteryState      30      1
% UIOffsetBluetoothState    31      1
% UIOffsetUsbState          32      1
% UIOffsetSleepTimeout      33      1
% UIOffsetSleepTimer        34      1
% UIOffsetRechargeable      35      1
% UIOffsetVolume            36      1
% UIOffsetError             37      1
% UIOffsetOBPPointer        38      1
% UIOffsetForceOff          39      1


%% Get UI Module Map
UIModuleID = 786433; %hex2dec('000C0001');

    % return values of the user interface module
    bytes = NXT_ReadIOMap(UIModuleID, 0, 40);

    map.PMenu               = wordbytes2dec(bytes(1:4), 4); %unsigned
    map.BatteryVoltage      = wordbytes2dec(bytes(5:6), 2); %unsigned
    map.LMSfilename         = bytes(7:26); 
    map.Flags               = bytes(27);
    map.State               = bytes(28);
    map.Button              = bytes(29);
    map.RunState            = bytes(30);
    map.BatteryState        = bytes(31);
    map.BluetoothState      = byte2btstate(bytes(32));
    map.UsbState            = byte2usbstate(bytes(33));
    map.SleepTimeout        = bytes(34);
    map.SleepTimer          = bytes(35);
    map.Rechargeable        = bytes(36);
    map.Volume              = bytes(37);
    map.Error               = bytes(38);
    map.OBPPointer          = bytes(39);
    map.ForceOff            = bytes(40);

end


function name = byte2btstate(byte)
    name = [];
    if bitget(byte, 1), name = [name 'VISIBLE ']; end
    if bitget(byte, 2), name = [name 'CONNECTED ']; end
    if bitget(byte, 3), name = [name 'OFF ']; end
    if bitget(byte, 4), name = [name 'ATTENTION ']; end
    if bitget(byte, 7), name = [name 'CONNECT_REQUEST ']; end
    if bitget(byte, 8), name = [name 'PIN_REQUEST ']; end
    
end

% function name = byte2timeout(byte)
%     if byte == 0
%         name = 'never';
%     else
%         name = sprintf('%d min',byte);
%     end
% end

% function name = byte2timer(byte)
%     name = sprintf('%d min',byte);
% end

function name = byte2usbstate(byte)
    switch byte
        case 0
            name = 'disconnected';
        case 1
            name = 'connected';
        case 2
            name = 'working';
    end
end

% function name = byte2batterystate(byte)
%     name = sprintf('%d/4', byte);
% end

% function name = byte2volume(byte)
%     name = sprintf('%d/4', byte);
% end
