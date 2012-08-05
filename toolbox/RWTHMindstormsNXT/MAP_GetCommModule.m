function map = MAP_GetCommModule()
% Reads the IO map of the communication module
%  
% Syntax
%   map = MAP_GetCommModule()
%
% Description
%   map = MAP_GetCommModule() returns the IO map of the communication module. The return
%   value map is a struct variable. It contains all communication module information.  
%
% Output:
%     map.PFunc              % ?
%
%     map.PFuncTwo           % ?
%
%     map.BTPort             % 1x4 cell array contains Bluetooth device information of each
%                                NXT Bluetooth port (i = 0..3)
%
%     map.BTPort{i}.BtDeviceTableName            % name of the Bluetooth device
%
%     map.BTPort{i}.BtDeviceTableClassOfDevice   % class of the Bluetooth device
%
%     map.BTPort{i}.BtDeviceTableBdAddr          % MAC address of the Bluetooth device
%
%     map.BTPort{i}.BtDeviceTableDeviceStatus    % status of the Bluetooth device
%
%     map.BTPort{i}.BtConnectTableName           % name of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnectTableClassOfDevice  % class of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnectTablePinCode        % pin code of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnetTableBdAddr          % MAC address of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnectTableHandleNr       % handle nr of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnectTableStreamStatus   % stream status of the connected Bluetooth device
%
%     map.BTPort{i}.BtConnectTableLinkQuality    % link quality of the connected Bluetooth device
%
%     map.BrickDataName               % name of the NXT brick
%
%     map.BrickDataBluecoreVersion    % Bluecore version number
%
%     map.BrickDataBdAddr             % MAC address of the NXT brick
%
%     map.BrickDataBtStateStatus      % Bluetooth state status
%
%     map.BrickDataBtHwStatus         % NXT hardware status
%
%     map.BrickDataTimeOutValue       % time out value
%
%     map.BtDeviceCnt                 % number of devices defined within the Bluetooth device table
%
%     map.BtDeviceNameCnt             % number of devices defined within the Bluetooth device table
%                                        (usually equal to BtDeviceCnt)
%
%     map.HsFlags                     % High Speed flags
%
%     map.HsSpeed                     % High Speed speed
%
%     map.HsState                     % High Speed state
%
%     map.HsSpeed                     % High Speed speed
%
%     map.UsbState                    % USB state
%
% Examples
%   map = MAP_GetCommModule();
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
% Comm Module Offsets                       Value           Size
% CommOffsetPFunc                           0               4
% CommOffsetPFuncTwo                        4               4
% CommOffsetBtDeviceTableName(p)            (((p)*31)+8)    16
% CommOffsetBtDeviceTableClassOfDevice(p)   (((p)*31)+24)   4
% CommOffsetBtDeviceTableBdAddr(p)          (((p)*31)+28)   7
% CommOffsetBtDeviceTableDeviceStatus(p)    (((p)*31)+35)   1
% CommOffsetBtConnectTableName(p)           (((p)*47)+938)  16
% CommOffsetBtConnectTableClassOfDevice (p) (((p)*47)+954)  4
% CommOffsetBtConnectTablePinCode(p)        (((p)*47)+958)  16
% CommOffsetBtConnectTableBdAddr(p)         (((p)*47)+974)  7
% CommOffsetBtConnectTableHandleNr(p)       (((p)*47)+981)  1
% CommOffsetBtConnectTableStreamStatus(p)   (((p)*47)+982)  1
% CommOffsetBtConnectTableLinkQuality(p)    (((p)*47)+983)  1
% CommOffsetBrickDataName                   1126            16
% CommOffsetBrickDataBluecoreVersion        1142            2
%
% CommOffsetBrickDataBdAddr                 1144            7
% CommOffsetBrickDataBtStateStatus          1151            1
% CommOffsetBrickDataBtHwStatus             1152            1
% CommOffsetBrickDataTimeOutValue           1153            1
%
% CommOffsetBtInBufBuf                      1157 128
% CommOffsetBtInBufInPtr                    1285 1
% CommOffsetBtInBufOutPtr                   1286 1
% CommOffsetBtOutBufBuf                     1289 128
% CommOffsetBtOutBufInPtr                   1417 1
% CommOffsetBtOutBufOutPtr                  1418 1
%
% CommOffsetHsInBufBuf                      1421 128
% CommOffsetHsInBufInPtr                    1549 1
% CommOffsetHsInBufOutPtr                   1550 1
% CommOffsetHsOutBufBuf                     1553 128
% CommOffsetHsOutBufInPtr                   1681 1
% CommOffsetHsOutBufOutPtr                  1682 1
%
% CommOffsetUsbInBufBuf                     1685 64
% CommOffsetUsbInBufInPtr                   1749 1
% CommOffsetUsbInBufOutPtr                  1750 1
% CommOffsetUsbOutBufBuf                    1753 64
% CommOffsetUsbOutBufInPtr                  1817 1
% CommOffsetUsbOutBufOutPtr                 1818 1
% CommOffsetUsbPollBufBuf                   1821 64
% CommOffsetUsbPollBufInPtr                 1885 1
% CommOffsetUsbPollBufOutPtr                1886 1
%
% CommOffsetBtDeviceCnt                     1889            1
% CommOffsetBtDeviceNameCnt                 1890            1
% CommOffsetHsFlags                         1891            1
% CommOffsetHsSpeed                         1892            1
% CommOffsetHsState                         1893            1
% CommOffsetUsbState                        1894            1

%% Set Module ID
    CommModuleID = 327681; %hex2dec('00050001');

    
%% Get Module Map in Bytes
    % return values of the user interface module
    bytes = NXT_ReadIOMap(CommModuleID, 0, 8);

    
