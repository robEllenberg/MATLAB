function [flag err_message] = checkStatusByte(f_resp)
% Interpretes the status byte of a return package, returns error message
%  
% Syntax
%   [flag err_message] = checkStatusByte(response) 
%
% Description
%   [flag err_message] = checkStatusByte(response) interpretes the response byte (not
%   hexadecimal). The return value flag indicates wether an error has occured 
%   (true = error, false = success). The string value err_message contains
%   the error message (or '' in case of success).
%
% Example
%   [status SleepTimeLimit] = NXT_SendKeepAlive('reply');
%   [err errmsg] = checkStatusByte(status);
%
% See also: COM_CollectPacket, NXT_LSGetStatus
%
% Signature
%   Author: Linus Atorf (see AUTHORS)
%   Date: 2007/10/15
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

    if f_resp == 0
        flag = false;
        err_message = '';
        return;
    else
        flag = true;
    end%if

    %TODO improve performance by changing hex-values to dec-values, hence
    % saving string comparisions and dec2hex...
    % since we usually don't have errors, this is low-priority
    
    f_resp_hex = num2str(dec2hex(f_resp, 2));
    switch (f_resp_hex)
        % we introduce this 0x01 custom error (NOT from LEGO Mindstorms
        % Documentation). It happens when we try to collect a packet but
        % there were no data received (the statusbyte is then still
        % initialized to 1):
        case '01'
            err_message = 'Empty packet: no data received';
        % standard errors from NXT documentation
        case '20'
            err_message = 'Pending communication transaction in progress';
        case '40'
            err_message = 'Specified mailbox queue is empty';
        case 'BD'
            err_message = 'Request failed (i.e. specified file not found)';
        case 'BE'
            err_message = 'Unknown command opcode';
        case 'BF'
            err_message = 'Insane packet';
        case 'C0'
            err_message = 'Data contains out-of-range values';
        case 'DD'
            err_message = 'Communication bus error';
        case 'DE'
            err_message = 'No free memory in communication buffer';
        case 'DF'
            err_message = 'Specified channel/connection is not valid';
        case 'E0'
            err_message = 'Specified channel/connection not configured or busy';
        case 'EC'
            err_message = 'No active program';
        case 'ED'
            err_message = 'Illegal size specified';
        case 'EE'
            err_message = 'Illegal mailbox queue ID specified';
        case 'EF'
            err_message = 'Attempted to access invalid field of a structure';
        case 'F0'
            err_message = 'Bad input or output specified';
        case 'FB'
            err_message = 'Insufficient memory available';
        case 'FF'
            err_message = 'Bad arguments';
        otherwise
            err_message = 'Unknown Error';
    end
    
end%function
