function ReturnBytes = COM_ReadI2C(Port, RequestLen, DeviceAddress, RegisterAddress, varargin)
% Requests and reads sensor data via I2C from a correctly configured digital sensor.
%
% Syntax
%   ReturnBytes = COM_ReadI2C(Port, RequestLen, DeviceAddress, RegisterAddress)
%
%   ReturnBytes = COM_ReadI2C(Port, RequestLen, DeviceAddress, RegisterAddress, handle)
%
% Description
%    This function is used to retrieve data from digital sensors (like the
%    ultrasonic) in a comfortable way. It is designed as a helping function
%    for developers wanting to access new sensors. For already implemented
%    sensors (e.g. ultrasound, as well as HiTechnic's acceleration and 
%    infrared sensors), use the provided high-level functions such as
%    GetUltrasonic, GetInfrared, etc.
%
%    For I2C communication, usually the NXT_SetInputMode command has to
%    be used with the LOWSPEED_9V or LOWSPEED setting. Afterwards,
%    commands can be send with NXT_LSWrite. Once a sensor is correctly
%    working, i.e. has data available, you can use this function to
%    retrieve them.
%
%    In COM_ReadI2C(Port, RequestLen, DeviceAddress, RegisterAddress),
%    Port is the sensor-port the sensor is connected to. RequestLen
%    specifies the amount of bytes you want to retrieve. For ultasound,
%    this is 1. DeviceAddress is the sensor's address on the I2C bus.
%    This sometimes can be changed, but not for the ultrasonic sensor.
%    Default value is 0x02 (2 in decimal). Finally, RegisterAddress is
%    the address where you want to read data from. For the ultrasound and
%    many other sensors, the "data section" starts at 0x42 (66 in decimal).
%
%    As last argument you can pass a valid NXT-handle to be used by this
%    function. If no handle is passed, the default set by
%    COM_SetDefaultNXT will be used.
%
%    *Returns:* ReturnBytes, byte-array (column vector) of uint8.
%    This array contains the raw sensor-data you requested. How to
%    interpret them depends on the sensor. If communication failed (even
%    after automatic retransmission) -- e.g. when the sensor get's
%    disconnected while in use -- an empty vector [] will be returned.
%
% Note:
%
%    Please note that the return values of this function are of type uint8.
%    You have to convert them to double (using double()) before
%    performing calculations with them, otherwise you might get unexpected
%    results!
%
%    The sensor you are addressing with this command has to be correctly
%    opened and initialized of course -- otherwise no valid data can be
%    received.
%
% Example
%    This example opens and reads the ultrasonic sensor
%   port = SENSOR_1;
%   handle = COM_OpenNXT('bluetooth.ini');
%
%   OpenUltrasonic(port);
%
%   % retrieve 1 byte from device 0x02, register 0x42
%   data = COM_ReadI2C(port, 1, uint8(2), uint8(66));
%
%   if isempty(data)
%       DistanceCM = -1;
%   else
%       % don'f forget this double()!!!
%       DistanceCM = double(data(1));
%   end%if
%
%
% See also: NXT_LSWrite, NXT_LSRead, NXT_LSGetStatus, NXT_SetInputMode, OpenUltrasonic,
% GetUltrasonic, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2008/09/23
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


%% Initialize
    ReturnBytes = [];   
    RecursionDepth = 1;
    
%% Parameter check
    % check if NXT handle is given; if not use default one
    if nargin == 5 
        handle = varargin{1};
    elseif nargin == 6
        handle = varargin{1};
        RecursionDepth = varargin{2};
    else
        handle = COM_GetDefaultNXT;
    end%if

    
    % Check for maximum recursion depth! This can happen when this function
    % repeatedly cannot read valid data via I2C. We set it by hand to 3
    % tries. This condition will happen when for example you pull out the
    % sensorcable of the US sensor just while it is retrieving data...
    if RecursionDepth > 3
        return
    end%if
    

    % check if port number is valid
    if Port < 0 || Port > 3 
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'Sensor port %d invalid! It has to be 0, 1, 2 or 3', port);
    end%if



%% Build hex command and send it with NXT_LSWrite

    % create this I2C command. 
    I2Cdata = [DeviceAddress; RegisterAddress]; 


    NXT_LSWrite(Port, RequestLen, I2Cdata, 'dontreply', handle)

    
    