%% Build Map Structure
    map.PFunc               = wordbytes2dec(bytes(1:4), 4); %unsigned
    map.PFuncTwo            = wordbytes2dec(bytes(5:8), 4); %unsigned


    % the following command is not working. The maximal returned number of bytes seems to be
    % limited to 119. 
    % bytes = NXT_ReadIOMap(CommModuleID, 0, 1144);

    % for each Bluetooth port get Bluetooth device table information
    for p = 0:3
        bytes = NXT_ReadIOMap(CommModuleID, p*31, 36);
        map.BTPort{p+1}.BtDeviceTableName           = char(bytes(9:24)');
        map.BTPort{p+1}.BtDeviceTableClassOfDevice  = bytes(25:28)'; %wordbytes2dec(bytes(25:28), 4);
        add = dec2hex(bytes(29:35),2); add = add';
        map.BTPort{p+1}.BtDeviceTableBdAddr         = sprintf('%s:%s:%s:%s:%s:%s:%s',add(1:2), add(3:4), add(5:6), add(7:8), add(9:10), add(11:12), add(13:14));
        map.BTPort{p+1}.BtDeviceTableDeviceStatus   = byte2devicestatus(bytes(36));
    end
    
    % for each Bluetoothport get connected device information
    for p = 0:3
        bytes = NXT_ReadIOMap(CommModuleID, p*47+938, 46);
          map.BTPort{p+1}.BtConnectTableName          = char(bytes(1:16)');
          map.BTPort{p+1}.BtConnectTableClassOfDevice = bytes(17:20)';
          map.BTPort{p+1}.BtConnectTablePinCode       = bytes(21:36)';
          add = dec2hex(bytes(37:43),2); add = add';
          map.BTPort{p+1}.BtConnetTableBdAddr         = sprintf('%s:%s:%s:%s:%s:%s:%s',add(1:2), add(3:4), add(5:6), add(7:8), add(9:10), add(11:12), add(13:14));
          map.BTPort{p+1}.BtConnectTableHandleNr      = bytes(44);
          map.BTPort{p+1}.BtConnectTableStreamStatus  = bytes(45);
          map.BTPort{p+1}.BtConnectTableLinkQuality   = bytes(46);
    end

    % get NXT brick information
    bytes = NXT_ReadIOMap(CommModuleID, 1126, 28);
    map.BrickDataName               = char(bytes(1:16)'); 
    map.BrickDataBluecoreVersion    = [num2str(wordbytes2dec(bytes(18),1)) '.' sprintf('%02d',wordbytes2dec(bytes(17),1))];
    add = dec2hex(bytes(19:25),2); add = add';
    map.BrickDataBdAddr             = sprintf('%s:%s:%s:%s:%s:%s:%s',add(1:2), add(3:4), add(5:6), add(7:8), add(9:10), add(11:12), add(13:14));
    map.BrickDataBtStateStatus      = byte2btstatestatus(bytes(26));
    map.BrickDataBtHwStatus         = byte2bthwstatus(bytes(27));
    map.BrickDataTimeOutValue       = bytes(28);
     
   % get additional information
    bytes = NXT_ReadIOMap(CommModuleID, 1889, 6);
    map.BtDeviceCnt                 = bytes(1);
    map.BtDeviceNameCnt             = bytes(2);
    map.HsFlags                     = byte2hsflags(bytes(3));
    map.HsSpeed                     = bytes(4);
    map.HsState                     = byte2hsstate(bytes(5));
    map.UsbState                    = byte2usbstate(bytes(6));
    
%% Get Buffer Information (not implemented yet)
%     bytes = NXT_ReadIOMap(CommModuleID, 1157, 100);
%     Note: only 119 bytes can be read at the same time. why?
%     
%     bytes = [bytes' NXT_ReadIOMap(CommModuleID, 1257, 28)'];
%     map.BtInBufBuf                  = bytes;
%     ...
end



function name = byte2devicestatus(byte)
    switch byte
        case 0
            name = 'EMPTY';
        case 1
            name = 'UNKNOWN';
        case 2
            name ='KNOWN';
        case 64
            name = 'NAME';
        case 128
            name = 'AWAY';
        otherwise
    end
end

function name = byte2btstatestatus(byte)
    name = [];
    if  bitget(byte, 1) == 1, name = [name 'BRICK_VISIBILITY ']; end
    if  bitget(byte, 2) == 1, name = [name 'BRICK_OPEN_PORT ']; end
    if  bitget(byte, 5) == 1, name = [name 'CONNECTION_0_ENABLE ']; end
    if  bitget(byte, 6) == 1, name = [name 'CONNECTION_1_ENABLE ']; end
    if  bitget(byte, 7) == 1, name = [name 'CONNECTION_2_ENABLE ']; end
    if  bitget(byte, 8) == 1, name = [name 'CONNECTION_3_ENABLE ']; end
end

% function name = byte2btstate(byte)
%     switch byte
%         case 0
%             name = 'OFF';
%         case 1
%             name = 'CMD_MODE';
%         case 2
%             name = 'DATA_MODE';
%         otherwise
%             name = '';
%     end
% end

function name = byte2bthwstatus(byte)
    switch byte
        case 0
            name = 'ENABLE';
        case 1
            name = 'DISABLE';
    end
end

function name = byte2hsflags(byte)
    switch byte
        case 1
            name = 'UPDATE';
        otherwise
            name = '';
    end
end

function name = byte2hsstate(byte)
    switch byte
        case 1
            name = 'INITIALISE';
        case 2
            name = 'INIT_RECEIVER';
        case 3
            name = 'SEND_DATA';
        case 4
            name = 'DISABLE';
        otherwise
            name = '';
    end
end

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
