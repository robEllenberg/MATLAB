function msg = getLibusbErrorString(errNo)
% Returns description to the last error from libusb
%
% Syntax
%   msg = getLibusbErrorString(errNo)
%
% Description
%   Returns the error message to the last error that occured with libusb
% 
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/04/29
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


if ~isscalar(errNo)
    msg = 'getLibusbErrorstring: error number is invalid (must be scalar)';
else

    if  errNo < 0
        %msg = sprintf('Error %d in libusb: %s', errNo, calllib('libusb', 'usb_strerror'));
        msg =  calllib('libusb', 'usb_strerror');

    % basically taht was it, leave the other strings below just in case...
    elseif errNo == 0
        msg = 'Call to libusb completed successfully';
    else
        msg = sprintf('Call to libusb completed successfully, %d bytes transmitted', errNo);
    end%if
    
end%if
    