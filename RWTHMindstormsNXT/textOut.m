function textOut(strMsg, varargin)
% Wrapper for fprintf() which can optionally write screen output to a logfile
%  
% Syntax
%   textOut(strMsg) 
%   
%   textOut(strMsg, 'screenonly')
%
%   textOut(strMsg, 'logonly')
%
% Description
%   textOut(strMsg) will write to screen (command window) AND logfile, if global logging is
%   enabled. 
%
%   textOut(strMsg, 'screenonly') writes to screen (command window) only.
%
%   textOut(strMsg, 'logonly') writes to logfile only (global logging must be enabled). If logging
%   is disabled or somehow failes, the message will not be logged or displayed at all...
%
% Note:
%   To enable logging (to file), set the global var EnableLogging to true and
%   set Logfilename to a valid filename. This function distinguishes between
%   Windows and Linux systems to use proper linebreaks.
%   The global variable DisableScreenOut is an on/off switch for the
%   complete textOut()-messages that would appear on the command window.
%   Default setting is false, i.e. there will be no output.
% 
%   Recommended usage is together with sprintf(), in order to add
%   linebreaks for example.
%
%
% Examples
%  textOut('This is a message\n');
%
%  x = 'world';
%  y = 2007;
%  textOut(sprintf('Hello %s, it is the year %d!\n', x, y));
%  %Results in:  >> Hello world, it is the year 2007!
%
%  global EnableLogging
%  global Logfilename
%  EnableLogging = true;
%  Logfilename = 'logfile.txt';
%  textOut(sprintf('Whatever I say here will be logged to the file as well.\n'));
% 
%  textOut(sprintf('Only appears in the command window\n'), 'screenonly');
%
%  textOut(sprintf('Only appears in the logfile, if logging enabled\n'), 'logonly');
%
%  global DisableScreenOut
%  DisableScreenOut = true;
%  textOut(sprintf(['If logging is enabled, this goes to the logfile, ', ...
%                   'if not, this goes nowhere\n']));
%
%
% See also: DebugMode, isdebug (private)
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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


%TODO This function should support a verbosity-level concept in the future.
% Meaning that you set a verbosity-setting in the beginning, e.g. 3. Then
% every textOut() message in the code gets its on vebosity-level, let's
% just say from 1 (very important) to 5 (verbose, not so important). Then
% by setting this global level, textOut can decide which messages to put on
% the screen and which to ignore. If a user wants a more detailed
% log-level, they can increase the global verbosity level setting. On the
% other hand would a setting of 0 shut up the whole textOut() output.
% More details to this idea are explained in "further concepts.txt"


% consider renaming these global variables, but losing backwards
% compatibility?
% a good idea would be to access these settings through additional varargin
% parameters like: textOut('message test', 'DisableScreenOut', true);
global Logfilename;
global EnableLogging;
global DisableScreenOut;


%% Default values
if isempty(DisableScreenOut) 
    DisableScreenOut = true;
end
if isempty(EnableLogging)
    EnableLogging = false;
end

% old version of this was opt-out, now we made it opt in
DisableLogging = ~EnableLogging;

ToScreen = false;
ToLog    = false;


%% Parameter check
if nargin < 2 
    ToScreen = true;
    ToLog    = true;
else
    % replace this by strcmpi()!
    style = lower(varargin{1});
    if strcmp(style, 'screenonly')
        ToScreen = true;
    elseif strcmp(style, 'logonly')
        ToLog = true;
    end%if
end%if


%% Logical decision
ToLog = ToLog & ~DisableLogging;

if DisableScreenOut
    ToScreen = false;
end%if


%% Print commands
if ToScreen
    fprintf('%s', strMsg)
end%if


% Consider leaving the logfile open for a while to improve performance?
% But of course it has to be closed at the end of a program. Maybe add a
% timer object to do that? But does not sound great. One has to balance
% reliability (something you expect from logfiles) against performance...

if ToLog
    fid = fopen(Logfilename, 'a');
    if fid < 0
        warning('MATLAB:RWTHMindstormsNXT:couldNotWriteToLogfile', ['Could not open or write to logfile "', Logfilename, '"'])
    else
        
        %TODO add a warning or display a msg to the screen, if writing to
        %the logfile fails...
        
        % replace this by ispc?
        if strcmp(computer(), 'PCWIN')
            strMsg = strrep(strMsg, sprintf('\n'), sprintf('\r\n'));
            %fprintf(fid, '%s\r\n', strMsg);
            fprintf(fid, '%s', strMsg);
        else
            %fprintf(fid, '%s\n', strMsg);
            fprintf(fid, '%s', strMsg);
        end%if
    end%if
    fclose(fid);
end%if

end%function

	