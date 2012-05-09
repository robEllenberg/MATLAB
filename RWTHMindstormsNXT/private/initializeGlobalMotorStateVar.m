function NXTMOTOR_State = initializeGlobalMotorStateVar
% Internal helper to initialize a struct holding motor information
%
% Syntax
%   NXTMOTOR_State = initializeGlobalMotorStateVar
%
% Description
%   This is used by the private function createHandleStruct.
%
%   Note: The name suggests the use of a global variable, but this is only
%   kept for historic reasons. No reference to a global variable is made.
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/06/28
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

%TODO try to get rid of most of this stuff some time!


NXTMOTOR_State = struct(...
    'BrakeDisabled',        {    false,     false,     false}, ...
    'SyncedToSpeed',        {    false,     false,     false}, ...
    'SyncedToMotor',        {       -1,        -1,        -1}, ... 
    'Power',                {        0,         0,         0}, ...
    'TurnRatio',            {        0,         0,         0}, ...
    'AngleLimit',           {        0,         0,         0}, ...
    'TachoCount',           {        0,         0,         0}, ...
    'RunStateName',         {'RUNNING', 'RUNNING', 'RUNNING'}, ...  %TODO check if it makes sense to initialize this with RUNNING instead of IDLE, (works well anyway)!
    'MemoryCount',          {        0,         0,         0}, ...
    'LastMsgToNXCSentTime', {tic()    ,     tic(),     tic()}, ...  
    'LastStopCmdSentTime',  {tic()    ,     tic(),     tic()}); 

end%function
