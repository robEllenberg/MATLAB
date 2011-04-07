function [ timedOut ] = WaitFor( obj, timeout, handle)
% Wait for motor(s) to stop (busy waiting)
%
% Syntax
%     OBJ.WaitFor
%     TIMEDOUT = OBJ.WaitFor(TIMEOUT)
%
%     OBJ.WaitFor(HANDLE)
%     TIMEDOUT = OBJ.WaitFor(TIMEOUT, HANDLE)
%
%
% Description
%     OBJ.WaitFor waits for motor specified by OBJ to stop.
%     We do this by reading the motor state from the NXT 
%     brick repeatedly until controlled movement is finished. If the motor
%     is set to run infinitely, the method returns immediately and displays a 
%     warning.
%
%     TIMEDOUT = OBJ.WaitFor(TIMEOUT) does the
%     same as described above but has an additional timeout TIMEOUT (given
%     in seconds). After this time the function stops waiting and
%     returns true. Otherwise it returns false. This functionality is
%     useful to avoid that your robot (and your program) get stuck in case
%     the motor should somehow get stalled (e.g.by  driving against a wall).
%
%     Use HANDLE (optional) to identify the connection to use for this command. 
%
% Note:
%     If you specify TIMEOUT and the motor is not able to finish its
%     current movement command in time (maybe because the motor is blocked?),
%     waiting will be aborted. The motor is probably still busy in this
%     case, so you have to make sure it is ready to accept commands before
%     using it again (i.e. by calling .Stop()).
%
% Examples:
%
%        % If a SendToNXT command is immediately followed by a Stop
%        % command without using WaitFor MATLAB does not wait to send
%        % the stop command until the motor has finished its rotation.
%        % Thus, the motor does not rotate at all, since the stop command
%        % reaches the NXT before the motor starts its rotation due to
%        % its mechanical inertia.
%        motorA = NXTMotor('A', 'Power', 60, 'TachoLimit', 1000);
%        motorA.SendToNXT();
%        motorA.Stop('off');
%        % motor A barely moved at all...
%
%        % To avoid this issue, WaitFor has to be used!
%        motorC = NXTMotor('C', 'Power', -20, 'TachoLimit', 120);
%        motorC.SendToNXT();
%        motorC.WaitFor();
%        data = motorC.ReadFromNXT();
%
%        % Instantiate motor A and run it
%        m = NXTMotor('A', 'Power', 50, 'TachoLimit', 1000);
%        m.SendToNXT();
%        % Wait for the motor, try waiting for max. 10 seconds
%        timedOut = WaitFor(m, 10);
%        if timedOut
%            disp('Motor timed out, is it stalled?')
%            m.Stop('off'); % this needed to "unlock" the motor
%        end%if
%        % now we can send new motor commands again...
%
% See also: NXTMotor, ReadFromNXT, SendToNXT, Stop, StopMotor
%
%
% Signature
%   Author: Aulis Telle, Linus Atorf (see AUTHORS)
%   Date: 2009/07/20
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



%NOTE check if this works properly for two motors all the time?!

%TODO currently we sent a request to MotorControl, asking "is motor N
% ready", and get a reply "N yes" or "N no". We must keep on requesting
% messages to retrieve our answer: Send a message, get a message. Otherwise
% an old reply will be left in the outbox and not be collected by us.
% this is why we restart the NXC program every time a new handle is opened!
% still, to solve this, we could use a sort of ID in this request, and only
% react on/interpret messages with the correct ID in the reply...


%% initialize
    InboxNr = 1; % meant is the NXT's inbox (i.e. MATLAB's outbox if you will)
    OutboxNr = 0; % other way round again :-)

%% check input parameters
if ~isa(obj,'NXTMotor')
    error('MATLAB:RWTHMindstormsNXT:InvalidObject',...
        'No NXTMotor object.');
end

if ~exist('handle', 'var')
    handle = COM_GetDefaultNXT();
end%if

if ~(isfield(handle, 'UseNXCMotorControl') && handle.UseNXCMotorControl)
    error('MATLAB:RWTHMindstormsNXT:Motor:embeddedMotorControlRequiredForMotorClass', 'The class NXTMotor needs the embedded NXC program MotorControl to be running on the NXT, and according to the currently used NXT-handle, this program is not running. Make sure you download MotorControl.rxe (compile from MotorControl.nxc) to your brick and do not disable the automatic launch when calling COM_OpenNXTEx. Otherwise, you have to use the function DirectMotorCommand with limited functionality!')
