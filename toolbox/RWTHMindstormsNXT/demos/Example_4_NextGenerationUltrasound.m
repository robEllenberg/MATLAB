%% Example 4: Next Generation Ultrasound
% Example demonstrating the results of the ultrasound "snapshot mode"
%
% Interpretation of the results however is difficult.
%
% Just connect an NXT to the USB port, adjust the US port (or connect it to
% SENSOR_2), and see what's happening. The script will exit after 200
% measurements...
%
% Signature
%
% *  Author: Linus Atorf, Alexander Behrens
% *  Date: 2009/07/17
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de

%% Check toolbox installation
% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '2.00');
    error(strcat('This program requires the RWTH - Mindstorms NXT Toolbox ' ...
        ,'version 3.00 or greater. Go to http://www.mindstorms.rwth-aachen.de ' ...
        ,'and follow the installation instructions!'));
end%if


%% Clean up
% Close previous handles (if existing)
COM_CloseNXT all


%% Set up Matlab
close all
clear all
format compact


%% Set up ports
portUS      = SENSOR_4;


%% Get USB handle
h = COM_OpenNXT();
COM_SetDefaultNXT(h);


%% Prepare graphics
figure('name', 'Next Generation Ultrasound')
set(gca, 'Color', 'black');
hold on

%% Initialize
OpenUltrasonic(portUS, 'snapshot')

n          = 8;         % bytes the US sensor received
count      = 200;       % how many readings until end?
plotcols   = 8;         % how many out of n echos to plot?
outOfRange = 160;       % setting for out of range readings

colors = flipud(hot(8));

data = zeros(1, n); 
allX = (1:count+1)';

%% Measuring...
for i = 1 : count
    USMakeSnapshot(portUS)
    pause(0.05);            % wait for the sound to travel
    echos = USGetSnapshotResults(portUS);

    echos(echos == 255) = outOfRange;

    echos = [echos(1); diff(echos)];

    data = vertcat(data, echos');
    x = allX(1:i+1);
    
    clf
    hold on
    set(gca, 'Color', 'black');
    
    axis([0 count 0 outOfRange])

    for j = plotcols : -1 : 1
        area(x, data(:, j) , 'FaceColor', colors(j, :))
    end
    
end%for


%% Clean up
CloseSensor(portUS)
COM_CloseNXT(h);
