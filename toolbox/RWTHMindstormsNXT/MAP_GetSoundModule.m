function map = MAP_GetSoundModule()
% Reads the IO map of the sound module
%  
% Syntax
%   map = MAP_GetSoundModule()
%
% Description
%   map = MAP_GetSoundModule() returns the IO map of the sound module. The return value map is
%   a struct variable. It contains all sound module information.
%
% Output:
%     map.Frequency          % frequency of the last played ton in Hz
%
%     map.Duration           % duration of the last played ton in ms
%
%     map.SamplingRate       % current sound sample rate
%
%     map.SoundFileName      % sound file name of the last played sound file
%
%     map.Flags              % sound module flag, 'IDLE': sound module is idle, 'UPDATE': a
%                               request for plackback is pending, 'RUNNING': playback in
%                               progress.
%
%     map.State              % sound module state, 'IDLE'; sound module is idel,
%                                'PLAYING_FILE': sound module is playing a .rso file,
%                                'PLAYING_TONE': a tone is playing, 'STOP': a request to stop
%                                playback is in progress. 
%
%     map.Mode               % sound module mode, 'ONCE': only play file once , 'LOOP': play
%                                file in a loop, 'TONE': play tone.
%
%     map.Volume             % volume: 0: diabled, 1: 25%, 2:50%, 3:75%, 4:100% of full volume
%
% Examples
%   map = MAP_GetSoundModule();
%
% See also: NXT_ReadIOMap
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

% Information provided by
% Not eXactly C (NXC) Programmer's Guide 
% Version 1.0.1 b33, October 10, 2007
% by John Hansen
% http://bricxcc.sourceforge.net/nbc/nxcdoc/NXC_Guide.pdf
% - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Sound Module Offsets Value Size
% SoundOffsetFreq           0  2
% SoundOffsetDuration       2  2
% SoundOffsetSampleRate     4  2
% SoundOffsetSoundFilename  6 20
% SoundOffsetFlags         26  1
% SoundOffsetState         27  1
% SoundOffsetMode          28  1
% SoundOffsetVolume        29  1


%% Get Sound Module Map
SoundModuleID = 524289; %hex2dec('00080001');


% return values of specified motor port
bytes = NXT_ReadIOMap(SoundModuleID, 0, 30);

map.Frequency      = wordbytes2dec(bytes(1:2), 2); %unsigned
map.Duration       = wordbytes2dec(bytes(3:4), 2); %unsigned
map.SamplingRate   = wordbytes2dec(bytes(5:6), 2); %unsigned
                     a = cellstr(char(bytes(7:26))');
map.SoundFileName  = a{1};
map.Flags          = byte2soundflags(wordbytes2dec(bytes(27), 1)); % ToDo: should be interpreted
map.State          = byte2soundstate(bytes(28));
map.Mode           = byte2soundmode(bytes(29));
map.Volume         = bytes(30);

end


function name = byte2soundflags(byte)
% Determines sound flags from given byte
    switch byte
        case 0
            name = 'IDLE';
        case 1
            name = 'UPDATE';
        case 2
            name = 'RUNNING';
        otherwise
            warning('MATLAB:RWTHMindstormsNXT:SoundModule', 'flag parameter unknown!');
    end
end

function name = byte2soundstate(byte)
% Determines sound state from given byte
    switch byte
        case 0
            name = 'IDLE';
        case 2
            name = 'PLAYING_FILE';
        case 3
            name = 'PLAYING_TONE';
        case 4
            name = 'STOP';
        otherwise
            warning('MATLAB:RWTHMindstormsNXT:SoundModule', 'flag parameter unknown!');
    end
end%function

function name = byte2soundmode(byte)
% Determines sound mode from given byte
    switch byte
        case 0
            name = 'ONCE';
        case 1
            name = 'LOOP';
        case 2
            name = 'TONE';
        otherwise
            warning('MATLAB:RWTHMindstormsNXT:SoundModule', 'mode parameter unknown!');
    end
end%function
