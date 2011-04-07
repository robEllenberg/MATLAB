function res = wordbytes2dec(bytes, n, varargin)
% Converts byte-array to integer, using little-endian format (LSB first)
%
% Syntax
%   res = wordbytes2dec(bytes, n, varargin)
%
% Description
%   usage:
%     wordbytes2dec(bytes, n)
%     bytes   : array of bytevalues (vertical vector = 1st index is 1)
%     n       : how many bytes to use? 2 = WORD usually, 4 = LONG, etc
%     'signed' : optional string-flag, if set the byte will be
%                interpreted as signed integer
%  
%   return:
%        res    : resulting integer
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/06/01
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

signed = false;


%% Check parameter
if nargin >= 3
   if ~ischar(varargin{1})
       error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter', '3rd parameter must either be ''signed'' or ''unsigned'' if specified, default is ''unsigned''')
   else
       if strcmpi(varargin{1}, 'signed')
           signed = true;
       end%if
   end%if
end%if

%% Convert byte-array to integer

%TODO consider using typecastc() instead of typecast for speed up!


if signed
    switch n
        case 1
            res = typecast(uint8(bytes(1)), 'int8');
        case 2
            res = typecast(uint8(bytes(1:2)), 'int16');
        case 4
            res = typecast(uint8(bytes(1:4)), 'int32');
        case 8
            res = typecast(uint8(bytes(1:8)), 'int64');
        otherwise
            error('MATLAB:RWTHMindstormsNXT:noIntegerConversionAvailable', 'Integer conversion only available for 1, 2, 4 or 8 bytes.')
    end%switch
else
    switch n
        case 1
            res = typecast(uint8(bytes(1)), 'uint8');
        case 2
            res = typecast(uint8(bytes(1:2)), 'uint16');
        case 4
            res = typecast(uint8(bytes(1:4)), 'uint32');
        case 8
            res = typecast(uint8(bytes(1:8)), 'uint64');
        otherwise
            error('MATLAB:RWTHMindstormsNXT:noIntegerConversionAvailable', 'Integer conversion only available for 1, 2, 4 or 8 bytes.')
    end%switch
end%if

% to avoid type mismatches (apparently, MATLAB has no auto conversion
% from uint* to double?), we return a double
res = double(res);

end%function
