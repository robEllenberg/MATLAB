function varargout = GUI_WatchMotorState(varargin)
% GUI_WATCHMOTORSTATE M-file for GUI_WatchMotorState.fig
%      GUI_WATCHMOTORSTATE, by itself, creates a new GUI_WATCHMOTORSTATE or raises the existing
%      singleton*.
%
%      H = GUI_WATCHMOTORSTATE returns the handle to a new GUI_WATCHMOTORSTATE or the handle to
%      the existing singleton*.
%
%      GUI_WATCHMOTORSTATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_WATCHMOTORSTATE.M with the given input arguments.
%
%      GUI_WATCHMOTORSTATE('Property','Value',...) creates a new GUI_WATCHMOTORSTATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_WatchMotorState_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_WatchMotorState_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% txtport the above text to modify the response to help GUI_WatchMotorState

% Last Modified by GUIDE v2.5 09-Oct-2007 14:14:36

% Begin initialization code - DO NOT TXTPORT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_WatchMotorState_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_WatchMotorState_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT TXTPORT


% --- Executes just before GUI_WatchMotorState is made visible.
function GUI_WatchMotorState_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_WatchMotorState (see VARARGIN)

% Choose default command line output for GUI_WatchMotorState
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_WatchMotorState wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_WatchMotorState_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function txtPort_Callback(hObject, eventdata, handles)
% hObject    handle to txtPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPort as text
%        str2double(get(hObject,'String')) returns contents of txtPort as a double


% --- Executes during object creation, after setting all properties.
function txtPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: txtPort controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmdStart.
function cmdStart_Callback(hObject, eventdata, handles)
% hObject    handle to cmdStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ****************

global DisableScreenOut;
global StopMotorWatchLoop;
StopMotorWatchLoop = false;


port = str2double(get(handles.txtPort, 'String'));
h = COM_GetDefaultNXT;

OldScreenOutMode = DisableScreenOut;
DisableScreenOut = true; %#ok<NASGU>


time(1) = tic;
StartBytesReceived = h.BytesReceived();

ReplyCount = 0;
MaxLatency = 0;
LatencySum = 0;
while(~StopMotorWatchLoop)
    
    if toc(time(1)) >= 1
        
        set(handles.txtReceivedBytes, 'String',  h.BytesReceived() - StartBytesReceived);
        StartBytesReceived = h.BytesReceived();
           
        set(handles.txtAvgLatency, 'String',  [num2str(ceil((LatencySum / ReplyCount) * 1000)) ' ms'] );
        LatencySum = 0;
        
        set(handles.txtMaxLatency, 'String',  [num2str(ceil(MaxLatency * 1000)) ' ms'] );
        MaxLatency = 0;
        
        set(handles.txtReplies, 'String',  ReplyCount);
        ReplyCount = 0;
        
        time(1) = tic;
    end%if
    
    
    time(2) = tic;
    
    out = NXT_GetOutputState(port, h);
    ReplyCount = ReplyCount + 1;
    
    tmp = toc(time(2));
    LatencySum = LatencySum + tmp;
    if tmp > MaxLatency, MaxLatency = tmp; end
    
    
    
    set(handles.txtPower, 'String', out.Power);
    
    if out.ModeIsMOTORON
        set(handles.chkMOTORON, 'Value', 1);
    else
        set(handles.chkMOTORON, 'Value', 0);
    end%if
    if out.ModeIsBRAKE
        set(handles.chkBRAKE, 'Value', 1);
    else
        set(handles.chkBRAKE, 'Value', 0);
    end%if
    if out.ModeIsREGULATED
        set(handles.chkREGULATED, 'Value', 1);
    else
        set(handles.chkREGULATED, 'Value', 0);
    end%if
    
    set(handles.txtRegMode, 'String', out.RegModeName);
    set(handles.txtRunState, 'String', out.RunStateName);
    set(handles.txtTurnRatio, 'String', out.TurnRatio);
    set(handles.txtTachoLimit, 'String', out.TachoLimit);
    set(handles.txtTachoCount, 'String', out.TachoCount);
    set(handles.txtBlockTachoCount, 'String', out.BlockTachoCount);
    set(handles.txtRotationCount, 'String', out.RotationCount);
    
    
    drawnow
    
    
end%while
DisableScreenOut = OldScreenOutMode;


% ****************



% --- Executes on button press in cmdStop.
function cmdStop_Callback(hObject, eventdata, handles)
% hObject    handle to cmdStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global StopMotorWatchLoop;
StopMotorWatchLoop = true;

function txtPower_Callback(hObject, eventdata, handles)
% hObject    handle to txtPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPower as text
%        str2double(get(hObject,'String')) returns contents of txtPower as a double


% --- Executes during object creation, after setting all properties.
function txtPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRegMode_Callback(hObject, eventdata, handles)
% hObject    handle to txtRegMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRegMode as text
%        str2double(get(hObject,'String')) returns contents of txtRegMode as a double


% --- Executes during object creation, after setting all properties.
function txtRegMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRegMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTurnRatio_Callback(hObject, eventdata, handles)
% hObject    handle to txtTurnRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTurnRatio as text
%        str2double(get(hObject,'String')) returns contents of txtTurnRatio as a double


% --- Executes during object creation, after setting all properties.
function txtTurnRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTurnRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtRunState_Callback(hObject, eventdata, handles)
% hObject    handle to txtRunState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRunState as text
%        str2double(get(hObject,'String')) returns contents of txtRunState as a double


% --- Executes during object creation, after setting all properties.
function txtRunState_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRunState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTachoLimit_Callback(hObject, eventdata, handles)
% hObject    handle to txtTachoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTachoLimit as text
%        str2double(get(hObject,'String')) returns contents of txtTachoLimit as a double


% --- Executes during object creation, after setting all properties.
function txtTachoLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTachoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtTachoCount_Callback(hObject, eventdata, handles)
% hObject    handle to txtTachoCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTachoCount as text
%        str2double(get(hObject,'String')) returns contents of txtTachoCount as a double


% --- Executes during object creation, after setting all properties.
function txtTachoCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTachoCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtBlockTachoCount_Callback(hObject, eventdata, handles)
% hObject    handle to txtBlockTachoCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtBlockTachoCount as text
%        str2double(get(hObject,'String')) returns contents of txtBlockTachoCount as a double


