function errorstring=getVISAErrorString(commandstatus)
% Returns error message from VISA / Fantom error code
%
% Syntax
%   errorstring=getVISAErrorString(commandstatus)
%
% Description
%   Returns the exact description from an error-number that occurs when
%   working with VISA / Fantom drivers. 
%   Fantom errorcodes can be found in the official LEGO Mindstorms NXT Fantom
%   SDK documentation, and VISA errorcodes in National Instrument's VISA programmers'
%   reference manual.
%   Original file can be found here:
%           http://forums.nxtasy.org/index.php?showtopic=2018
%           http://www.vitalvanreeven.nl/page156/fantomNXT.zip
% 
% Signature
%   Author: Vital van Reeven (see AUTHORS)
%   Date: 2008/03/29
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


    % fantom error codes (found in fantom documentation) and 
    % some VISA error codes, found in NI-VISA programmers reference manual
    KSTATUSOFFSET=-142000;  %0xfffdd550
    switch (commandstatus)
        %general NI-VISA errorcodes
        case {-1073807298}  %0xbfff003e
            errorstring='Could not perform operation because of I/O error.';
        case {-1073807194}  %0xbfff00a6
            errorstring='The connection for the given session has been lost.';
        case {-1073807247}  %0xbfff0071
            errorstring='A specified user buffer is not valid or cannot be accessed for the required size.';
        %specific FANTOM errorcodes
        case {KSTATUSOFFSET-5} % kStatusPairingFailed  
            errorstring='Bluetooth pairing operation failed. Warning: You have already paired with that Bluetooth device. ';
        case {KSTATUSOFFSET-6} % kStatusBluetoothSearchFailed  
            errorstring='Bluetooth search failed. ';
        case {KSTATUSOFFSET-7} % kStatusSystemLibraryNotFound  
            errorstring='System library not found. ';
        case {KSTATUSOFFSET-8} % kStatusUnpairingFailed  
            errorstring='Bluetooth unpairing operation failed. ';
        case {KSTATUSOFFSET-9} % kStatusInvalidFilename  
            errorstring='Invalid filename specified. ';
        case {KSTATUSOFFSET-10} % kStatusInvalidIteratorDereference  
            errorstring='Invalid iterator dereference. (No object to get.). ';
        case {KSTATUSOFFSET-11} % kStatusLockOperationFailed  
            errorstring='Resource locking operation failed. ';
        case {KSTATUSOFFSET-12} % kStatusSizeUnknown  
            errorstring='Could not determine the requested size. ';
        case {KSTATUSOFFSET-13} % kStatusDuplicateOpen  
            errorstring='Cannot open two objects at once. ';
        case {KSTATUSOFFSET-14} % kStatusEmptyFile  
            errorstring='File is empty. Warning: The requested file is empty. ';
        case {KSTATUSOFFSET-15} % kStatusFirmwareDownloadFailed  
            errorstring='Firmware download failed. ';
        case {KSTATUSOFFSET-16} % kStatusPortNotFound  
            errorstring='Could not locate virtual serial port. ';
        case {KSTATUSOFFSET-17} % kStatusNoMoreItemsFound  
            errorstring='No more items found. ';
        case {KSTATUSOFFSET-18} % kStatusTooManyUnconfiguredDevices  
            errorstring='Too many unconfigured devices. ';
        case {KSTATUSOFFSET-19} % kStatusCommandMismatch  
            errorstring='Command mismatch in firmware response. ';
        case {KSTATUSOFFSET-20} % kStatusIllegalOperation  
            errorstring='Illegal operation. ';
        case {KSTATUSOFFSET-21} % kStatusBluetoothCacheUpdateFailed  
            errorstring='Could not update local Bluetooth cache with new name. Warning: Could not update local Bluetooth cache with new name. ';
        case {KSTATUSOFFSET-22} % kStatusNonNXTDeviceSelected  
            errorstring='Selected device is not an NXT. ';
        case {KSTATUSOFFSET-23} % kStatusRetryConnection  
            errorstring='Communication error. Retry the operation. ';
        case {KSTATUSOFFSET-24} % kStatusPowerCycleNXT  
            errorstring='Could not connect to NXT. Turn the NXT off and then back on before continuing. ';
        case {KSTATUSOFFSET-99} % kStatusFeatureNotImplemented  
            errorstring='This feature is not yet implemented. ';
        case {KSTATUSOFFSET-189} % kStatusFWIllegalHandle  
            errorstring='Firmware reported an illegal handle. ';
        case {KSTATUSOFFSET-190} % kStatusFWIllegalFileName  
            errorstring='Firmware reported an illegal file name. ';
        case {KSTATUSOFFSET-191} % kStatusFWOutOfBounds  
            errorstring='Firmware reported an out of bounds reference. ';
        case {KSTATUSOFFSET-192} % kStatusFWModuleNotFound  
            errorstring='Firmware could not find module. ';
        case {KSTATUSOFFSET-193} % kStatusFWFileExists  
            errorstring='Firmware reported that the file already exists. ';
        case {KSTATUSOFFSET-194} % kStatusFWFileIsFull  
            errorstring='Firmware reported that the file is full. ';
        case {KSTATUSOFFSET-195} % kStatusFWAppendNotPossible  
            errorstring='Firmware reported the append operation is not possible. ';
        case {KSTATUSOFFSET-196} % kStatusFWNoWriteBuffers  
            errorstring='Firmware has no write buffers available. ';
        case {KSTATUSOFFSET-197} % kStatusFWFileIsBusy  
            errorstring='Firmware reported that file is busy. ';
        case {KSTATUSOFFSET-198} % kStatusFWUndefinedError  
            errorstring='Firmware reported the undefined error. ';
        case {KSTATUSOFFSET-199} % kStatusFWNoLinearSpace  
            errorstring='Firmware reported that no linear space is available. ';
        case {KSTATUSOFFSET-200} % kStatusFWHandleAlreadyClosed  
            errorstring='Firmware reported that handle has already been closed. ';
        case {KSTATUSOFFSET-201} % kStatusFWFileNotFound  
            errorstring='Firmware could not find file. ';
        case {KSTATUSOFFSET-202} % kStatusFWNotLinearFile  
            errorstring='Firmware reported that the requested file is not linear. ';
        case {KSTATUSOFFSET-203} % kStatusFWEndOfFile  
            errorstring='Firmware reached the end of the file. ';
        case {KSTATUSOFFSET-204} % kStatusFWEndOfFileExpected  
            errorstring='Firmware expected an end of file. ';
        case {KSTATUSOFFSET-205} % kStatusFWNoMoreFiles  
            errorstring='Firmware cannot handle more files. ';
        case {KSTATUSOFFSET-206} % kStatusFWNoSpace  
            errorstring='Firmware reported the NXT is out of space. ';
        case {KSTATUSOFFSET-207} % kStatusFWNoMoreHandles  
            errorstring='Firmware could not create a handle. ';
        case {KSTATUSOFFSET-208} % kStatusFWUnknownErrorCode  
            errorstring='Firmware reported an unknown error code. ';
        otherwise
            errorstring=['Unknown errorcode: ' num2str(commandstatus)];
    end
end