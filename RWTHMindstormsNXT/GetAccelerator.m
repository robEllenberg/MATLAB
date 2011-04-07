function [acc_vector] = GetAccelerator(port, varargin)
% Reads the current value of the HiTechnic acceleration sensor
%
% Syntax
%   acc_vector = GetAccelerator(port)
%
%   acc_vector = GetAccelerator(port, handle)
%
% Description
%   acc_vector = GetAccelerator(port) returns the current 1x3 accelerator vector acc_vector of 
%   the HiTechnic acceleration sensor. The column vector contains the
%   readings of the x, y, and z-axis, respectively. A reading of 200 is
%   equal to the acceleration of 1g. Maximum range is -2g to +2g.
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   OpenAccelerator(SENSOR_4);
%   acc_Vector = GetAccelerator(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: OpenAccelerator, CloseSensor, COM_ReadI2C
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/09/25
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


% old recursive version to remember...
%
%     RequestLen = 6;
%     I2Cdata = hex2dec(['02'; '42']); 
%     
% 
%     while ((BytesReady < 6) ||  (status ~= 0)) && (toc(ticID) < timeout)
%         
%         [BytesReady status] = NXT_LSGetStatus(port);
%         if status == 221 % communication bus error
%             % recursive!
%             acc_vector = GetAccelerator(port);
%             return
%         end%if
%         %idlecount = idlecount + 1;
%     end%if
%     

    % check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if    


    % initialize
    acc_vector = [NaN; NaN; NaN];


    
    % retrieve 6 bytes from device 0x02, register 0x42
    data = COM_ReadI2C(port, 6, uint8(2), uint8(66), handle);
    
    if ~isempty(data)
        % this double() is so important!!!
        data = double(data);
        
        % as seen in the hitechnic example code...
        % this is just a byte shift and could be done better, but
        % should work
%         if (data(1) > 127); data(1) = data(1) - 256; end
%         if (data(2) > 127); data(2) = data(2) - 256; end
%         if (data(3) > 127); data(3) = data(3) - 256; end
%         
%         acc_vector(1) = data(1) * 4 + data(4);
%         acc_vector(2) = data(2) * 4 + data(5);
%         acc_vector(3) = data(3) * 4 + data(6);

         %power of vectorization :-)
         data(data > 127) = data(data > 127) - 256;
         acc_vector = data(1:3) .* 4 + data(4:6);
         
    end%if

end%function
