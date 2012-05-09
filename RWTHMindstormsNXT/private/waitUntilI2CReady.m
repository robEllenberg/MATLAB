function waitUntilI2CReady(port, handle)
% just "blocks" the given sensor port until the I2C bus is ready.
% timeout is included, so after a maximum of currently 1s, the function
% will release anyway...
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/12/1
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

    startTime = clock();
    timeOut = 1; % in seconds
    status = -1; % initialize
    while (status ~= 0) && (etime(clock, startTime) < timeOut)
        [dontcare status] = NXT_LSGetStatus(port, handle);
    end%while
    
end%function
