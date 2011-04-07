%% Example 1: Play Tone and Get Battery Level
% Example to play a tone on the brick and retrieve the current battery level: 
%
% Signature
%
% *  Author: Linus Atorf, Alexander Behrens
% *  Date: 2009/07/17
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de

% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '2.00');
    error('This program requires the RWTH - Mindstorms NXT Toolbox version 2.00 or greater. Go to http://www.mindstorms.rwth-aachen.de and follow the installation instructions!');
end%if


% Close previous handles (if existing)
COM_CloseNXT all
% Prepare workspace by cleaning all old settings to be on the safe side. 
clear all
close all

% Open new NXT connection 
%  - Tries to open a connection via USB. The first NXT device that is found will be used.
%  - Device drivers (Fantom on Windows, libusb on Linux) have to be already installed for USB to work.
%  - For using Bluetooth a previous configuration file has to be generated COM_MakeBTConfigFile)
%  - This call will not try to open a Bluetooth connection...
handle = COM_OpenNXT();
% at this place we could call COM_SetDefaultNXT(handle);

% Play tone with frequency 800Hz and duration of 500ms. 
NXT_PlayTone(800,500, handle);

% Get current battery level. 
voltage = NXT_GetBatteryLevel(handle)

% Close NXT connection. 
COM_CloseNXT(handle);