function varargout = GUI_WatchSensor(varargin)
% GUI_WATCHSENSOR M-file for GUI_WatchSensor.fig
%      GUI_WATCHSENSOR, by itself, creates a new GUI_WATCHSENSOR or raises the existing
%      singleton*.
%
%      H = GUI_WATCHSENSOR returns the handle to a new GUI_WATCHSENSOR or the handle to
%      the existing singleton*.
%
%      GUI_WATCHSENSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_WATCHSENSOR.M with the given input arguments.
%
%      GUI_WATCHSENSOR('Property','Value',...) creates a new GUI_WATCHSENSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_WatchAnalogSensor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_WatchSensor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_WatchSensor

% Last Modified by GUIDE v2.5 17-Jul-2008 15:45:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_WatchSensor_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_WatchSensor_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before GUI_WatchSensor is made visible.
function GUI_WatchSensor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_WatchSensor (see VARARGIN)

% Choose default command line output for GUI_WatchSensor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_WatchSensor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_WatchSensor_OutputFcn(hObject, eventdata, handles) 
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

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmdStart.
function cmdStart_Callback(hObject, eventdata, handles)
% hObject    handle to cmdStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


DisplayPeriod = 10; %seconds

global DisableScreenOut;
global StopSensorWatchLoop;
global USmode;
StopSensorWatchLoop = false;


%tmp = get(handles.lstPort, 'String');
port = get(handles.lstPort, 'Value') - 1; % - 1 because 1st sensor is 0
tmp = get(handles.lstSensorType, 'String');
sensortype = tmp{get(handles.lstSensorType, 'Value')};

PlotData = get(handles.chkPlotData, 'Value');

USmode = false;
if strcmpi(sensortype, 'Ultrasonic')
    USmode = true;  
end%if

h = COM_GetDefaultNXT;

OldScreenOutMode = DisableScreenOut;
DisableScreenOut = true; %#ok<NASGU>



try
    if USmode
        CloseSensor(port);
        OpenUltrasonic(port);
    else
        if NXT_SetInputMode(port, sensortype, 'PERIODCOUNTERMODE', 'reply', h) ~= 0
            errordlg('Invalid sensor type, or the specified sensor is not connected to the specified port')
            return
        end%if
    end%if
catch
    errordlg('Invalid sensor type, or the specified sensor is not connected to the specified port')
    return
end%catch


MaxYVal = 1024;
if USmode; MaxYVal = 256; end%if

axes(handles.axsSensorData);
axis([0 DisplayPeriod 0 MaxYVal]);
hold on
cla

if ~USmode
    plot([0 DisplayPeriod], [MaxYVal * 0.45 MaxYVal * 0.45], 'k--')
    plot([0 DisplayPeriod], [MaxYVal * 0.55 MaxYVal * 0.55], 'k--')
else
    plot([0 DisplayPeriod], [150 150], 'k--')
end%if
cmap = colormap(jet(MaxYVal));


time(1) = tic;
time(3) = tic;

StartBytesReceived = h.BytesReceived();
StartErrorCount = h.TransmissionErrors();

ReplyCount = 0;
MaxLatency = 0;
LatencySum = 0;

if h.ConnectionTypeValue == 1
    LineWidth = 2; % USB
else
    LineWidth = 3;
end%if
    

