function COM_CloseNXT(varargin)
% Closes and deletes a specific NXT handle, or clears all existing handles
%
% Syntax
%   COM_CloseNXT(handle)
%
%   COM_CloseNXT('all')
%
%   COM_CloseNXT('all', inifilename)
%
%
% Description
%   After using NXT handles, a user should free the device (and the memory
%   occupied by the handle) by calling this method. After the clean up
%   invoked by this call, an NXT brick can be accessed and used again (by
%   COM_OpenNXT or COM_OpenNXTEx.
%
%   COM_CloseNXT(handle) will close and erase the specified device.
%   handle has to be a valid handle struct created by either
%   COM_OpenNXT or COM_OpenNXTEx.
%
%   COM_CloseNXT('all') will close and erase all existing NXT devices
%   from memory (as long as the toolbox could keep track of them). All USB
%   handles will be destroyed, all open serial ports (for Bluetooth
%   connections) will be closed. This can be useful at the beginning of a
%   program to create a "fresh start" and a well-defined starting
%   environment.
%   Please note that a clear all command can cause this function to fail
%   (in such a way, that not all open USB devices can be closed, since all
%   information about them has be cleare from MATLAB's memory). If this
%   happens, an NXT device might appear to be busy and cannot be used.
%   Usually rebooting the NXT helps, if not try to restart MATLAB as well.
%   So be careful with using clear all before COM_CloseNXT('all'). 
%
%   COM_CloseNXT('all', inifilename) will do the same as above, but
%   instead of closing all open serial ports, only the COM-Port specified
%   in inifilename will be used (a valid Bluetooth configuration file can be 
%   created by the function COM_MakeBTConfigFile). 
%   This syntax helps to avoid interference with other serial ports that might
%   be used by other (MATLAB) programs at the same time. Note that still all open
%   USB devices will be closed.
%
%
% Limitations
%   If you call COM_CloseNXT('all') after a clear all command has been
%   issued, the function will not be able to close all remaining open USB
%   handles, since they have been cleared out of memory. This is a problem
%   on Linux systems. You will not be able to use the NXT device without
%   rebooting it.
%   Solution: Either use only clear in your programs, or you use the
%   COM_CloseNXT('all') statement before clear all.
%   The best way however is to track your handles carefully and close them
%   manually before exiting whenever possible!
%   
%
% Example
%   handle = COM_OpenNXT('bluetooth.ini', check');
%   COM_SetDefaultNXT(handle);
%   NXT_PlayTone(440,10);
%   COM_CloseNXT(handle);
%
% See also: COM_OpenNXT, COM_OpenNXTEx, COM_MakeBTConfigFile, COM_SetDefaultNXT
%
% Signature
%   Author: Linus Atorf, Alexander Behrens (see AUTHORS)
%   Date: 2011/09/28
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

    global NXTHANDLE_Array
    
    % need this if it has to be cleared!
    global NXTHANDLE_Default %#ok<NUSED>  
    % MATLAB doesn't recognize the use with global later, so we ignored the
    % mlint warning with %#OK ...
    
    
    if nargin == 0
        error('MATLAB:RWTHMindstormsNXT:notEnoughInputArguments', 'Not enough input arguments: Either specify a handle struct to be closed or pass the string argument ''all''.')
    end%if
    
    if ischar(varargin{1}) 
        if  strcmpi(varargin{1}, 'all') 
            % CLOSE ALL handles
            
            % use this function recursively
            for j = 1 : length(NXTHANDLE_Array)
                % careful, so that COM_CloseNXT doesn't crash...
                if ~isempty(NXTHANDLE_Array{j}) && isstruct(NXTHANDLE_Array{j})
                	COM_CloseNXT(NXTHANDLE_Array{j});
                end%if
                NXTHANDLE_Array{j} = [];
            end%for

            % use old BT function, still important for windows serial objects!
            BT_CloseAllHandles(varargin{2:end});
    
            % clear list of handles!
            clear global NXTHANDLE_Array
            
            % if we're clearing all handles, the default is one of them!
            clear global NXTHANDLE_Default
            
        else
            error('MATLAB:RWTHMindstormsNXT:invalidStringParameter', 'Input argument has to be a valid NXT handle struct or the string ''all''!')
        end%if
    else
        % close just one handle
        h = varargin{1};
        checkHandleStruct(h);
        
        % before closing, retrieve default handle, need it later down
        % dont worry if it doesn't exist, but dont crash, so we use try!
        try
            defaultHandle = COM_GetDefaultNXT();
        catch
            defaultHandle = [];
        end%try
        
        
        if h.ConnectionTypeValue == 1 % USB
            textOut(sprintf('Closing handle (USB) with MAC = %s (handle was %.1f minutes old)\n', h.NXTMAC, etime(clock, h.CreationTime) / 60));
            if (h.OSValue == 1) || (h.OSValue == 3) % Windows and Mac (Fantom)
                USB_CloseHandle_Windows(h);
            else % linux and Win64 (Libusb)
                USB_CloseHandle_Linux(h);
            end%if
        else % BT
            textOut(sprintf('Closing handle (Bluetooth) on port %s (handle was %.1f minutes old)... ', h.ComPort, etime(clock, h.CreationTime) / 60));
            BT_CloseHandle(h);
        end%if
        
        
        % we have to compare the current to the global default handle, because if
        % we're closing this specific handle which is also the global default,
        % we want to close "both"
        %
        %Old explanation for this, replace BT_ with COM_
        % this behaviour is necessary, because after calling
        % BT_CloseHandle(BT_GetDefaultHandle), the default handle SHOULD be
        % closed and cleared, and therefore the next call to
        % BT_GetDefaultHandle MUST fail. If we didn't manually clear this
        % global var, BT_GetDefaultHandle would return a pseudo-valid handle,
        % which then fails when calling fread or write, which is confusing. Try
        % it on your own in the command line, the handle then produces the
        % following warning-like text:
        %   Invalid instrument object.
        %   This object has been deleted and cannot be
        %   connected to the hardware. This object should
        %   be removed from your workspace with CLEAR.
        
        % we compare handles by their index, should be unique!
        if ~ isempty(defaultHandle) && (h.Index == defaultHandle.Index)
            clear global NXTHANDLE_Default
        end%if

        % remove handle from global array
        NXTHANDLE_Array{h.Index} = [];
        
        % delete internal references
        h.DeleteMe();
        
        % and finally, don't know if this matters:
        clear h
        
    end%if



end%function


%% --- FUNCTION BT_CloseHandle
function BT_CloseHandle(h)
% Closes and deletes an existing serial or file handle
%
% Syntax
%   |BT_CloseHandle(handle)|
%
% Description
%   |BT_CloseHandle(handle)| closes and deletes the given |handle|. This |handle| can be a serial one
%   in the PC mode or a file handle on a Linux system, which emulates the Bluetooth connection. The
%   given |handle| is created by the |BT_OpenHandle|.
%
%   Even if the given |handle| is a global one (|BT_SetDefaultHandle|) it will be deleted.
%
% Example
%+   BT_MakeConfigFile();
%+   bt_handle = BT_OpenHandle('bluetooth.ini');
%+   NXT_PlayTone(500,200);
%+   BT_CloseHandle(bt_handle);
%
% See also: COM_OpenNXT, COM_OpenNXTEx
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/14
%   Copyright: 2007-2011, RWTH Aachen University
%


%% Close given bluetooth connection
    try
        if (h.OSValue == 1) || (h.OSValue == 4) % Win 32Bit or 64Bit
            fclose(h.Handle());
            delete(h.Handle()); 
        else   % Linux or Mac
            fclose(h.Handle());
        end
        % complete the textOut message started earlier
        textOut(sprintf('done.\n'));
    catch
        textOut(sprintf('failed.\n'));
    end%try

end%function


%% --- FUNCTION BT_CloseAllHandles
function BT_CloseAllHandles(varargin)
% Closes and deletes all existing serial or file handles, which are open
%
% Syntax
%   |BT_CloseAllHandles()|
%
%   |BT_CloseAllHandles(inifilename)|
%
% Description
%   |BT_CloseAllHandles()| closes and deletes all serial connections on a PC system and all file
%   handles on a Linux system, whose status are open.
%   
%   |BT_CloseAllHandles(inifilename)| closes and deletes all serial connections on a PC system
%   matching to the specified COM port settings stored in the configuration file. The name of the
%   configuration file is given by the string |inifilename|. 
%   On a Linux system all matching open file handles are closed and deleted.
%
%   Use this function first if MATLAB cannot open a working serial / bluetooth
%   connection and you are sure all other parameters are correct. Sometimes
%   a not properly closed handle can lead to this problem, so its good
%   practice to add a |BT_CloseAllHandles(inifilename)| to the beginning of
%   all your programs before using |BT_OpenHandle|.
%
% Examples
%+   BT_CloseAllHandles();
%
%+   BT_CloseAllHandles('bluetooth.ini');
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/07/08
%   Copyright: 2007-2011, RWTH Aachen University


inisection = 'Bluetooth'; % the part inbetween [ ] inside the inifile...


%% Close all serial ports
    if nargin < 1
        textOut(sprintf('Closing all serial ports... '));
        if ispc % WINDOWS VERSION -------------
            try
                devices = instrfind('Status', 'open');
                for j = 1 : length(devices)
                    fclose(devices(j));
                    delete(devices(j));
                end%for
                clear devices()


                textOut(sprintf('done.\n'));
            catch
                textOut(sprintf('somehow failed.\n'));
            end%
        else % LINUX VERSION -------------
            try
                for j = fopen('all')
                    if numel(strmatch('/dev/', fopen(j)))
                        fclose(j);
                    end%if
                end%for


                textOut(sprintf('done.\n'));
            catch
                textOut(sprintf('somehow failed.\n'));
            end%
        end%if
    
%% Close specific serial port set in ini-file
    elseif nargin == 1
        if ~ischar(varargin{1})
            error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter', 'Use no parameter () to close all open ports, or use (inifilename) to close a specific port.') 
        end%if

        inifilename = varargin{1};
        ComPort = readFromIniFile(inisection, 'SerialPort', inifilename);

        textOut(sprintf('Closing serial port %s... ', ComPort));

        if ispc % WINDOWS VERSION -------------
            try
                devices = instrfind('Port', ComPort, 'Status', 'open');
                for j = 1 : length(devices)
                    fclose(devices(j));
                    delete(devices(j));
                end%for
                clear devices()

                textOut(sprintf('done.\n'));
            catch
                textOut(sprintf('somehow failed.\n'));
            end%
        else % LINUX VERSION -------------
            try
                for j = fopen('all')
                    if strcmp(fopen(j), ComPort)
                        fclose(j);
                    end%if
                end%for

                textOut(sprintf('done.\n'));
            catch
                textOut(sprintf('somehow failed.\n'));
            end%
        end%if

    else
        error('MATLAB:RWTHMindstormsNXT:invalidVararginParameter', 'Use no parameter () to close all open ports, or use (inifilename) to close a specific port.') 
    end%if

end%function



%% --- FUNCTION USB_CloseHandle_Windows
function USB_CloseHandle_Windows(h)    


    textOut(sprintf('  - Destroying NXT handle... '))
    status = calllib('fantom', 'nFANTOM100_destroyNXT', h.Handle(), 0);
    displayUSBWinStatus(status)

end%function



%% --- FUNCTION USB_CloseHandle_Linux
function USB_CloseHandle_Linux(h)    
    
    LIBUSB_Interface = 0;

    % interface number is hardcoded, should it be that way?
    textOut(sprintf('  - Releasing interface... '));
    ret = calllib('libusb', 'usb_release_interface', h.Handle(), LIBUSB_Interface);
    displayLibusbStatus(ret);


    textOut(sprintf('  - Closing device... '));
    ret = calllib('libusb', 'usb_close', h.Handle());
    displayLibusbStatus(ret);

    % we don't unload libusb now, but if we did:
    % if we unload the lib, apparently we get a segmentation violation the 2nd
    % time we open a handle after we've closed the first one, although
    % USB_OpenHandle still reports success...??? Solution: Keep libusb loaded.
    % Maybe libpointers get invaled if they point to another (wrong) instance
    % of the loaded lib???

end%if


%% --- FUNCTION displayUSBWinStatus(status)
function displayUSBWinStatus(status)
    if status
        textOut(sprintf('failed.\n'));
        textOut(sprintf(['VISA error ' num2str(status) ': ' getVISAErrorString(status) '\n']))
    else
        textOut(sprintf('done.\n'));
    end%if
end%function


%% --- FUNCTION displayLibusbStatus(status)
function displayLibusbStatus(status)
    if isnumeric(status) && (status < 0)
        textOut(sprintf('failed.\n'));
        textOut(sprintf(['Libusb error ' num2str(status) ': ' getLibusbErrorString(status) '\n']))
    else
        textOut(sprintf('done.\n'));
    end%if
end%function
