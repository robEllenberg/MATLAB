function varargout = CalibrateEOPD(port, calibrationMode, varargin)
% Calibrates the HiTechnic EOPD sensor (measures/sets calibration matrix)
%
% Syntax
%   CalibrateEOPD(port, 'NEAR', nearDist)
%
%   CalibrateEOPD(port, 'FAR', farDist)
%
%   calibMatrix = CalibrateEOPD(port, 'READMATRIX')
%
%   CalibrateEOPD(port, 'SETMATRIX', calibMatrix)
%
% Description
%   To help you make sense of the HiTechnic EOPD sensor values, this
%   function can calibrate the sensor. The method is based on this article:
%   http://www.hitechnic.com/blog/eopd-sensor/eopd-how-to-measure-distance/#more-178
%
%   Before your start calibration, open the sensor using OpenEOPD and a
%   mode of your choice. Please note: The calibration will be valid for
%   this mode only. So if you choose long range mode during calibration,
%   you must use this mode all the time when working with this specific
%   calibration setting.
%
%   The calibration process is straight forward. You place the sensor at a
%   known distance in front of a surface. First you need to chose a short
%   distance, e.g. around 3cm (not too close). Then you call this function with 
%   calibrationMode = 'NEAR', followed by nearDist set to the actual
%   distance. This can be centimeters, millimeters, or LEGO studs. The unit
%   doesn't matter as long as you keep it consistend. The value later
%   returned by GetEOPD will be in this exact units.
%
%   As second step, you have to place the sensor at another known distance,
%   preferrably at the end of the range. Let's just say we use 9cm this
%   time. Now call this functions with calibrationMode = 'FAR', followed
%   by a 9. That's it. The sensor is now calibrated.
%
%   Before you continue to use the sensor, you should retrieve the 
%   calibration matrix and store it for later use. This matrix is
%   essentialy just a combination of the two distances you used for
%   calibration, and the according EOPD raw sensor readings. Out of these
%   two data pairs, the distance mapping is calculated, which is used inside
%   GetEOPD. To retrieve the matrix, call calibMatrix =
%   CalibrateEOPD(port, 'READMATRIX').
%
%   If later on you want to leave out the calibration of a specific EOPD
%   sensor for certain environmental conditions, you can simply re-use the
%   calibration matrix. Call CalibrateEOPD(port, 'SETMATRIX',
%   calibMatrix). The format of the 2x2 calibMatrix is:
%   [nearDist nearEOPD; farDist farEOPD].
% 
%   To summarize:
% 
% # Use the 'NEAR' mode with a short distance to the surface.
% # Use the 'FAR' mode with a long distance to the surface (all
%   relatively. The order can be swapped).
% # Retrieve and store the calibration matrix using the 'READMATRIX'
% mode.
% # Later on, if you want to skip steps 1 - 3, just directly load the matrix
% from step 3 using the 'SETMATRIX' mode.
% 
%   
% Limitations
%   Calibration is stored inside the NXT handle, for a specific port. This
%   means after closing the NXT handle, or when connecting the sensor to
%   another port, calibration is lost. That is why you should either always
%   run the calibration at the begin of your program, or restore the
%   previous state with the 'SETMATRIX' calibration mode.
%
%   Unlike most other functions, this one cannot be called with an NXT
%   handle as last argument. Please use COM_SetDefaultNXT before.
%
%
% Examples
%   port = SENSOR_2;
%   OpenEOPD(port, 'SHORT');
%
%   % place sensor to 3cm distance, you can also try 2cm or similar
%   CalibrateEOPD(port, 'NEAR', 3);
%   pause;
%
%   % place sensor to 9cm distance, you can also try 10cm or similar
%   CalibrateEOPD(port, 'FAR', 9);
%
%   % retrieve & display calibration matrix
%   calibMatrix = CalibrateEOPD(port, 'READMATRIX');
%   disp(calibMatrix);
%
%   % now the sensor can be used
%   [dist raw] = GetEOPD(port);
%
%   % clean up, as usual. LED stays on anyway
%   CloseSensor(port);
%
%   % Later on in another program, you can
%   % restore the calibration:
%   OpenEOPD(port, 'SHORT'); % use same mode as for calibration
%
%   % manually set calibMatrix or load from file
%
%   % now restore calibration
%   CalibrateEOPD(port, 'SETMATRIX', calibMatrix);
%
%   % sensor ready to be used now...
%
% See also: OpenEOPD, GetEOPD, CloseSensor, NXT_SetInputMode, NXT_GetInputValues
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 20010/09/22
%   Copyright: 2007-2011, RWTH Aachen University
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





