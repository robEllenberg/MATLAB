function ret = readFromIniFile(AppName, KeyName, filename)
% Reads parameters from a configuration file (usually *.ini)
%  
% Syntax
%   ret = readFromIniFile(AppName, KeyName, filename) 
%
% Description
%   ret=readFromIniFile(AppName, KeyName, filename)
%
%   This function works like GetPrivateProfileString() from the Windows-API
%   that is well known for reading ini-file data. The parameters are:
%
%       AppName  = Section name of the type [xxxx]
%       KeyName  = Key name separated by an equal to sign, of the type abc = 123
%       filename = ini file name to be used
%
%       ret      = string (!) value of the key found, empty ('') if key was not
%                  found. Since it's a string, you have to convert to
%                  integers / floats on your own.
% 
% Note that AppName and KeyName are NOT case sensitive, and that whitespace
% between '=' and the value will be ignored (removed).
%
% If the key or the AppName is not found, or if the inifile does not
% exist or could not be opened, '' will be returned (this will also be 
% returned when the key is empty).
%
% Examples:
%    %a sample ini file (sample.ini) may have entries:
%    %
%    %   [XYZ]
%    %   abc=123
%    %   def=7
%    %   ; lines starting with a ; are comments
%    %   [ZZZ]
%    %   abc=890
%
% readFromIniFile('XYZ','abc', 'sample.ini') % will return '123'
%
% readFromIniFile('ZZZ','abc', 'sample.ini') % will return '890'
%
% readFromIniFile('XYZ','def', 'sample.ini') % will return '7'
%
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/01/08
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



% This functions is very generous about invalid inifiles.
% It takes the first matching occurence of [Secion] and Key=, and then
% returns the value found. It will NOT check for multiple sections, split
% sections, multiple keys ore similar things.
% We even ignore lines that are not sections or keys.
% Also lines beginning with a ';' (after the whitespace) will be handled as
% comments. Note that a comment can NOT follow after the value of a key in
% the same line, since we must allow the possibility for ';'s to occur in
% strings of the values...
%
% What we do is simple: Scan through the line from top to bottom, keep track
% of the current section we're in, see if we have a key, and if both section
% and key are a match, get the value and break. Done.


ret = '';

%% Try to read in inifile
fid = fopen(filename, 'r');
if fid < 0
	warning('MATLAB:RWTHMindstormsNXT:couldNotOpenInifile', 'Ini-file "%s" was not found or could not be read.', filename);
	return
end%if

% input to a string
data = fread(fid, '*char')';
fclose(fid);


%% Separate lines and parse away
curSection = '';
curKey = '';
while(~isempty(data))
    
    % get next line by LFs
    [curLine, data] = strtok(data, char(10)); %#ok<STTOK>
    
    % remove whitespace (includes removing CRs if present)
    curLine = strtrim(curLine);
    
    % if line's empty or too short
    if length(curLine) < 2
        % ignore empty lines, or in this case lines with a max of 1 char,
        % there's nothing we can do
        
    % if we have a section header
    elseif strcmp(curLine(1), '[') && strcmp(curLine(end), ']')
        curSection = curLine(2:end-1);
        % remember to reset key, so that an old key does not work in a new
        % section....
        curKey = '';
    
    % if we have a comment
    elseif strcmp(curLine(1), ';') 
        % ignore this line, it's a comment
        
    % or if we have a key
    elseif ~isempty(strfind(curLine, '=')) % found a =, it's a key
        [curKey remainder] = strtok(curLine, '=');
        curVal = strtok(remainder, '=');
        % remove whitespaces from tokens
        curKey = strtrim(curKey);
        curVal = strtrim(curVal);
    
    % this means we also ignore all other lines with rubbish etc in them...
    end%if
    
    % check if we found what we're looking for, NOT case sensitive
    if strcmpi(curSection, AppName) && strcmpi(curKey, KeyName)
        ret = curVal;
        return
    end%if
    
end%while



end%function

