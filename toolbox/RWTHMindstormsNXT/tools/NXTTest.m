function NXTTest()
% NXTTest
% This function connects to the NXT and plays a tone to confirm it is working.
%
% Signature
%   Author: Alexander Behrens (see AUTHORS)
%   Date: 2010/08/03
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

    %% Clean up previous handles
    COM_CloseNXT all

    %% Set up Matlab
    clear all % if you use clear all, call COM_CloseNXT all before, as we did!

    %% Connect to NXT
    fprintf('    Connecting...')

    handle = COM_OpenNXTEx('Any', '', 'bluetooth.ini');

    if isempty(handle)
        fprintf('    error! Unable to connect to NXT!\n')
        return;
    else
        fprintf('   ...done.\n')
    end

    %% Play tone
    reply = 'Y';  
    while strcmpi(reply,'Y');
        fprintf('    Play tone...')
        NXT_PlayTone(800,500, handle);
        fprintf('    ...done.\n')
        
        reply = input('    Play tone again? Y/N [Y]: ', 's');
        if isempty(reply)
            reply = 'Y';
        end
    end

    %% Close NXT connection.
    fprintf('    Disconnecting...')
    COM_CloseNXT(handle);
    fprintf('    ...done.\n')
end