%% Parameter check
    
    % valid mode?
    if ~strcmpi(calibrationMode, 'NEAR') && ~strcmpi(calibrationMode, 'FAR') && ...
       ~strcmpi(calibrationMode, 'READMATRIX') && ~strcmpi(calibrationMode, 'SETMATRIX')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Calibration mode for HiTechnic EOPD sensor has to be either ''NEAR'', ''FAR'', ''READMATRIX'', or ''SETMATRIX''');
    end%if

    % except strings as input
    if ischar(port)
        port = double(port);
    end%if
    if port < 0 || port > 3 
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT InputPort must be between 0 and 3 (use constants SENSOR_1 to SENSOR_4)');
    end%if
    
        
%% Get handle
   handle = COM_GetDefaultNXT();
   
   
%% Modes...

    if strcmpi(calibrationMode, 'NEAR')
        
        if nargin < 3 || ~isfloat(varargin{1}) || varargin{1} <= 0
            error('MATLAB:RWTHMindstormsNXT:Sensor:invalidEOPDCalibration', 'With ''NEAR'' calibration mode for the EOPD sensor, a valid positive distance must be specified as argument after ''NEAR''!');
        end%if
        if nargout > 0 
              error('MATLAB:RWTHMindstormsNXT:tooManyOutputArguments', 'With calibration mode ''NEAR'', this functions does not return any output arguments.');
        end%if
        
        nearDist = varargin{1};
        
        [dontcare nearEOPD] = GetEOPD(port);
        
        curMatrix = handle.EOPDSensorMatrix(port);
        %format: [nearDist nearEOPD; farDist farEOPD] 
        curMatrix(1, :) = [nearDist nearEOPD];
        % and write back:
        handle.EOPDSensorMatrix(port, curMatrix);

    elseif strcmpi(calibrationMode, 'FAR')
        
        if nargin < 3 || ~isfloat(varargin{1}) || varargin{1} <= 0
            error('MATLAB:RWTHMindstormsNXT:Sensor:invalidEOPDCalibration', 'With ''FAR'' calibration mode for the EOPD sensor, a valid positive distance must be specified as argument after ''FAR''!');
        end%if
        if nargout > 0 
              error('MATLAB:RWTHMindstormsNXT:tooManyOutputArguments', 'With calibration mode ''FAR'', this functions does not return any output arguments.');
        end%if
        
        farDist = varargin{1};
        
        [dontcare farEOPD] = GetEOPD(port);
        
        curMatrix = handle.EOPDSensorMatrix(port);
        %format: [nearDist nearEOPD; farDist farEOPD] 
        curMatrix(2, :) = [farDist farEOPD];
        % and write back:
        handle.EOPDSensorMatrix(port, curMatrix);
        
    elseif strcmpi(calibrationMode, 'READMATRIX')
        
        varargout{1} = handle.EOPDSensorMatrix(port);
        return;
        
    elseif strcmpi(calibrationMode, 'SETMATRIX')
        
        if nargin < 3 || ~isfloat(varargin{1})
            error('MATLAB:RWTHMindstormsNXT:Sensor:invalidEOPDCalibration', 'With ''SETMATRIX'' calibration mode for the EOPD sensor, a valid 2x2 calibration matrix must be specified as argument after ''SETMATRIX''!');
        end%if
        if nargout > 0 
              error('MATLAB:RWTHMindstormsNXT:tooManyOutputArguments', 'With calibration mode ''SETMATRIX'', this functions does not return any output arguments.');
        end%if
        
        calibMatrix = varargin{1};
        if nnz(size(calibMatrix) == [2 2]) ~= 2 || nnz(calibMatrix > 0) ~= 4
            error('MATLAB:RWTHMindstormsNXT:Sensor:invalidEOPDCalibration', 'Invalid EOPD calibration matrix. Matrix must be 2x2 and positive!');
        end%if
        
        
        handle.EOPDSensorMatrix(port, calibMatrix);
        
    end%if


end%function
