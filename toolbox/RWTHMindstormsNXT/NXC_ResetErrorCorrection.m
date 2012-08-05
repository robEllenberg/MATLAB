function NXC_ResetErrorCorrection(port, handle)
% Sends reset error correction command to the NXC-program MotorControl on the NXT
%
% Syntax
%   NXC_ResetErrorCorrection(port)
%
%   NXC_ResetErrorCorrection(port, handle)
%
% Description
%   The NXC-program "MotorControl" must be running on the brick, otherwise
%   this function will not work. It is used to sent advanced motor commands
%   to the NXT that can perform better and more precise motor regulation
%   than possible with only classic direct commands.
%
%   This function resets the "internal error correction memory" for the
%   according motor. Usually, you cannot move the NXT motors by hand in
%   between two commands that control the motors, since the modified motor
%   position does not match the internal counters any more. This leads to
%   unexpected motor behaviour (when the NXT firmware tries to correct the
%   manual movements you just made). _The problem described here does not occur when
%   working with the NXTMotor class._
%
%   To work around this problem, it is possible to reset the error
%   correction counter by hand using this function. It will clear the
%   counter TachoCount, since this counter is internally attached to the
%   error correction. The counter BlockTachoCount (see direct commands
%   specification of the LEGO Mindstorms Bluetooth Developer Kit) will also
%   be reset (since it is used to coordinate multiple motors during
%   synchronous driving).
%
%   It is recommended to call this function before using classic direct
%   commands (i.e. like NXT_SetOutputState), to get the intuitively
%   expected results.
%
% Input:
%   port has to be a port number between 0 and 2. It can also be an array
%   of valid port-numbers, i.e. [0; 1], [0; 2], [1; 2] or [0; 1;
%   2]. The named constants MOTOR_A to MOTOR_C can be used for clarity
%   (i.e. port = [MOTOR_A; MOTOR_B].
%
%   handle is optional and determines the NXT handle to be used, if
%   specified. Otherwise the default handle will be used (set using
%   COM_SetDefaultNXT).
%
%
% Limitations
%   This function is intended for advanced users. It makes no sense to use
%   it together with the NXTMotor class. It can however be useful in
%   between certain DirectMotorCommand calls.
%
%
% Example
% % This will reset the TachoCount counter for port A on the NXT, which
% % also resets the error correction
% NXC_ResetErrorCorrection(MOTOR_A);
% % Now MOTOR_A behaves as if the NXT was freshly booted up...
% % The "personal" position counter (field Position when calling
% % a motor object's method ReadFromNXT()) won't be affected through this
% % -- it will stay untouched until reset by a motor object's method
% % ResetPosition())
%
%
% See also: NXTMotor, NXC_MotorControl, NXT_SetOutputState,
% NXT_GetOutputState, NXT_ResetMotorPosition, ReadFromNXT
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/11/12
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

%% initialize
    InboxNr = 1; % meant is the NXT's inbox (i.e. MATLAB's outbox if you will)

%% Lot's of Error-Checking and preparing input data...
    
    % NXT handle given?
    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end

    % port-array ok?
    if length(port) > 3
        error('MATLAB:RWTHMindstormsNXT:Motor:tooManyPorts', 'Maximum number of ports allowed for this command is 3');
    end%if
    for j = 1 : length(port)
        if IsFraction(port(j)) | (port(j) < 0) | (port(j) > 2)
            error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'A motor-port can only be 0, 1, or 2 for this command. An array of up to 3 different motors is allowed.');
        end%if
    end%for

    % important to sort so that it's either AB, AC or BC (or ABC)
    port = sort(port);
    
    % set real port number to use in protocol
    % we use the following port constants, apart from the ABC thing
    % OUT_A	0x00
    % OUT_B	0x01
    % OUT_C	0x02
    % OUT_AB	0x03
    % OUT_AC	0x04
    % OUT_BC	0x05
    % OUT_ABC	0x06

    % check for duplicates!
    if ((length(port) == 2) && (port(1) == port(2))) || ((length(port) == 3) && ((port(1) == port(2)) || port(2) == port(3)))
         error('MATLAB:RWTHMindstormsNXT:Motor:invalidPortCombination', 'When multiple ports a specified, they cannot be the same.');
    end%if

    
    if length(port) > 1
        if (port(1) == 0) && (port(2) == 1)
        	prt = 3;
        elseif (port(1) == 0) && (port(2) == 2)
            prt = 4;
        elseif (port(1) == 1) && (port(2) == 2)
            prt = 5;
        end%if
    elseif length(port) == 3
        prt = 6; % constant OUT_ABC
    else
      prt = port;  
    end%if
    
    
      
    %% build string message to send
    %from the NXC program:
    % #define PROTO_CONTROLLED_MOTORCMD       1
    % #define PROTO_RESET_ERROR_CORRECTION    2 <--
    % #define PROTO_ISMOTORREADY              3
    % #define PROTO_CLASSIC_MOTORCMD          4
    % #define PROTO_JUMBOPACKET               5
    msg = sprintf('2%1d', prt);
    
    
%% no wait-time before sending the message this time
% the counter is just a register that will be cleared, there are no tasks
% involved in the NXC program, this really shouldn't be a problem!
    
%% finally, send message   

    NXT_MessageWrite(msg, InboxNr, handle);
    
%% Remember timestamp
    NXTMOTOR_State = handle.NXTMOTOR_getState();
    
    for j = 1 : length(port)
        NXTMOTOR_State(port(j)+1).LastMsgToNXCSentTime = tic();
    end%for
    
    handle.NXTMOTOR_setState(NXTMOTOR_State);
    
end%function


function ret = IsFraction(x)
    if x == fix(x)
        ret = false;
    else
        ret = true;
    end%if
end%if
    
    