% --- Executes during object creation, after setting all properties.
function txtBlockTachoCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtBlockTachoCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkMOTORON.
function chkMOTORON_Callback(hObject, eventdata, handles)
% hObject    handle to chkMOTORON (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkMOTORON


% --- Executes on button press in chkBRAKE.
function chkBRAKE_Callback(hObject, eventdata, handles)
% hObject    handle to chkBRAKE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkBRAKE


% --- Executes on button press in chkREGULATED.
function chkREGULATED_Callback(hObject, eventdata, handles)
% hObject    handle to chkREGULATED (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkREGULATED



function txtRotationCount_Callback(hObject, eventdata, handles)
% hObject    handle to txtRotationCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtRotationCount as text
%        str2double(get(hObject,'String')) returns contents of txtRotationCount as a double


% --- Executes during object creation, after setting all properties.
function txtRotationCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtRotationCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtReplies_Callback(hObject, eventdata, handles)
% hObject    handle to txtReplies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtReplies as text
%        str2double(get(hObject,'String')) returns contents of txtReplies as a double


% --- Executes during object creation, after setting all properties.
function txtReplies_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtReplies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtReceivedBytes_Callback(hObject, eventdata, handles)
% hObject    handle to txtReceivedBytes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtReceivedBytes as text
%        str2double(get(hObject,'String')) returns contents of txtReceivedBytes as a double


% --- Executes during object creation, after setting all properties.
function txtReceivedBytes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtReceivedBytes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtAvgLatency_Callback(hObject, eventdata, handles)
% hObject    handle to txtAvgLatency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtAvgLatency as text
%        str2double(get(hObject,'String')) returns contents of txtAvgLatency as a double


% --- Executes during object creation, after setting all properties.
function txtAvgLatency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtAvgLatency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtMaxLatency_Callback(hObject, eventdata, handles)
% hObject    handle to txtMaxLatency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtMaxLatency as text
%        str2double(get(hObject,'String')) returns contents of txtMaxLatency as a double


% --- Executes during object creation, after setting all properties.
function txtMaxLatency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtMaxLatency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


    % if default handle set, ok, if not, create one...
    try
        h = COM_GetDefaultNXT();
    catch
        COM_CloseNXT('all', 'bluetooth.ini');
        COM_SetDefaultNXT(COM_OpenNXT('bluetooth.ini'))
    end%try


% --- Executes on button press in cmdRunReg0.
function cmdRunReg0_Callback(hObject, eventdata, handles)
% hObject    handle to cmdRunReg0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
    
    %SetOutputState_B(h, 'direct', 0, 25, 'MOTORON+BRAKE+REGULATED', 'MOTOR_SPEED', 0, 'RUNNING', 'inf')
    NXT_SetOutputState(0, ...
        25, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        'SPEED', ... % sync to speed why not
        0, ...
        'RUNNING', ... % again, IDLE would disable power => COAST mode
        0, ...
        'dontreply');
    


% --- Executes on button press in cmdStopAll.
function cmdStopAll_Callback(hObject, eventdata, handles)
% hObject    handle to cmdStopAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    %h = COM_GetDefaultNXT;
    %SetOutputState_B(h, 'direct', 255, 0, 'MOTOROFF', 'IDLE', 0, 'IDLE', 0)
    StopMotor all off


% --- Executes on button press in cmdDriveRampUp.
function cmdDriveRampUp_Callback(hObject, eventdata, handles)
% hObject    handle to cmdDriveRampUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    
    NXT_ResetMotorPosition(1, true);
    NXT_ResetMotorPosition(2, true);
    NXT_ResetMotorPosition(1, false);
    NXT_ResetMotorPosition(2, false);

    %out = NXT_GetOutputState(2, h);
      
    %SetOutputState_B(h, 'direct', 1, 80, 'MOTORON+BRAKE+REGULATED', 'MOTOR_SYNC', 0, 'RAMPUP', 3000)
    %SetOutputState_B(h, 'direct', 2, 80, 'MOTORON+BRAKE+REGULATED', 'MOTOR_SYNC', 0, 'RAMPUP', 3000)

    NXT_SetOutputState(1, ...
        80, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        'SYNC', ... % sync to speed why not
        0, ...
        'RAMPUP', ... % again, IDLE would disable power => COAST mode
        3000, ...
        'dontreply');
    
    NXT_SetOutputState(2, ...
        80, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        'SYNC', ... % sync to speed why not
        0, ...
        'RAMPUP', ... % again, IDLE would disable power => COAST mode
        3000, ...
        'dontreply');
    
    
% --- Executes on button press in cmdDriveRampDown.
function cmdDriveRampDown_Callback(hObject, eventdata, handles)
% hObject    handle to cmdDriveRampDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







function txtNewPower_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewPower as text
%        str2double(get(hObject,'String')) returns contents of txtNewPower as a double


% --- Executes during object creation, after setting all properties.
function txtNewPower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewPower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewTachoLimit_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewTachoLimit as text
%        str2double(get(hObject,'String')) returns contents of txtNewTachoLimit as a double


% --- Executes during object creation, after setting all properties.
function txtNewTachoLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmdSetOutputState.
function cmdSetOutputState_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSetOutputState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global DisableScreenOut;
    OldDisableScreenOut = DisableScreenOut;
    DisableScreenOut = false; %#ok<NASGU>
    
    port = str2double(get(handles.txtPort, 'String'));
    power = str2double(get(handles.txtNewPower, 'String'));
    tacholimit = str2double(get(handles.txtNewTachoLimit, 'String'));
    
    if (get(handles.chkSpeedRegulated, 'Value')) == 1
        speedsync = 'SPEED';
    else
        speedsync = 'IDLE';
    end%if
    
    NXT_SetOutputState(port, ...
        power, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        speedsync, ... % sync to speed why not
        0, ...
        'RUNNING', ... % again, IDLE would disable power => COAST mode
        tacholimit, ...
        'dontreply', ... 
        COM_GetDefaultNXT);

    DisableScreenOut = OldDisableScreenOut;

% --- Executes on button press in cmdResetAbsolute.
function cmdResetAbsolute_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetAbsolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global DisableScreenOut;
    OldDisableScreenOut = DisableScreenOut;
    DisableScreenOut = false; %#ok<NASGU>


    port = str2double(get(handles.txtPort, 'String'));
    NXT_ResetMotorPosition(port, false);

    DisableScreenOut = OldDisableScreenOut;

% --- Executes on button press in cmdResetRelative.
function cmdResetRelative_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetRelative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global DisableScreenOut;
    OldDisableScreenOut = DisableScreenOut;
    DisableScreenOut = false; %#ok<NASGU>


    port = str2double(get(handles.txtPort, 'String'));
    NXT_ResetMotorPosition(port, true);

    DisableScreenOut = OldDisableScreenOut;



function txtNewTachoLimit1_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewTachoLimit1 as text
%        str2double(get(hObject,'String')) returns contents of txtNewTachoLimit1 as a double


% --- Executes during object creation, after setting all properties.
function txtNewTachoLimit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewTachoLimit2_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewTachoLimit2 as text
%        str2double(get(hObject,'String')) returns contents of txtNewTachoLimit2 as a double


% --- Executes during object creation, after setting all properties.
function txtNewTachoLimit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewTachoLimit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewPower1_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewPower1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewPower1 as text
%        str2double(get(hObject,'String')) returns contents of txtNewPower1 as a double


% --- Executes during object creation, after setting all properties.
function txtNewPower1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewPower1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewPower2_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewPower2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewPower2 as text
%        str2double(get(hObject,'String')) returns contents of txtNewPower2 as a double


% --- Executes during object creation, after setting all properties.
function txtNewPower2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewPower2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewTurnRatio1_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewTurnRatio1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewTurnRatio1 as text
%        str2double(get(hObject,'String')) returns contents of txtNewTurnRatio1 as a double


% --- Executes during object creation, after setting all properties.
function txtNewTurnRatio1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewTurnRatio1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txtNewTurnRatio2_Callback(hObject, eventdata, handles)
% hObject    handle to txtNewTurnRatio2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtNewTurnRatio2 as text
%        str2double(get(hObject,'String')) returns contents of txtNewTurnRatio2 as a double


% --- Executes during object creation, after setting all properties.
function txtNewTurnRatio2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtNewTurnRatio2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmdSubmit1.
function cmdSubmit1_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSubmit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global DisableScreenOut;
    OldDisableScreenOut = DisableScreenOut;
    DisableScreenOut = false; %#ok<NASGU>
    
    
    power1 = str2double(get(handles.txtNewPower1, 'String'));
    tacholimit1 = str2double(get(handles.txtNewTachoLimit1, 'String'));
    turnratio1 = str2double(get(handles.txtNewTurnRatio1, 'String'));
   
    
    NXT_SetOutputState(1, ...
        power1, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        'SYNC', ... 
        turnratio1, ...
        'RUNNING', ... % again, IDLE would disable power => COAST mode
        tacholimit1, ...
        'dontreply', ... 
        COM_GetDefaultNXT);
    

    
    DisableScreenOut = OldDisableScreenOut;



% --- Executes on button press in cmdResetBothAbsolute.
function cmdResetBothAbsolute_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetBothAbsolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    NXT_ResetMotorPosition(1, false);
    NXT_ResetMotorPosition(2, false);

% --- Executes on button press in cmdResetBothRelative.
function cmdResetBothRelative_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetBothRelative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    NXT_ResetMotorPosition(1, true);
    NXT_ResetMotorPosition(2, true);


% --- Executes on button press in cmdSubmit2.
function cmdSubmit2_Callback(hObject, eventdata, handles)
% hObject    handle to cmdSubmit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  
    power2 = str2double(get(handles.txtNewPower2, 'String'));
    tacholimit2 = str2double(get(handles.txtNewTachoLimit2, 'String'));
    turnratio2 = str2double(get(handles.txtNewTurnRatio2, 'String'));
    
    NXT_SetOutputState(2, ...
        power2, ...
        true, ... % motor always on, otherwise this would be COAST mode
        true, ... % brake on
        'SYNC', ... 
        turnratio2, ...
        'RUNNING', ... % again, IDLE would disable power => COAST mode
        tacholimit2, ...
        'dontreply', ... 
        COM_GetDefaultNXT);



% --- Executes on button press in chkSpeedRegulated.
function chkSpeedRegulated_Callback(hObject, eventdata, handles)
% hObject    handle to chkSpeedRegulated (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkSpeedRegulated




% --- Executes on button press in cmdResetMemoryCounter.
function cmdResetMemoryCounter_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetMemoryCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    NXT_StartProgram('ResetCounter');
    pause(0.5)
    NXT_StopProgram();
