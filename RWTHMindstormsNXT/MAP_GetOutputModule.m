function map = MAP_GetOutputModule(motor)
% Reads the IO map of the output module
%  
% Syntax
%   map = MAP_GetOutputModule(motor)
%
% Description
%   map = MAP_GetOutputModule(motor) returns the IO map of the output module at the given
%   motor port. The motor port can be addressed by MOTOR_A, MOTOR_B, MOTOR_C and 'all'.
%   The return value map is a struct variable or cell array ('all' mode). It contains all
%   output module information.  
%
% Output:
%     map.TachoCount         % internal, non-resettable rotation-counter (in degrees)
%
%     map.BlockTachoCount    % block tacho counter, current motor position, resettable using,
%                              ResetMotorAngle (NXT-G counter since block start)
%
%     map.RotationCount      % rotation tacho counter, current motor position (NXT-G counter
%                              since program start)
%
%     map.TachoLimit         % tacho/angle limit, 0 means none set
%
%     map.MotorRPM           % current pulse width modulation ?
%
%     map.Flags              % should be always ''. Flags are considered in MAP_SetOutputModule.
%
%     map.Mode               % output mode bitfield 1: MOTORON, 2: BRAKE, 4: REGULATED
%
%     map.ModeName           % output mode name interpreted by output mode bitfield
%
%     map.Speed              % motor power/speed
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
%     map.RunStateName       % run state name interpreted by run state byte
%   
%     map.RegModeByte        % regulation mode byte
%
%     map.RegModeName        % regulation mode name interpreted by regulation mode byte
%
%     map.Overloaded         % overloaded flag (true: speed regulation is unable to onvercome
%                                physical load on the motor)
%
%     map.SyncTurnParam      % current turn ratio, 1: 25%, 2:50%, 3:75%, 4:100% of full volume
%
% Examples
%   map = MAP_GetOutputModule(MOTOR_A);
%
%   map = MAP_GetOutputModule('all');
%
% See also: NXT_ReadIOMap
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2008/05/22
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

% Information provided by
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


%% Get Output Module Map
OutputModuleID = 131073; %hex2dec('00020001');

% one motor mode
if motor ~= 255

    % return values of specified motor port
    bytes = NXT_ReadIOMap(OutputModuleID, motor*32, 29);

    map.TachoCount      = wordbytes2dec(bytes(1:4), 4, 'signed'); %signed
    map.BlockTachoCount = wordbytes2dec(bytes(5:8), 4, 'signed'); %signed
    map.RotationCount   = wordbytes2dec(bytes(9:12), 4, 'signed'); %signed
    map.TachoLimit      = wordbytes2dec(bytes(13:16), 4); %unsigned
    map.MotorRPM        = wordbytes2dec(bytes(17:18), 2); %unsigned
    map.Flags           = wordbytes2dec(bytes(19), 1); % ToDo: should be interpreted
    [isMOTORON isBRAKE isREGULATED] = byte2outputmode(bytes(20));
    name = '';
    if isMOTORON;   name = [name 'MOTORON '];   end
    if isBRAKE;     name = [name 'BRAKE '];     end
    if isREGULATED; name = [name 'REGULATED ']; end

    map.Mode            = bytes(20);
    map.ModeName        = name;    
    map.Speed           = bytes(21);
    map.ActualSpeed     = bytes(22);
    map.RegPParameter   = bytes(23);
    map.RegIParameter   = bytes(24);
    map.RegDParameter   = bytes(25);
    map.RunStateByte    = bytes(26);
    map.RunStateName    = byte2runstate(bytes(26));
    map.RegModeByte     = bytes(27);
    map.RegModeName     = byte2regmode(bytes(27));
    map.Overloaded      = bytes(28);
    map.SyncTurnParam   = bytes(29);
    map.PwnFreq         = NaN;

else
    
    % return values of all three motor ports
    bytes = NXT_ReadIOMap(OutputModuleID, 0, 96);
    
    for i = 0:1:2
        map{i+1}.TachoCount      = wordbytes2dec(bytes(32*i+1:32*i+4), 4, 'signed'); %signed
        map{i+1}.BlockTachoCount = wordbytes2dec(bytes(32*i+5:32*i+8), 4, 'signed'); %signed
        map{i+1}.RotationCount   = wordbytes2dec(bytes(32*i+9:32*i+12), 4, 'signed'); %signed
        map{i+1}.TachoLimit      = wordbytes2dec(bytes(32*i+13:32*i+16), 4); %unsigned
        map{i+1}.MotorRPM        = wordbytes2dec(bytes(32*i+17:32*i+18), 2); %unsigned
        map{i+1}.Flags           = wordbytes2dec(bytes(32*i+19), 1); % ToDo: should be interpreted
        [isMOTORON isBRAKE isREGULATED name] = byte2outputmode(bytes(32*i+20));
        map{i+1}.Mode            = bytes(32*i+20);
        map{i+1}.ModeName        = name;
        map{i+1}.Speed           = bytes(32*i+21);
        map{i+1}.ActualSpeed     = bytes(32*i+22);
        map{i+1}.RegPParameter   = bytes(32*i+23);
        map{i+1}.RegIParameter   = bytes(32*i+24);
        map{i+1}.RegDParameter   = bytes(32*i+25);
        map{i+1}.RunStateByte    = bytes(32*i+26);
        map{i+1}.RunStateName    = byte2runstate(bytes(32*i+26));
        map{i+1}.RegModeByte     = bytes(32*i+27);
        map{i+1}.RegModeName     = byte2regmode(bytes(32*i+27));
        map{i+1}.Overloaded      = bytes(32*i+28);
        map{i+1}.SyncTurnParam   = bytes(32*i+29);
        map{i+1}.PwnFreq         = bytes(96);
    end
end


end