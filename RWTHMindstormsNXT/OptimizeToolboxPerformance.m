function OptimizeToolboxPerformance
% Copies binary versions of typecastc to toolbox for better performance 
%
% Syntax
%   OptimizeToolboxPerformance
%
%
% Description
%
% This script automates toolbox optimization. The private functions
% wordbytes2dec and dec2wordbytes are very frequently called and thus most
% critical for performance (mostly, but not only CPU load), especially at
% high packet rates (USB). Profiling shows the bottleneck: typecast.
% When using the binary version from the MATLAB directory, speed-ups up to
% 300% can be experienced. However this binary version is in a private
% directory, so cannot be called directly. Also it depends on the OS, CPU
% architecture and MATLAB version used. So, the only solution: We copy
% those binary files to our own toolboxes private directory.
%
% The script asks the user for permission and performs the file actions
% automatically. After each step the results will be checked to avoid a
% corrupt toolbox.
%
% During the process, the m-files for the above named functions will be
% overwritten. This is the reason we provide 2 versions in the private dir,
% .m.slow (the original with typecast) and .m.fast (optimized version that
% needs binary typecastc files in the same directory).
%
% Note: The optimization is not possible anymore since MATLAB Release 2010a
% (i.e. since MATLAB version 7.10 and greater). As typecast is now a 
% built-in function, optimization is probably not necessary anymore anyway.
%
%
% Example
%  OptimizeToolboxPerformance
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2010/10/01
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


%% Check MATLAB version

if ~verLessThan('MATLAB', '7.10') % if ver >= 7.10
    helptext = sprintf(['Optimization of RWTH - Mindstorms NXT Toolbox not necessary!\n\n' ...
                     '' ...
                     'You are using a MATLAB release 2010a or newer (version 7.10 or greater).\n' ...
                     'Optimization is not possible (and not necessary) anymore. The function\n' ...
                     'typecast is a built-in function in current MATLAB releases and cannot be\n' ...
                     'further optimized.\n\n' ...
                     '' ...
                     'Enjoy using the RWTH - Mindstorms NXT Toolbox!\n']);
    disp(helptext)
    helpdlg(helptext, 'Optimization not necessary');
    return
end%if



%% Prepare workspace
% this is important, as now files or functions should be loaded!
close all
clear all




%% Ask user
q = '';
q = [q 'Do you want to optimize the performance of RWTH - Mindstorms NXT Toolbox?\n'];
q = [q '\n'];
q = [q 'In order to do so, binary files from your MATLAB installation will be copied '];
q = [q 'to the toolbox directory, so write access is required in this location. '];
q = [q 'Please note that this optimization will only work for the version of MATLAB '];
q = [q 'and the operating system you are currently using.\n'];
q = [q '\n'];
q = [q 'Press YES to continue.\n'];

if ~strcmpi('Yes', questdlg(sprintf(q), 'Optimize RWTH - Mindstorms NXT Toolbox?', 'Yes', 'No', 'No'))
    % user cancelled
    return
end%if

disp('Optimizing performance of RWTH - Mindstorms NXT Toolbox')
disp(' - Checking directories and functions...')

%% Locate toolbox path

ToolboxPrivateDir = fullfile(fileparts(mfilename('fullpath')), 'private');
if isempty(ToolboxPrivateDir) || strcmpi(ToolboxPrivateDir, 'private')
    errordlg('Could not locate RWTH - Mindstorms NXT Toolbox. Is it installed correctly and is the path properly set?')
    error   ('Could not locate RWTH - Mindstorms NXT Toolbox. Is it installed correctly and is the path properly set?')
end%if


%% Find typecastc

TypecastcPath = fileparts(which('typecast'));
if isempty(TypecastcPath)
    errordlg('Could not find MATLAB-function "typecast". Is MATLAB installed correctly and up2date?')
    error   ('Could not find MATLAB-function "typecast". Is MATLAB installed correctly and up2date?')
end%if

TypecastcPath = fullfile(TypecastcPath, 'private');

%% Try typecastc in original location
OldDir = pwd;
try
    cd(TypecastcPath)
    test = typecastc(int8(-1), 'uint8');
    if test ~= 255
        % raise error for catch...
        error('dummy error')
    end%
