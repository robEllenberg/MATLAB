function handle = COM_OpenNXT(inifilename)
% Opens USB or Bluetooth connection to NXT device and returns a handle
%
% Syntax
%   handle = COM_OpenNXT()
%
%   handle = COM_OpenNXT(inifilename)
%
% Description
%   handle = COM_OpenNXT() tries to open a connection via USB. The first
%   NXT device that is found will be used. Device drivers (Fantom on
%   Windows, libusb on Linux) have to be already installed for USB to work.
%
%   handle = COM_OpenNXT(inifilename) will search the USB bus
%   for NXT devices, just as the syntax without any parameters. If this fails
%   for some reason (no USB connection to the NXT available, no device drivers
%   installed, or NXT device is busy), the function will try to establish a 
%   connection via Bluetooth, using the given Bluetooth configuration file
%   (you can create one easily with COM_MakeBTConfigFile.
%
%   Note that this function is the most simple way to get an NXT handle. If
%   you need a method to access multiple NXTs or more options, see the
%   advanced function COM_OpenNXTEx. In fact, COM_OpenNXT is just a
%   convenient wrapper to COM_OpenNXTEx('Any', ...).
%
%
% Limitations of COM_CloseNXT
%   If you call COM_CloseNXT('all') after a clear all command has been
%   issued, the function will not be able to close all remaining open USB
%   handles, since they have been cleared out of memory. This is a problem
%   on Linux systems. You will not be able to use the NXT device without
%   rebooting it.
%   Solution: Either use only clear in your programs, or you use the
%   COM_CloseNXT('all') statement before clear all.
%   The best way however is to track your handles carefully and close them
%   manually (COM_CloseNXT(handle)) before exiting whenever possible!
%
%
% Example
%   handle = COM_OpenNXT('bluetooth.ini');
%   COM_SetDefaultNXT(handle);
%   NXT_PlayTone(440,10);
%   COM_CloseNXT(handle);
%
% See also: COM_OpenNXTEx, COM_CloseNXT, COM_MakeBTConfigFile, COM_SetDefaultNXT
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/07/10
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


if ~exist('inifilename', 'var') % no BT settings, so USB only...
    handle = COM_OpenNXTEx('USB', '');
else % Bluetooth file given, but still try USB first
    handle = COM_OpenNXTEx('Any', '', inifilename);    
end%if


end%function