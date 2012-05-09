function MAP_SetOutputModule(motor, map, varargin)
% Writes the IO map to the output module
%  
% Syntax
%   MAP_SetOutputModule(motor, map)
%
%   MAP_SetOutputModule(motor, map, varargin)
%
% Description
%   map = MAP_SetOutputModule(motor, map) writes the IO map to the output module at the given motor
%   motor. The motor port can be addressed by MOTOR_A, MOTOR_B, MOTOR_C. The map structure has
%   to provide all output module information, listed below. 
%
% Input:
%     map.TachoCount         % internal, non-resettable rotation-counter (in degrees)
%
%     map.BlockTachoCount    % block tacho counter, current motor position, resettable using,
%                                ResetMotorAngle (NXT-G counter since block start)
%
%     map.RotationCount      % rotation tacho counter, current motor position (NXT-G counter
%                                since program start)
%  
%     map.TachoLimit         % current set tacho/angle limit, 0 means none set
%
%     map.MotorRPM           % current pulse width modulation ?
%
%     map.Flags              % update flag bitfield, commits any changing (see also varargin)
%
%     map.Mode               % output mode bitfield 1: MOTORON, 2: BRAKE, 4: REGULATED
%
%     map.Speed              % current motor power/speed
%
%     map.ActualSpeed        % current actual percentage of full power (regulation mode)
%
%     map.RegPParameter      % proportional term of the internal PID control algorithm
%
%     map.RegIParameter      % integral term of the internal PID control algorithm
%
%     map.RegDParameter      % derivate term of the internal PID control algorithm
%
%     map.RunStateByte       % run state byte
%
%     map.RegModeByte        % regulation mode byte
%
%     map.Overloaded         % overloaded flag (true: speed regulation is unable to onvercome
%                              physical load on the motor)
%
%     map.SyncTurnParam      % current turn ratio, 1: 25%, 2:50%, 3:75%, 4:100% of full volume
%
%   map = MAP_SetOutputModule(motor, map, varargin) sets the update flags explicit by the given
%   arguments.
%   'UpdateMode':           commits changes to the mode property
%   'UpdateSpeed':          commits changes to the speed property
%   'UpdateTachoLimit':     commits changes to the tacho limit property
%   'ResetCounter':         resets internal movement counters, cancels current goal, and resets
%                           internal error-correction system
%   'UpdatePID':            commits changes to PID regulation parameters
%   'ResetBlockTachoCount': resets block tacho count (block-relative position counter (NXT-G))
%   'ResetRotationCount':   resets rotation count (program-relative position counter (NXT-G))
%
% Examples
%  MAP_SetOutputModule(MOTOR_A, map);
%
%  map = MAP_GetOutputModule(MOTOR_A);
%  map.RegPParameter = 20;
%  MAP_SetOutputModule(MOTOR_A, map, 'UpdatePID');
%
% See also: MAP_GetOutputModule, NXT_WriteIOMap
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/22
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
%
%
% Information supported by
% Not eXactly C (NXC) Programmer's Guide 
% Version 1.0.1 b33, October 10, 2007
% by John Hansen
% http://bricxcc.sourceforge.net/nbc/nxcdoc/NXC_Guide.pdf
% - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Output Module Offsets            Value        Size
% OutputOffsetTachoCount(p)        (((p)*32)+0)  4
% OutputOffsetBlockTachoCount(p)   (((p)*32)+4)  4
% OutputOffsetRotationCount(p)     (((p)*32)+8)  4
% OutputOffsetTachoLimit(p)        (((p)*32)+12) 4
% OutputOffsetMotorRPM(p)          (((p)*32)+16) 2
% OutputOffsetFlags(p)             (((p)*32)+18) 1
% OutputOffsetMode(p)              (((p)*32)+19) 1
% OutputOffsetSpeed(p)             (((p)*32)+20) 1
% OutputOffsetActualSpeed(p)       (((p)*32)+21) 1
% OutputOffsetRegPParameter(p)     (((p)*32)+22) 1
% OutputOffsetRegIParameter(p)     (((p)*32)+23) 1
% OutputOffsetRegDParameter(p)     (((p)*32)+24) 1
% OutputOffsetRunState(p)          (((p)*32)+25) 1
% OutputOffsetRegMode(p)           (((p)*32)+26) 1
% OutputOffsetOverloaded(p)        (((p)*32)+27) 1
% OutputOffsetSyncTurnParameter(p) (((p)*32)+28) 1
% OutputOffsetPwnFreq              96            1


%% Parameter check
% check if bluetooth handle is given; if not use default one
if nargin < 3
    warning(['IO map changes have to be committed by the output module update flag!\n', ...
            'Update information is interpreted according the flag bitfield!\n', ...
            'Changes maybe will not be committed']);
end


% interpret and check motor parameter
if ischar(motor)
    if strcmpi(motor, 'all')
        motor = 255;
    else
        motor = str2double(motor);
    end%if
end%if

if (motor < 0 || motor > 2) && (motor ~= 255)
    error('MATLAB:RWTHMindstormsNXT:Motor:invalidPort', 'Input argument for motor port must be 0, 1 or 2 or ''all''.');
end%if


