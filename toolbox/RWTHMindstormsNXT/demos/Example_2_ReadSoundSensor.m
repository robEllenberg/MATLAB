%% Example 2: Read Sound Sensor
% Example to read the sound sensor value in dB
%
% Signature
%
% *  Author: Linus Atorf, Alexander Behrens
% *  Date: 2009/07/17
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de

% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '2.00');
    error(strcat('This program requires the RWTH - Mindstorms NXT Toolbox ' ...
        ,'version 2.00 or greater. Go to http://www.mindstorms.rwth-aachen.de' ...
        ,' and follow the installation instructions!'));
end%if


% Close previous handles (if existing)
COM_CloseNXT all
% Prepare workspace by cleaning all old settings to be on the safe side. 
close all
clear all


% Open new NXT Bluetooth connection according to the previously generated
% configuration file. You can use COM_MakeBTConfigFile for this step.
% Please note that a USB connection will be used if one is present. If no
% USB device is found, the Bluetooth configuration file will be used.
handle = COM_OpenNXT('bluetooth.ini');

% Set current NXT handle as default for subsequent toolbox function calls
COM_SetDefaultNXT(handle);

% Initialize the sound sensor by setting the sound sensor mode and input port. 
OpenSound(SENSOR_2, 'DB');

% Get the current sound sensor value in dB. 
value = GetSound(SENSOR_2)

% Close the sound sensor. 
CloseSensor(SENSOR_2);

% Close Bluetooth connection. 
COM_CloseNXT(handle);