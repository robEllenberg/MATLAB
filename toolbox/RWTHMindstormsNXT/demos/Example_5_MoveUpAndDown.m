%% Example 5: Move up and down
% Make a motor precisely move back and forth 10 times
%
% Example which moves a motor (or robotic arm) 10 times back and
% forth (up and down), as precisely as possible without blindly trusting
% the motor commands. Very simple error compensation (i.e. trying absolute
% movements instead of always relative).
%
% Signature
%
% *  Author: Linus Atorf
% *  Date: 2009/10/05
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de

%%
%

% Now let's imagine we want to control a robotic arm. For the sake of this
% example, we want it to move up and down, alternatingly for 10 times. Let
% the arm just have one joint, so we only control one motor. A little
% problem is gravity: The arm has a certain weight. So if we aren't
% careful, moving it downwards will sometimes result in a little lower
% position than we expect, and moving upwards won't move the motor as far
% as we hope all the time. After all, the motor control is only accurate to
% a couple of degrees (+/- 1 most of the time, but not necessarily equally
% distributed). So without reading the motor's position and accounting for
% those inaccuracies, the errors would accumulate over time and cause a
% significant displacement of the arm. By simply retrieving the arm's
% position and making sure that it moves a bit more upwards if necessary,
% or a bit less downwards, we can avoid the accumulating errors and have
% precise movement even after a long period of operation. Here is how its
% done:

% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '4.01');
    error(strcat('This program requires the RWTH - Mindstorms NXT Toolbox ' ...
    ,'version 4.01 or greater. Go to http://www.mindstorms.rwth-aachen.de ' ...
    ,'and follow the installation instructions!'));
end%if


%% Prepare
COM_CloseNXT all
close all
clear all

%% Connect to NXT, via USB or BT
h = COM_OpenNXT('bluetooth.ini');
COM_SetDefaultNXT(h);

%% Set params
power = 100;
port  = MOTOR_A;
dist  = 180;    % distance to move in degrees

%% Create motor objects
% we use holdbrake, make sense for robotic arms
mUp    = NXTMotor(port, 'Power',  power, 'ActionAtTachoLimit', 'HoldBrake');
mDown  = NXTMotor(port, 'Power', -power, 'ActionAtTachoLimit', 'HoldBrake');

%% Prepare motor
mUp.Stop('off');
mUp.ResetPosition();

%% Main movement (repeat 10 times)
for j=1:10
    
    % where are we?
    data = mUp.ReadFromNXT();
    pos  = data.Position;
    
    % where do we want to go?
    % account for errors, i.e. if pos is not 0
    mDown.TachoLimit = dist + pos;
    
    % move
    mDown.SendToNXT();
    mDown.WaitFor();
    
    % now we are at the bottom, repeat the game:
    % where are we?
    data = mUp.ReadFromNXT(); % doesn't matter which object we use to read!
    pos  = data.Position;
    
    % pos SHOULD be = dist in an ideal world
    % but calculate new "real" distance to move
    % based on current error...    
    % but avoid negative values!
    mUp.TachoLimit = abs(pos);
    % this looks very simple now, but it comes from
    %   TachoLimit = dist + (pos - dist);
    % i.e. real distance + error correction
    % Imagine it this way: We are currently at pos,
    % and want to go back to 0, so this is exactly the distance
    % to go! And then only take abs, because power takes care of the sign
    
    mUp.SendToNXT();
    mUp.WaitFor();
    
end%for

%% Clean up
% mode was HOLDBRAKE, so don't forget this:
mUp.Stop('off');
COM_CloseNXT(h);