while(~StopSensorWatchLoop)

    if toc(time(1)) >= 1
        
        PlotData = get(handles.chkPlotData, 'Value');
        
        set(handles.txtReceivedBytes, 'String',  h.BytesReceived() - StartBytesReceived);
        StartBytesReceived = h.BytesReceived();

        set(handles.txtAvgLatency, 'String',  [num2str(ceil((LatencySum / ReplyCount) * 1000)) ' ms'] );
        LatencySum = 0;
        
        set(handles.txtMaxLatency, 'String',  [num2str(ceil(MaxLatency * 1000)) ' ms'] );
        MaxLatency = 0;
        
        set(handles.txtReplies, 'String',  ReplyCount);
        ReplyCount = 0;
        
        set(handles.txtTransmissionErrors, 'String', h.TransmissionErrors() - StartErrorCount);
        StartErrorCount = h.TransmissionErrors();

        % update current values so there's at least some kind of info
        if ~USmode            
            set(handles.txtPeriodCount, 'String', out.ScaledVal);
            set(handles.txtCurVal, 'String', out.NormalizedADVal);
        else
            set(handles.txtCurVal, 'String', out);
        end%if

        
        drawnow % need this for MATLAB to not freeze if drawing is disabled
        
        time(1) = tic;
    end%if
    
    
    time(2) = tic;
    
    if ~USmode
        out = NXT_GetInputValues(port, h);
    else
        out = GetUltrasonic(port);
        if out < 1
            % work around for color map to not crash
            out = 1;
        end%if
    end%if
    ReplyCount = ReplyCount + 1;
    
    tmp = toc(time(2));
    LatencySum = LatencySum + tmp;
    if tmp > MaxLatency, MaxLatency = tmp; end
 
   
    if toc(time(3)) > DisplayPeriod
        time(3) = tic;
        cla
        if ~USmode
            plot([0 DisplayPeriod], [MaxYVal * 0.45 MaxYVal * 0.45], 'k--')
            plot([0 DisplayPeriod], [MaxYVal * 0.55 MaxYVal * 0.55], 'k--')
        else
            plot([0 DisplayPeriod], [150 150], 'k--')
        end%if
    end%if

    
    if PlotData
        if ~USmode            
            set(handles.txtPeriodCount, 'String', out.ScaledVal);
            set(handles.txtCurVal, 'String', out.NormalizedADVal);
            plot([toc(time(3)) toc(time(3))], [0 out.NormalizedADVal], 'LineWidth', LineWidth, 'Color', cmap(out.NormalizedADVal + 1, :))
        else
            set(handles.txtCurVal, 'String', out);
            plot([toc(time(3)) toc(time(3))], [0 out], 'LineWidth', LineWidth, 'Color', cmap(out + 1, :))
        end%if

        drawnow
    end%if
    
    
end%while

try
    CloseSensor(SENSOR_1);
    CloseSensor(SENSOR_2);
    CloseSensor(SENSOR_3);
    CloseSensor(SENSOR_4);
catch
    % nothing
end%try
    
DisableScreenOut = OldScreenOutMode;


% --- Executes on button press in cmdStop.
function cmdStop_Callback(hObject, eventdata, handles)
% hObject    handle to cmdStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global StopSensorWatchLoop;
StopSensorWatchLoop = true;


function txtPeriodCount_Callback(hObject, eventdata, handles)
% hObject    handle to txtPeriodCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtPeriodCount as text
%        str2double(get(hObject,'String')) returns contents of txtPeriodCount as a double


% --- Executes during object creation, after setting all properties.
function txtPeriodCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtPeriodCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
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


% --- Executes on selection change in lstSensorType.
function lstSensorType_Callback(hObject, eventdata, handles)
% hObject    handle to lstSensorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lstSensorType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstSensorType


% --- Executes during object creation, after setting all properties.
function lstSensorType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstSensorType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in cmdResetCount.
function cmdResetCount_Callback(hObject, eventdata, handles)
% hObject    handle to cmdResetCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cmdResetCount
global USmode

if ~USmode
    %h = COM_GetDefaultNXT;
    port = get(handles.lstPort, 'Value') - 1;
    NXT_ResetInputScaledValue(port)
end%if




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% if default handle set, ok, if not, create one...
try
    h = COM_GetDefaultNXT();
    % but we don't trust this handle, so let's be careful and check it
    status = NXT_SendKeepAlive('reply');
    if status ~= 0
        COM_CloseNXT('all', 'bluetooth.ini');
        COM_SetDefaultNXT(COM_OpenNXT('bluetooth.ini'));
    end%if
catch
    COM_CloseNXT('all', 'bluetooth.ini');
    COM_SetDefaultNXT(COM_OpenNXT('bluetooth.ini'));
end%try






function txtCurVal_Callback(hObject, eventdata, handles)
% hObject    handle to txtCurVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtCurVal as text
%        str2double(get(hObject,'String')) returns contents of txtCurVal as a double


% --- Executes during object creation, after setting all properties.
function txtCurVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtCurVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function txtTransmissionErrors_Callback(hObject, eventdata, handles)
% hObject    handle to txtTransmissionErrors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtTransmissionErrors as text
%        str2double(get(hObject,'String')) returns contents of txtTransmissionErrors as a double


% --- Executes during object creation, after setting all properties.
function txtTransmissionErrors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtTransmissionErrors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in lstPort.
function lstPort_Callback(hObject, eventdata, handles)
% hObject    handle to lstPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lstPort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstPort


% --- Executes during object creation, after setting all properties.
function lstPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on button press in chkPlotData.
function chkPlotData_Callback(hObject, eventdata, handles)
% hObject    handle to chkPlotData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkPlotData


