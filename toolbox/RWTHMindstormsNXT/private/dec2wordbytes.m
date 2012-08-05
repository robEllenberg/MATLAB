function bytes = dec2wordbytes(val, n, varargin)
% Converts (un)signed integer to byte-array, using little-endian format (LSB first)
%
% Syntax
%   bytes = dec2wordbytes(val, n, varargin)
%
% Description
%   usage:
%     dec2wordbytes(bytes, n)
%       val     : integer
%       n       : number of bytes to use, i.e. word-size (2 usually = WORD)
%       'signed' : optional string-flag, if set the output byte will have to 
%                  be interpreted as signed integer, the input val can then
%                  (and only then) be negative.
%   return:
%        bytes  : the created byte-array (column vector) in "reversed
%                 order" = little-endian format, LSB first...
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/06/01
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

signed = false;

%% Check parameter

%TODO think about using non-string argument for signed, something like -1,
%to avoid slow string comparision...
if nargin >= 3
   if ~ischar(varargin{1})
       error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter', '3rd parameter must either be ''signed'' or ''unsigned'' if specified, default is ''unsigned''')
   else
       if strcmpi(varargin{1}, 'signed')
           signed = true;
       end%if
   end%if
end%if

%TODO consider using typecastc() instead of typecast for speed up!

if signed
    switch n
        case 1
            bytes = typecast(int8(val), 'uint8');
        case 2
            bytes = typecast(int16(val), 'uint8')';
        case 4
            bytes = typecast(int32(val), 'uint8')';
        case 8
            bytes = typecast(int64(val), 'uint8')';
        otherwise
            error('MATLAB:RWTHMindstormsNXT:noIntegerConversionAvailable', 'Integer conversion only available for 1, 2, 4 or 8 bytes.')
    end%switch
else
    switch n
        case 1
            bytes = typecast(uint8(val), 'uint8');
        case 2
            bytes = typecast(uint16(val), 'uint8')';
        case 4
            bytes = typecast(uint32(val), 'uint8')';
        case 8
            bytes = typecast(uint64(val), 'uint8')';
        otherwise
            error('MATLAB:RWTHMindstormsNXT:noIntegerConversionAvailable', 'Integer conversion only available for 1, 2, 4 or 8 bytes.')
    end%switch
end%if


end %function