end%if


if nargout > 0
    timedOut = 0;
end

if ~exist('timeout','var')
    timeout = 0;
elseif ~isscalar(timeout) || ~isnumeric(timeout)
    error('MATLAB:RWTHMindstormsNXT:invalidParameter', 'Given Timeout is not a number.');
end

%disp(sprintf('New WaitFor, Motor %d', obj.Port(1)));
%pause(0.1);


%% Check agains running infinitely
% get data from NXT
data = obj.ReadFromNXT(handle);
% the implicit nice side effect here is, that
% NXT_GetOutputState (called by ReadFromNXT) will wait
% for the NXC timestamp, which is a good thing

% check if motor is running forever
if data.TachoLimit == 0 && data.IsRunning
    warning('MATLAB:RWTHMindstormsNXT:Motor:ignoringWaitForWithNoTachoLimit',...
        'Motor %s seems to be running infinitely. Not waiting for this motor! Exiting WaitFor()...', char(65 + data.Port));
    return;
end


%% Actual waitfor-loop 

warned236 = false;
mTimedOut = false;
hGlobalTimeOut = tic();
hNXCReplyTimeOut = tic();

motorReady = false;
while(~motorReady)
    
    % request info from the NXC program:
    % #define PROTO_CONTROLLED_MOTORCMD       1 
    % #define PROTO_RESET_ERROR_CORRECTION    2
    % #define PROTO_ISMOTORREADY              3 <--
    % #define PROTO_CLASSIC_MOTORCMD          4
    % #define PROTO_JUMBOPACKET               5
    msg = sprintf('3%1d', obj.Port(1));
    NXT_MessageWrite(msg, InboxNr, handle);
    
    hMsgSent = tic();
    
    pause(0.001); % use this so CTRL + C can break into this loop and for the NXC task to relax a bit
    
    while(toc(hMsgSent) < 0.010)
        % waiting max 10ms
    end%while
    
    
    reply = '';
    while(isempty(reply))
        % this loop is to ALWAYS collect all packets we request!!)
        
        % request statusByte so that we don't get flooded with error msgs...
        [reply dummy statusByte] = NXT_MessageRead(OutboxNr, OutboxNr, true, handle);
        
        % ignore error 64
        if (statusByte ~= 0) && (statusByte ~= 64) % 64 = "Specified mailbox queue is empty"
            if (statusByte == 236) && (~warned236) % MATLAB:RWTHMindstormsNXT:messageReadWithNoActiveProgram
                warned236 = true;
                warning('MATLAB:RWTHMindstormsNXT:embeddedMotorControlSeemsTerminated', 'The embedded NXC program MotorControl should be running on the NXT brick. It seems the program is not running and/or was terminated accidentally. Please restart it or create a new NXT handle! Continuing...')
            end%if
            %NOTE we're ignoring all other errors here...
        end%if
        
        
        %disp(sprintf('    WaitFor, Motor %d, reply = %s', obj.Port(1), reply));
        

        if ~isempty(reply) % some sort of reply
            % remember when
            hNXCReplyTimeOut = tic();
            % interpret: first char is port, 2nd is state
            if strcmpi(reply(1), num2str(obj.Port(1))) && strcmpi(reply(2), '1')
                % done :-)
                motorReady = true;
                break;
            end%if
            % we discard all replies not matching our port num... security...
            
        else % no reply :-(
            if (toc(hNXCReplyTimeOut) > 5)
                warning('MATLAB:RWTHMindstormsNXT:noReplyFromEmbeddedMotorControlProgram', 'There has been no reply (time out) for at least 5 seconds from the embedded NXC program MotorControl, which should be running on the NXT brick. Please make sure the program is running and does not get terminated accidentally. Exiting WaitFor() and continuing...')
                mTimedOut = true;
                break;
            end%if
        end%if
        
        % don't put too much stress on the NXT with USB connections:
        if handle.ConnectionTypeValue == 1 % USB
            pause(0.010);
        end%if
        
    end%while

    % check if warning236 -> noReplyFromEmbedded... warning was triggered:
    if mTimedOut
        break
    end%if
    
    % check "global timeout"
    if (timeout ~= 0) && (toc(hGlobalTimeOut) > timeout)
        mTimedOut = true;
        break;
    end%if
    
end%while

% final relaxation pause...
pause(0.010);

% if output argument is requested
if exist('timedOut','var')
    timedOut = mTimedOut;
end%if
