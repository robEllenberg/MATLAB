function ToolboxUpdate()
% ToolboxUpdate
% Shows the local installed toolbox version and gets remote update
% information from the toolbox svn server.
%
%
%
% Signature
%   Author: Alexander Behrens, Linus Atorf (see AUTHORS)
%   Date: 2009/10/07
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


    %% init search pattern
    startMarker = 'a href="version-';
    endMarker = '/">';
    tagname = {};


    %% web connection
    [text status] = urlread('http://www.mindstorms.rwth-aachen.de/subversion/tags/');
    if ~status
        error('MATLAB:RWTHMindstormsNXT:CheckForUpdates','Could not connect to server!');
    end

    %% find search pattern
    indizes = findstr(text, startMarker);

    % select last version number
    for idx = indizes
        tmp = findstr(text(idx+length(startMarker):end), endMarker);
        tagname{end+1} = text(idx+length(startMarker):idx+length(startMarker)+tmp(1)-2);
    end%for


    %% start GUI
    Version_GUI(tagname);
    
end


function Version_GUI(tagnames)
    
    %% get version
     v = ver('RWTHMindstormsNXT');
 
     
     %% fill data fields
    data = cell(length(tagnames), 5);
    for n = 1:1:length(tagnames)
        
        data{n,1} = 'RWTH - Mindstorms NXT Toolbox';
        data{n,2} = tagnames{length(tagnames)-n+1};
        data{n,3} = isVersionStable(tagnames{length(tagnames)-n+1});
        
        % data field 'Installed Version'
        for m=1:length(v)
            if strcmpi(v(m).Version, tagnames{length(tagnames)-n+1})
                data{n,4} = true;
                break;
            else
                data{n,4} = false;
            end
        end
        
        data{n,5} = false;
        
    end
     
    
    %%  init GUI
    gray = [.8 .8 .8];
    
    f = figure('Position',[100 100 700 550], ...
               'NumberTitle', 'off', ...
               'MenuBar', 'none', ...
               'Name', 'RWTH - Mindstorms NXT / Check for Updates', ...
               'Color', gray);
    
    columnname     = {'Product', 'Version', 'Stable', 'Installed Version', 'Download'};
    columnformat   = {'char','char',[],[],[]};
    columnwidth    = {220, 50, 50, 'auto', 'auto'};
    columneditable = [false false false false true]; 
    
    horz_off = .1;
    width    = 1 - 2*horz_off;
    vert_off = .1;
    vline1 = 0.1;
    vline2 = 0.4;
    vline3 = 0.5;
    vline4 = 0.8;
    vline5 = 0.82;

    
    ver_text = [];
    for k=1:1:numel(v)
        ver_text = [ver_text, sprintf('%s', v(k).Version)];
        if k < numel(v)
            ver_text = [ver_text, ' and '];
        end
    end
    
    if isempty(ver_text)
        txt = 'You currently have no Release';
    else
        txt = ['You currently have Release ', ver_text];
    end
    
    txt = [txt , ...
           sprintf([' installed.\n\n', ...
                   'Updates for the RWTH - Mindstorms NXT Toolbox are listed below. ', ...
                   'You can download the\n specific toolbox versions by selecting the download fields\n\n', ... 
                   'or visiting the project page http://www.mindstorms.rwth-aachen.de'])];
    h_text = uicontrol('Style', 'text', ...
                       'HorizontalAlignment', 'left', ...
                       'Units','normalized','Position',...
                       [horz_off, vline4,  width, (vline5 - vline4)*8], ...
                       'String', txt, ...
                       'FontWeight', 'bold', ...
                       'BackgroundColor', gray, ...
                       'Parent', f);
    
    h_table = uitable('Units','normalized','Position',...
                      [horz_off, vline3,  width, (vline4 - vline3)*0.9], ...
                      'Data', data,... 
                      'ColumnName', columnname,...
                      'ColumnFormat', columnformat,...
                      'ColumnEditable', columneditable, ...
                      'RowName', [], ...
                      'ColumnWidth', columnwidth, ...
                      'Parent', f, ...
                      'CellSelectionCallback', @cell_callback, ...
                      'CellEditCallback', @cell_edit_callback);
            
   h_text2 = uicontrol('Style', 'text', ...
                        'HorizontalAlignment', 'left', ...
                        'Units','normalized','Position',...
                        [horz_off, vline2, width ,(vline3 - vline2)*0.5], ...
                        'String', 'What''s New:', ...
                        'FontWeight', 'bold', ...
                        'BackgroundColor', gray, ...
                        'Parent', f);
                  
    h_field = uicontrol('Style', 'edit', ...
                        'HorizontalAlignment', 'left', ...
                        'Units','normalized','Position',...
                        [horz_off, vline1, width ,(vline2 - vline1)*0.9], ...
                        'String', '', ...
                        'Max', 8, ...
                        'BackgroundColor', gray, ...
                        'Parent', f);
                    

                    
    %% cell callback from table
    function cell_callback(hObject, eventdata)
        
        if numel(eventdata.Indices) > 0
            c_ver = tagnames{length(tagnames)-eventdata.Indices(1)+1};
            filename = ['/ChangeLogv', c_ver, '.txt'];
            urladdress = ['http://www.mindstorms.rwth-aachen.de/subversion/tags/version-', c_ver, filename];
        
            % read changelog from server
            A = urlread(urladdress);
        
            % update text field
            set(h_field, 'String', A);
        end
    end
    

    %% cell edit callback from table
    function cell_edit_callback(hObject, eventdata)
        c_ver = tagnames{length(tagnames)-eventdata.Indices(1)+1};
        filename = ['/RWTHMindstormsNXTv', c_ver, '.zip'];
        urladdress = ['http://www.mindstorms.rwth-aachen.de/subversion/tags/version-', c_ver, filename];
        
        % download zip file
        [stat h_web] = web(urladdress);

        % disable edit field
        data = get(hObject, 'Data');
        data(eventdata.Indices(1), 5) = {false};
        set(hObject, 'Data', data);
    end
end


%% isVersionStable
function stable = isVersionStable(version)
    filename = ['/ChangeLogv', version, '.txt'];
    urladdress = ['http://www.mindstorms.rwth-aachen.de/subversion/tags/version-', version, filename];
        
    % read changelog from server
    A = urlread(urladdress);
        
    % select string to first endofline
    endofline = sprintf('\r\n');
        
    idx = strfind(A, endofline);
    if ~isempty(strfind(A(1:idx(1)), '(stable'))
        stable = true;
    else
        stable = false;
    end
end