%% Try requesting answer until it is ready

    % Usually one should issue the LSWrite command, then keep requesting
    % the I2C bus-status with LSGetStatus until it doesn't return an error
    % and until the amount of bytes one requested is availabled, and then
    % finally retrieve the data with LSRead.
    %
    % I found that the step with LSGetStatus can be omitted. Each direct
    % command, including LSRead, has its own error message included (the
    % statusbyte). If instead of using LSGetStatus and THEN using LSRead,
    % we just use LSRead straight ahead, this has 2 advantages:
    % - most of the time, the I2C sensor is ready anyway. So we save the
    % time (especially via Bluetooth) that LSGetStatus needs.
    % - if the sensor is not ready, we can keep polling it with LSRead. The
    % error messages are the same, but once they stop (and data is ready),
    % we already got the data as payload - having saved another call!
    %
    % Compared to the traditional way, this yields a speed up of about 100%
    % for both Bluetooth and USB.
    %
    %
    % Note that there is a tiny chance for further improvement, depending
    % on the sensor. If we add a short pause here in the magnitude of 1ms
    % to 10ms, it could lead to one failed LSRead being saved. Imagine
    % this: Instead of asking the sensor straight away if it's ready, and
    % then waiting 60ms for one more Bluetooth packet to arrive, we could
    % wait 10ms (if that is enough) and then get the sensors answer with
    % the next packet straight away.
    % Testing showed that this is NOT necessary and most of the time NOT
    % helping with Bluetooth, a fast computer and the ultrasonic sensor.
    % However, different sensors may show different behaviour... 
      
    % use a timeout so we don't get stuck
    startTime = clock();
    timeOut = 1; % in seconds
    status = -1; % initialize

    BytesRead = 0;
    
    % if we get error 224, it seems the sensor was not opened properly
    % or, alternatively, it was opened, but due to termination of a NXC
    % program, it was "closed" again... so let's warn about this, but only
    % once...
    ShowedWarning224 = false;
    

%% Actual request-loop
    timedOut = false;
    while ((status ~= 0) || ( BytesRead < 1)) 

        % note that we suppress statusbyte-error-warnings by requesting the
        % 3rd optional output argument of NXT_LSRead()
        [data BytesRead status] = NXT_LSRead(Port, handle);

               
        % discovery: if we get an error 221, it seems there is nothing that
        % can be done to retrieve the data. we will run into a timeout. so
        % why not retry the whole reading process?
        if (status == 221)  % 221 = "Communication bus error"
            
            % try to flush out invalid data with this command
            %[a b c] = NXT_LSRead(Port); 
            
            if isdebug()
                textOut(sprintf(['! COM_ReadI2C failed, recursion depth ' num2str(RecursionDepth) ' @ ' datestr(now, 'HH:MM:SS.FFF') '\n']))
            end%if
            %disp(['COM_ReadI2C failed, recursion depth ' num2str(RecursionDepth) ' @ ' datestr(now, 'HH:MM:SS.FFF')])
            
            % recursively retry this whole thing!
            ReturnBytes = COM_ReadI2C(Port, RequestLen, DeviceAddress, RegisterAddress, handle, RecursionDepth + 1);
            
            return 
            
        elseif (status == 224) % 224 = "Specified channel/connection not configured or busy"
            
            % for this error, we do nothing but showing a warning once...
            if (RecursionDepth == 1) && (ShowedWarning224 == false)
                warning('MATLAB:RWTHMindstormsNXT:Sensor:I2CnotConfiguredOrBusy', 'It seems the specified digital sensor is either busy or was not opened properly. If rebooting the NXT does not help, make sure the correct Open* command for this sensor has been executed, and no NXC/NBC program running on the brick has been terminated (or is currently being terminated) before/while sensor data are read. Trying to continue...');
                ShowedWarning224 = true;
            end%if
            
        end%if
        
        % already timed out?
        if etime(clock, startTime) > timeOut
            timedOut = true;
            break
        end%if
        
    end%while
    
    
%% Return bytes (be careful, they are uint8!)
    if ~timedOut
        ReturnBytes = data;
    end%if
    
    
    
    