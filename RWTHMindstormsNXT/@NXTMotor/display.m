function display( obj )
% Display method for NXTMotor objects.
%
%   DISPLAY(OBJ) displays information pertaining to the NXTMotor object OBJ.
%
% See also: NXTMotor
%
%
% Signature
%   Author: Aulis Telle, Linus Atorf (see AUTHORS)
%   Date: 2009/07/20
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

if ~isa(obj,'NXTMotor')
    error('MATLAB:RWTHMindstormsNXT:invalidObject','No NXTMotor object.');
end

if isscalar(obj)
    fprintf([...
        '\n'...
        'NXTMotor object properties:\n\n' ...
        '            Port(s): '    infoStrPort(  obj.Port)              '\n' ...
        '              Power: '    infoStrPower(obj.Power)             '\n' ...
        '    SpeedRegulation: '    infoStrOnOff( obj.SpeedRegulation)   '\n' ...
        '        SmoothStart: '    infoStrOnOff( obj.SmoothStart)   '\n' ...
        '         TachoLimit: '    infoStrTachoLimit(obj.TachoLimit)    '\n' ...
        ' ActionAtTachoLimit: '    infoStrActionAtTachoLimit( obj.ActionAtTachoLimit) '\n' ...
        '\n']);
else
    disp(obj);
end

end


%% get port info (string)
function s = infoStrPort(p)
    if numel(p) == 1
        s = num2str(p);
    else
        s = mat2str(p);
    end

    s = [s, blanks(12 - length(s)), '(', portString(p) ')'];
end %% END FUNCTION INFOSTRPORT


%% convert port to string
function s = portString(p)
    s = '';
    for k = 1:length(p)
        if k > 1
            s = [s ','];
        end
        switch(p(k))
            case 0
                s = [s, 'A'];
            case 1
                s = [s, 'B'];
            case 2
                s = [s, 'C'];
            otherwise
                s = 'undefined';
        end
    end

end %% END FUNCTION PORTSTRING


%% convert number to string
function s = infoStrNumber(n)
    s = num2str(n);
end %% END FUNTION INFOSTRNUMBER


%% convert boolean in 'on', 'off'
function s = infoStrOnOff(b)
    s = num2str(b);
    if b 
        s = [s, '           (on)'];
    else
        s = [s, '           (off)'];
    end
end %% END FUNCTION INFOSTRONOFF


%% convert boolean in 'yes', 'no'
function s = infoStrYesNo(b)
    s = num2str(b);
    if b 
        s = [s, '           (yes)'];
    else
        s = [s, '           (no)'];
    end  
end %% END FUNCTION INFOSTRYESNO

%% convert tacholimit to numer, add optional "no limit"
function s = infoStrTachoLimit(b)
    s = num2str(b);
    if b == 0 
        s = [s, '           (no limit)'];
    else
        s = [s, blanks(12 - length(s)), sprintf('(~%.1f rotations)', b/360)];
    end  
end %% END FUNCTION INFOSTRTACHOLIMIT

function s = infoStrActionAtTachoLimit(b)
    if strcmpi(b, 'coast')               
        s = '''Coast''     (turn off power at TachoLimit)';
    elseif strcmpi(b, 'brake')
        s = '''Brake''     (brake, turn off when stopped)';
    elseif strcmpi(b, 'holdbrake')
        s = '''HoldBrake'' (brake to stop, keep braking)';
    else
        s = 'undefined';
    end%if
end %% END FUNCTION INFOSTRACTIONATTACHOLIMIT

% function s = infoStrTurnRatio(b)
%     s = num2str(b);
%     if b == 0 
%         s = [s, '           (straight: same direction, same speed)'];
%     elseif abs(b) > 0 && abs(b) < 50
%         s = [s, blanks(12 - length(s)), '(same direction, different speeds)'];
%     elseif abs(b) == 50         
%         s = [s, blanks(12 - length(s)), '(one motor stopped, one rotating)'];
%     elseif abs(b) == 100                 
%         s = [s, blanks(12 - length(s)), '(opposite directions, same speed)'];
%     else
%         s = [s, blanks(12 - length(s)), '(opposite directions, different speeds)'];
%     end%ff
%     
% end %% END FUNCTION INFOSTRTURNRATIO

function s = infoStrPower(b)
    s = num2str(b);
    if b > 0 
        s = [s, blanks(12 - length(s)), '(forward)'];
    elseif b < 0
        s = [s, blanks(12 - length(s)), '(reverse)'];
    end%of
end %% END FUNCTION INFOSTRPOWER