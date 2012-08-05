%% Example 6: Multi NXT support
% Use several NXTs at the same time
%
% This Example shows how you can use the Toolbox to controll several NXTs
% via USB and/or Bluetooth at the same time.
%
% Signature
%
% *  Author: Martin Staas
% *  Date: 2011/09/30
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de


%% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '4.05');
    error(strcat('This program requires the RWTH - Mindstorms NXT Toolbox ' ...
        ,'version 4.05 or greater. Go to http://www.mindstorms.rwth-aachen.de '...
        ,'and follow the installation instructions!'));
end%if

%% Prepare
COM_CloseNXT all
close all
clear all

%%
%
%% For this Example you have to Edit the MAC Adresses right below this text.

% NXT 1 (USB)
% Open NXT with given MAC via USB
NXT1.MAC = '00165302F0DD';
NXT1.connectionMode = 'USB';
NXT1.bluetoothIni = ''; %we don´t need a bluetooth.ini for an USB-Connection

% NXT 2 (Bluetooth)
% Open NXT with given information from "bluetooth1.ini" via Bluetooth
NXT2.MAC = '';
NXT2.connectionMode = 'Bluetooth';
NXT2.bluetoothIni = 'bluetooth1.ini';  
% use information from ini file (serial port information, Name or/and MAC 
% of NXT(using Bluetooth object from Intstrument Control Toolbox >= v3.0))

% NXT 3 (Bluetooth)
% Open NXT with given information from "bluetooth2.ini" and the given MAC
% via Bluetooth
NXT3.MAC = '0016530E7EDE'; 
%this information will only be used if you have a Windows 64Bit system 
%and the "Intstrument Control Toolbox" >= v3.0.
NXT3.connectionMode = 'Bluetooth';
NXT3.bluetoothIni = 'bluetooth2.ini'; 
% use information from ini file (serial port information, Name or/and MAC 
%of NXT (using Bluetooth object from Intstrument Control Toolbox >= v3.0))

% NXT 4 ... add as many as you want!


%% write all NXT-Handles into one array
handle(1) = COM_OpenNXTEx(NXT1.connectionMode,NXT1.MAC,NXT1.bluetoothIni);
handle(2) = COM_OpenNXTEx(NXT2.connectionMode,NXT2.MAC,NXT2.bluetoothIni);
handle(3) = COM_OpenNXTEx(NXT3.connectionMode,NXT3.MAC,NXT3.bluetoothIni);

%% Iterate all NXTs and play a tone
for n = 1:numel(handle)
    NXT_PlayTone(mod(450*n,7000),400,handle(n));
    pause(1);
end

%% close
COM_CloseNXT('all');