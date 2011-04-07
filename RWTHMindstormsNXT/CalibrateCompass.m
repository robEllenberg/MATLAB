function [ok] = CalibrateCompass(port, f_start, varargin)
% Enables calibration mode of the HiTechnic compass sensor
%
% Syntax
%  CalibrateCompass(port, f_start)
%
%  CalibrateCompass(port, f_start, handle)
%
% Description
%   Calibrate the compass to reduce influence of metallic objects,
%   especially of the NXT motor and brick on compass values.
%   You have to calibrate a roboter only once until the design changes.
%   During calibration the compass should make two full rotations very slowly.
%   The compass sensor has to be opened (using OpenCompass) before execution.
% 
%   Set f_start = true to start calibration mode, and f_start = false to stop it.
%   In between those commands, the calibration (compass rotation) should occur.
%
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4
%   analog to the labeling on the NXT Brick. 
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%
%
%     % compass must be open for calibration
%     OpenCompass(SENSOR_2);
%
%     % enable calibration mode
%     CalibrateCompass(SENSOR_2, true);
%
%     % compass is attached to motor A, rotate 2 full turns
%     m = NXTMotor('A', 'Power', 5, 'TachoLimit', 720)
%     m.SendToNXT();
%
%     m.WaitFor();
%
%     % calibration should now be complete!
%     CalibrateCompass(SENSOR_2, false);
%
% See also: OpenCompass, GetCompass, CloseSensor, NXT_LSRead, NXT_LSWrite
%
% Signature
%   Author: Rainer Schnitzler, Linus Atorf (see AUTHORS)
%   Date: 2008/08/01
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

%% Check Parameter
    if nargin < 2
        error('MATLAB:RWTHMindstormsNXT:notEnoughInputArguments', 'Two function parameter are required, port and start/stop mode');
    end
    
    
    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
%% create this I2C command to start callibration
    
    if f_start
      waitUntilI2CReady(port, handle);
      I2Cdata = hex2dec(['02'; '41'; '43']); % Command (41): Start callibration (43) 
      NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle); 
      ok = true;
    else
      % set back to 0
      waitUntilI2CReady(port, handle);
      I2Cdata = hex2dec(['02'; '41'; '00']); % Command (41): Stop callibration (00)      
      NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
      
      % wait for compass sensor to get ready and decide wether calibration
      % was successful (it writes a 2 in case calibration failed)
      pause(0.2); % 200ms, just a guess... enough or too long?
      
      % retrieve 1 byte from device 0x02, register 0x41    
      data = COM_ReadI2C(port, 1, uint8(2), uint8(65), handle);      % calibration ok ?
      if isempty(data) || (data == 2)
         ok = false;
      else
         ok = true;
      end
    end
    
end%function
