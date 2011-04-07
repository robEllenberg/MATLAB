function h = createHandleStruct()
% Main part of the toolbox's NXT handle concept, creates a handle
%
% Syntax
%   h = createHandleStruct()
%
% Description
%   Various information concerning the NXT brick and the toolbox's way of
%   communicating with it is stored inside this handle: Bluetooth and USB
%   parameters, the actual handle to the hardware drivers, but also data
%   about the current motor status and transmission statistics.
%
%   To store dynamic information, we create this struct with function
%   handles to nested functions of this m-file, using the concept of
%   function closures. They enable us to keep variables as if they were
%   global or persistent, and work around the limitation of MATLAB that
%   passing variables/objects by reference is not possible...
%
%   For documentation of the provided "member functions" (function handles
%   to nested functions) see either this sourcecode or the "RWTH -
%   Mindstorms NXT Toolbox Developer's Guide" document (to be published)
% 
% Notes
%   Special thanks to Eckhard Lehmann (The MathWorks, Germany) for pointing
%   out and explaining the concept of function closures in MATLAB, as well
%   as thanks to Jim Hunziker for his example on this topic (from MATLAB
%   Central File Exchange).
%   Another good introductory example can be found here (especially comments
%   #3 and #6):
%   http://blogs.mathworks.com/loren/2007/08/09/a-way-to-create-reusable-tools
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/01
%   Copyright: 2007-2010, RWTH Aachen University
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
 
%% Initialize member variables
    % we store "private" member information in variables, here prefixed
    % with v_. Due to function closures, they will keep their state for
    % each handle "object".
    
    v_Handle = [];
    
    v_BytesSent = 0;
    v_BytesReceived = 0;
    v_PacketsSent = 0;
    v_PacketsReceived = 0;
    v_TransmissionErrors = 0;
    
    v_LastSendTime = [];
    v_LastReceiveTime = [];
    
    v_NXTMOTOR_State = initializeGlobalMotorStateVar();
    v_NXTMOTOR_CurrentMotor = NaN;
    
    v_ReceivedPacketQueue = [];
    
    % init gyro sensor offset to hardcoded default value
    % tested with two different devices, offset was 592 and 597,
    % the internet says defaults are around 600. we use 595
    % doesnt really matter anyway, but better to have a fitting default
    % value than a totally wrong one
    % format: 1st column offsets, 2nd column flag if already calibrated
    v_GyroSensorOffset = [ones(4,1) * 595, zeros(4, 1)];
    % format: [nearDist nearEOPD; farDist farEOPD] 
    tmpNaN = [NaN NaN; NaN NaN];
    v_EOPDSensorMatrix = {tmpNaN tmpNaN tmpNaN tmpNaN};
    
    v_LastGetUSTime = [tic; tic; tic; tic];
    
    v_Connected = false;
    
    
%% Create & initialize handle struct
    % Here we use the struct's fields for the first time.
    % Whenever we've got dynamic information, we will set the field
    % to its according function handle, that can later be called from the
    % outside...
    

    h.OSName                = '';  % String, 'Windows' or 'Linux'
    h.OSValue            	= NaN; % Windows = 1, Linux = 2
    h.ConnectionTypeName    = '';  % String, 'USB' or 'Bluetooth'
    h.ConnectionTypeValue 	= NaN; % USB = 1, Bluetooth = 2

    h.Handle                = @ActualHandle;  % actual handle to driver / serial ...

    % Infos taken from bluetooth.ini file
    h.IniFilename           = '';
    h.ComPort               = '';
    h.BaudRate            	= NaN;
    h.DataBits            	= NaN;
    h.Timeout             	= NaN;

    h.SendSendPause       	= NaN;
    h.SendReceivePause      = NaN;

    % Timestamps needed for automatic wait-time between consecutive
    % bluetooth-data transmissions
    h.LastSendTime        	= @LastSendTime;
    h.LastReceiveTime     	= @LastReceiveTime;

    % NXT info, Name might be added in the future
    %h.NXTName               = '';
    h.NXTMAC                = '';

    % NXTMOTOR_State is its own struct to store information about the 3
    % motors of each NXT. Needed for functions like SetPower etc, to
    % automatically form 2 packets when working with synchronized motors,
    % but also to keep state in certain circumstances...
    h.NXTMOTOR_getState    	= @NXTMOTOR_getState;
    h.NXTMOTOR_setState    	= @NXTMOTOR_setState;
    h.NXTMOTOR_resetRegulationState  = @NXTMOTOR_resetRegulationState;
    h.NXTMOTOR_getCurrentMotor = @NXTMOTOR_getCurrentMotor;
    h.NXTMOTOR_setCurrentMotor = @NXTMOTOR_setCurrentMotor;
    
    % In Windows-USB (Fantom), we cannot transmit and receive packets
    % seperately. Whenever we send a direct command, we directly get the
    % reply packet at once. To emulate (or "fake") they way how we send and
    % collect packets in different functions, we create this queue that
    % temporarily stores data until we collect them (think of it as a
    % classic read-buffer for serial connections)
    h.getReceivedPacketQueue    = @getReceivedPacketQueue;
    h.setReceivedPacketQueue    = @setReceivedPacketQueue;
    h.addtoReceivedPacketQueue  = @addtoReceivedPacketQueue;

    % The HiTechnic Gyro sensor needs to be calibrated manually.
    % The offset must be stored inside the handle (for each NXT, and for
    % each sensor). 
    h.GyroSensorOffset = @GyroSensorOffset;
    % similar to Gyro calibration, we store EOPD calibration values
    h.EOPDSensorMatrix = @EOPDSensorMatrix;
    
    % avoid polling the US too frequently
    h.LastGetUSTime    = @LastGetUSTime;
    
    
    % Statistics! We update these packet and byte counters when
    % appropriate. If performance is an issue, we could leave this out, but
    % it might be very comfortable to have this easy overview about packet
    % rate and data rate...
    h.BytesSent           	= @BytesSent;
    h.BytesReceived       	= @BytesReceived;
    h.PacketsSent         	= @PacketsSent;
    h.PacketsReceived     	= @PacketsReceived;
    % Transmission error is defined as a reply packet containing a
    % statusbyte ~= 0. The only exception is I2C traffic, where we
    % sometimes except those packet-error-messages (usually
    % DontCheckStatusByte is then set to true for COM_CollectPacket)
    h.TransmissionErrors  	= @TransmissionErrors;

    % Creation-Time is just a gimmick, timestamp how old this handle is
    h.CreationTime       	= NaN;
    % We need this flag, it basically signals success or failure of
    % connection establishment
    h.Connected             = @Connected;
    
    % An index to a global cell-array of all handles ever constructed. We
    % keep track of them ("keep a copy") so that COM_CloseNXT('all') can
    % really close all outstanding USB handles...
    h.Index                 = NaN;
    
    h.DeleteMe              = @DeleteMe;
    
    h.UseNXCMotorControl    = 0;
    
%% *** Statistics functions
% They either return the current value or INCREMENT it by the specified
% value, so h.BytesSent(5) will add 5 sent bytes (not set to 5!).

%% --- NESTED FUNCTION BytesSent
    function ret = BytesSent(n)
        if nargin == 1
            v_BytesSent = v_BytesSent + n;
        end
        ret = v_BytesSent;
    end%function

%% --- NESTED FUNCTION BytesReceived
    function ret = BytesReceived(n)
        if nargin == 1
            v_BytesReceived = v_BytesReceived + n;
        end
        ret = v_BytesReceived;
    end%function

%% --- NESTED FUNCTION PacketsSent
    function ret = PacketsSent(n)
        if nargin == 1
            v_PacketsSent = v_PacketsSent + n;
        end
        ret = v_PacketsSent;
    end%function

%% --- NESTED FUNCTION PacketsReceived
    function ret = PacketsReceived(n)
        if nargin == 1
            v_PacketsReceived = v_PacketsReceived + n;
        end
        ret = v_PacketsReceived;
    end%function

%% --- NESTED FUNCTION TransmissionErrors
    function ret = TransmissionErrors(n)
        if nargin == 1
            v_TransmissionErrors = v_TransmissionErrors + n;
        end
        ret = v_TransmissionErrors;
    end%function

%% *** Connected flag
%% --- NESTED FUNCTION Connected
    function ret = Connected(n)
        if nargin == 1
            v_Connected = n;
        end
        ret = v_Connected;
    end%function

%% *** Bluetooth send- and receive-timestamps
%% --- NESTED FUNCTION LastSendTime
    function ret = LastSendTime(in)
        if nargin == 1
            v_LastSendTime = in;
        end
        ret = v_LastSendTime;
    end%function

%% --- NESTED FUNCTION LastReceiveTime
    function ret = LastReceiveTime(in)
        if nargin == 1
            v_LastReceiveTime = in;
        end
        ret = v_LastReceiveTime;
    end%function

%% *** The actual handle-value (for fantom/libusb etc.)
%% --- NESTED FUNCTION ActualHandle
    function ret = ActualHandle(hIn)
        if nargin == 1
            v_Handle = hIn;
        end%if
        ret = v_Handle;
    end%function

%% *** Windows-USB (Fantom) receive queue management
% These functions provide easy access to modify the queue. Of course one
% could've done this with one single function, but I chose these 3 variants
% for performance reasons (all very simple and hence fast)!

%% --- NESTED FUNCTION getReceivedPacketQueue
    function ret = getReceivedPacketQueue()
        ret = v_ReceivedPacketQueue;
    end%function

%% --- NESTED FUNCTION setReceivedPacketQueue
    function setReceivedPacketQueue(in)
        v_ReceivedPacketQueue = in;
    end%function

%% --- NESTED FUNCTION addtoReceivedPacketQueue
    function addtoReceivedPacketQueue(in)
        v_ReceivedPacketQueue = vertcat(v_ReceivedPacketQueue, in);
    end%function

%% *** NXT Motor State struct
% What was formerly a single global variable is now attached to the handle.
% Since the struct is not exactly small, performance is an issue here, but
% this is the most obvious, easy to follow implementation...

%% --- NESTED FUNCTION NXTMOTOR_getState
    function ret = NXTMOTOR_getState()
        ret = v_NXTMOTOR_State;
    end%function

%% --- NESTED FUNCTION NXTMOTOR_setState
    function NXTMOTOR_setState(in)
        v_NXTMOTOR_State = in;
    end%function

%% --- NESTED FUNCTION NXTMOTOR_resetRegulationState
    function NXTMOTOR_resetRegulationState(motor)
        % formerly known as resetMotorRegulation.m
        
        if motor ~= 255
            
            % note the usage of index + 1, it is necessary!!
            if v_NXTMOTOR_State(motor + 1).SyncedToMotor ~= -1
                % reset the synced-to motor as well
                v_NXTMOTOR_State(v_NXTMOTOR_State(motor + 1).SyncedToMotor + 1).SyncedToMotor = -1;
                v_NXTMOTOR_State(motor + 1).SyncedToMotor = -1;
            end%if

            v_NXTMOTOR_State(motor + 1).SyncedToSpeed = false;    

        else % == 255

            for motor = 0 : 2 % 0 : 2 because we add 1 later down

                % note the usage of index + 1, it is necessary!!    
                if v_NXTMOTOR_State(motor + 1).SyncedToMotor ~= -1
                    % reset the synced-to motor as well
                    v_NXTMOTOR_State(v_NXTMOTOR_State(motor + 1).SyncedToMotor + 1).SyncedToMotor = -1;
                    v_NXTMOTOR_State(motor + 1).SyncedToMotor = -1;
                end%if

                v_NXTMOTOR_State(motor + 1).SyncedToSpeed = false;    

            end%for
        end%if

    end%function


%% *** Current Active Motor (for highlevel motor functions)
% We use this as fast internal handler (quicker than global vars) instead
% of GetMotor and SetMotor...

%% --- NESTED FUNCTION NXTMOTOR_getCurrentMotor
    function ret = NXTMOTOR_getCurrentMotor()
        if isnan(v_NXTMOTOR_CurrentMotor)
            error('MATLAB:RWTHMindstormsNXT:Motor:noMotorSet', 'Current motor number not set, must use SetMotor() first. Or did you accidently use CLEAR?');
        end%if
        ret = v_NXTMOTOR_CurrentMotor;
    end%function

%% --- NESTED FUNCTION NXTMOTOR_setCurrentMotor
    function NXTMOTOR_setCurrentMotor(n)
        v_NXTMOTOR_CurrentMotor = n;
    end%function


%% --- NESTED FUNCTION GyroSensorOffset
    function ret = GyroSensorOffset(port, offset)
        if nargin > 1
            v_GyroSensorOffset(port+1, 1) = offset;
            v_GyroSensorOffset(port+1, 2) = true;            
        end%if
        ret = v_GyroSensorOffset(port+1, :);
    end%function


%% --- NESTED FUNCTION EOPDSensorMatrix
    function ret = EOPDSensorMatrix(port, matrix)
        if nargin > 1
            v_EOPDSensorMatrix{port+1} = matrix;
        end%if
        ret = v_EOPDSensorMatrix{port+1};
    end%function


%% --- NESTED FUNCTION LastGetUSTime
    function ret = LastGetUSTime(in)
        if nargin == 1
            v_LastGetUSTime = in;
        end
        ret = v_LastGetUSTime;
    end%function



%% *** Clean up
% Since we cannot delete all external "outside" references (function handles)
% to these internal nested functions, we have to free the memory by using
% clear in here...
% See here, review Nr. 6:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=18223&objectType=file

%% --- NESTED FUNCTION DeleteMe
    function DeleteMe
        % retrieve local vars of this workspace and clear them
        vars = who;
        clear(vars{:});
        h = [];
    end%function
end%function