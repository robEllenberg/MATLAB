function [sensorData motorData] = NXC_GetSensorMotorData(handle)
% Retrieves selected data from all analog sensors and all motors in a single packet
%
% Syntax
%  [sensorData motorData] = NXC_GetSensorMotorData(handle)
%
%
% Description
%  This function uses the embedded NXC program MotorControl to retrieve
%  certain data from all analog sensors and all motors connected to the NXT. The
%  sensors must already be opened. The function does no interprete any
%  data for you. The big advantage of this function is that it retrieves
%  all the data within one single Bluetooth / USB packet, which is faster
%  than retrieving all information one by one after each other...
%
% Limitations
%   This function is not yet implemented and does not return any data!
%
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2009/07/15
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

    
%% Check parameters
    % NXT handle given?
    if ~exist('handle', 'var')
        handle = COM_GetDefaultNXT();
    end%if
    
    
    warning('MATLAB:RWTHMindstormsNXT:notYetImplementedWarning', 'NXC_GetSensorMotorData is not yet implemented in this toolbox version. Continuing...');        
    
    
%% Fake output data 
    for j = 1 : 4
        sensorData(j) = struct();
    end%for
    for j = 1 : 3
        motorData(j) = struct();
    end%for
    


    