catch
    % change back...
    cd(OldDir);    
    errordlg('The binary version of typecast ("typecastc") does not seem to work. Aborting...')
    error   ('The binary version of typecast ("typecastc") does not seem to work. Aborting...')
end%try
% change back...
cd(OldDir);

% before continuing, clean up
clear typecastc
clear typecast


% create typecastc.* mask
TypecastcFilesMask = fullfile(TypecastcPath, 'typecastc.*');

%% Locate & copy source files

disp(' - Copying binary files for typecastc()...')
TypecastcFiles = dir(TypecastcFilesMask);
try
    for j = 1 : length(TypecastcFiles)
        copyfile(fullfile(TypecastcPath, TypecastcFiles(j).name), fullfile(ToolboxPrivateDir, TypecastcFiles(j).name), 'f');
    end%for
catch
    errordlg('Could not copy binary files to the toolboxes private folder. Do you have write access there? Aborting...')
    error   ('Could not copy binary files to the toolboxes private folder. Do you have write access there? Aborting...')
end%try


%% Check if binary files work in new location
disp(' - Checking freshly copied files...')
OldDir = pwd;
try
    cd(ToolboxPrivateDir)
    test = typecastc(int8(-1), 'uint8');
    if test ~= 255
        % raise error for catch...
        error('dummy error')
    end%
catch
    % change back...
    cd(OldDir);    
    errordlg('The binary version of typecast ("typecastc") does not seem to work in the toolboxes private folder. Aborting...')
    error   ('The binary version of typecast ("typecastc") does not seem to work in the toolboxes private folder. Aborting...')
end%try
% change back...
cd(OldDir);

% before continuing, clean up
clear typecastc
clear typecast

%% Now overwrite our functions...
disp(' - Updating wordbytes2dec() and dec2wordbytes()...')
try
    copyfile(fullfile(ToolboxPrivateDir, 'wordbytes2dec.m.fast'), fullfile(ToolboxPrivateDir, 'wordbytes2dec.m'), 'f');
    copyfile(fullfile(ToolboxPrivateDir, 'dec2wordbytes.m.fast'), fullfile(ToolboxPrivateDir, 'dec2wordbytes.m'), 'f');
catch
    errordlg('Could not overwrite functions wordbytes2dec() and dec2wordbytes() in toolboxes private dir. Got write access there? Aborting...')
    error   ('Could not overwrite functions wordbytes2dec() and dec2wordbytes() in toolboxes private dir. Got write access there? Aborting...')
end%try


%% Try the new versions!
disp(' - Checking new versions of wordbytes2dec() and dec2wordbytes()...')
OldDir = pwd;
try
    cd(ToolboxPrivateDir)
    
    a = [123; 132];
    test1 = wordbytes2dec(a, 2, 'signed');
    test2 = dec2wordbytes(test1, 2, 'signed');
    
    % compare vectors
    res = (test2 == a);
    % if not equal...
    if nnz(res) ~= 2
        % raise error for catch...
        error('dummy error')
    end%if
    
catch
    
    cd(OldDir);
    
    disp(' - New functions did not work, restoring old versions...')
    copyfile(fullfile(ToolboxPrivateDir, 'wordbytes2dec.m.slow'), fullfile(ToolboxPrivateDir, 'wordbytes2dec.m'), 'f');
    copyfile(fullfile(ToolboxPrivateDir, 'dec2wordbytes.m.slow'), fullfile(ToolboxPrivateDir, 'dec2wordbytes.m'), 'f');
        
    warndlg('New functions with binary versions of typecastc() did not work as expected. Original (slower) files were restored.', 'Optimization failed')
    disp(sprintf('Optimization failed.\nNew functions with binary versions of typecastc()\ndid not work as expected.\nOriginal (slower) files were restored.'))
    
end%try

cd(OldDir);


%% Done!

disp('Optimization successful!')
helpdlg('New functions with binary versions of typecastc() are correctly working. Toolbox performance with high packet rates (i.e. via USB) should be up to 3 times faster now, depending on your machine and CPU.', 'Optimization successful')

