function byte = sensormode2byte(name)
% Determines sensor mode byte from given sensor mode
%
% Syntax
%   byte = sensormode2byte(name)
%
% Description
%   The constant names and enumerations are directly taken from the LEGO
%   Mindstorms Bluetooth SDK and Direct Commands Appendix
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
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

%% Create look up table
NXT__RAWMODE            =   0; %#ok<NASGU> %hex2dec('00'); %#ok<NASGU>
NXT__BOOLEANMODE        =  32; %#ok<NASGU> %hex2dec('20'); %#ok<NASGU>
NXT__TRANSITIONCNTMODE  =  64; %#ok<NASGU> %hex2dec('40'); %#ok<NASGU>
NXT__PERIODCOUNTERMODE  =  96; %#ok<NASGU> %hex2dec('60'); %#ok<NASGU>
NXT__PCTFULLSCALEMODE   = 128; %#ok<NASGU> %hex2dec('80'); %#ok<NASGU>
NXT__CELSIUSMODE        = 160; %#ok<NASGU> %hex2dec('A0'); %#ok<NASGU>
NXT__FAHRENHEITMODE     = 192; %#ok<NASGU> %hex2dec('C0'); %#ok<NASGU>
NXT__ANGLESTEPSMODE     = 224; %#ok<NASGU> %hex2dec('E0'); %#ok<NASGU>
% what are these "masks"? not explained in mindstorms docu...
NXT__SLOPEMASK          =  31; %#ok<NASGU> %hex2dec('1F'); %#ok<NASGU>
% and why is this MODEMASK identical to ANGLESTEPSMODE? is this by design?
NXT__MODEMASK           = 224; %#ok<NASGU> %hex2dec('E0'); %#ok<NASGU>


%% Check parameter
if ~exist(['NXT__' name], 'var') || ~isreal(['NXT__' name])
    error('MATLAB:RWTHMindstormsNXT:Sensor:invalidModeName', 'Unknown NXT sensor mode "%s". See inside this method (private/sensormode2byte.m) for a list.', name)
end%if

%% Interpret sensor mode byte
byte = eval(['NXT__' name]);

end%function