% check bitfield
if nargin > 2
    bitfield = 0;
    for i=1:size(varargin,2)
        switch varargin{i}
            case 'UpdateMode'
                bitfield = bitfield + 1; %#ok<NASGU> %hex2dec('01');
            case 'UpdateSpeed'
                bitfield = bitfield + 2; %#ok<NASGU> %hex2dec('02');                
            case 'UpdateTachoLimit'
                bitfield = bitfield + 4; %#ok<NASGU> %hex2dec('04');                                
            case 'ResetCounter'
                bitfield = bitfield + 8; %#ok<NASGU> %hex2dec('08');                                
            case 'UpdatePID'
                bitfield = bitfield + 16; %#ok<NASGU> %hex2dec('10');                                
            case 'ResetBlockTachoCount'
                bitfield = bitfield + 32; %#ok<NASGU> %hex2dec('20');
            case 'ResetRotationCount'
                bitfield = bitfield + 64; %#ok<NASGU> %hex2dec('40');
            otherwise
                error('MATLAB:RWTHMindstormsNXT:unknownModuleFlag', 'unkown output module flag: %s', varargin{i});
        end
    end
    if size(map,2) > 1
        for i=1:size(map,2)
            map{i}.Flags = bitfield;
        end
    else
        map.Flags = bitfield;
    end
end


% check correct map structure
if (motor == 255) && (size(map,2) ~= 3)
    error('MATLAB:RWTHMindstormsNXT:invalidOutputModuleMaps', 'map structure contains not three Output Module Maps!');
end

%% Write Data to Output Module Map
OutputModuleID = 131073; %hex2dec('00020001');

% one motor mode
if motor ~= 255
    bytes(1:4)   = dec2wordbytes(map.TachoCount, 4, 'signed'); %signed
    bytes(5:8)   = dec2wordbytes(map.BlockTachoCount, 4, 'signed'); %signed
    bytes(9:12)  = dec2wordbytes(map.RotationCount, 4, 'signed'); %signed
    bytes(13:16) = dec2wordbytes(map.TachoLimit, 4); %unsigned
    bytes(17:18) = dec2wordbytes(map.MotorRPM, 2); %unsigned
    bytes(19)    = dec2wordbytes(map.Flags, 1); % ToDo: should be interpreted
    bytes(20)    = dec2wordbytes(map.Mode, 1);
    bytes(21)    = dec2wordbytes(map.Speed, 1);
    bytes(22)    = dec2wordbytes(map.ActualSpeed, 1);
    bytes(23)    = dec2wordbytes(map.RegPParameter, 1);
    bytes(24)    = dec2wordbytes(map.RegIParameter, 1);
    bytes(25)    = dec2wordbytes(map.RegDParameter, 1);    
    bytes(26)    = dec2wordbytes(map.RunStateByte, 1);
    bytes(27)    = dec2wordbytes(map.RegModeByte, 1);    
    bytes(28)    = dec2wordbytes(map.Overloaded, 1);
    bytes(29)    = dec2wordbytes(map.SyncTurnParam, 1);    
    %bytes(30 o 96)    = dec2wordbytes(map.PwnFreq, 1);    

    % return values of specified motor port
    NXT_WriteIOMap(OutputModuleID, motor*32, size(bytes,2), bytes);
    
else
    % return values of all three motor ports
    for i = 0:1:size(map,2)-1
        bytes(32*i+1:32*i+4)   = dec2wordbytes(map{i+1}.TachoCount, 4, 'signed'); %signed
        bytes(32*i+5:32*i+8)   = dec2wordbytes(map{i+1}.BlockTachoCount, 4, 'signed'); %signed
        bytes(32*i+9:32*i+12)  = dec2wordbytes(map{i+1}.RotationCount, 4, 'signed'); %signed
        bytes(32*i+13:32*i+16) = dec2wordbytes(map{i+1}.TachoLimit, 4); %unsigned
        bytes(32*i+17:32*i+18) = dec2wordbytes(map{i+1}.MotorRPM, 2); %unsigned
        bytes(32*i+19)         = dec2wordbytes(map{i+1}.Flags, 1); % ToDo: should be interpreted
        bytes(32*i+20)         = dec2wordbytes(map{i+1}.Mode, 1);
        bytes(32*i+21)         = dec2wordbytes(map{i+1}.Speed, 1);
        bytes(32*i+22)         = dec2wordbytes(map{i+1}.ActualSpeed, 1);
        bytes(32*i+23)         = dec2wordbytes(map{i+1}.RegPParameter, 1);
        bytes(32*i+24)         = dec2wordbytes(map{i+1}.RegIParameter, 1);
        bytes(32*i+25)         = dec2wordbytes(map{i+1}.RegDParameter, 1);    
        bytes(32*i+26)         = dec2wordbytes(map{i+1}.RunStateByte, 1);
        bytes(32*i+27)         = dec2wordbytes(map{i+1}.RegModeByte, 1);    
        bytes(32*i+28)         = dec2wordbytes(map{i+1}.Overloaded, 1);
        bytes(32*i+29)         = dec2wordbytes(map{i+1}.SyncTurnParam, 1);    
    end
    if size(map,2) == 3
        bytes(96)              = dec2wordbytes(map{i+1}.PwnFreq, 1);    
    end

    % return values of specified motor port
    NXT_WriteIOMap(OutputModuleID, 0, size(bytes,2), bytes);    
end

end
