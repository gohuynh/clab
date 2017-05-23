function varargout = Detect_Lightning_Main_Dev(varargin)
% DETECT_LIGHTNING_MAIN_DEV MATLAB code for Detect_Lightning_Main_Dev.fig
%      DETECT_LIGHTNING_MAIN_DEV, by itself, creates a new DETECT_LIGHTNING_MAIN_DEV or raises the existing
%      singleton*.
%
%      H = DETECT_LIGHTNING_MAIN_DEV returns the handle to a new DETECT_LIGHTNING_MAIN_DEV or the handle to
%      the existing singleton*.
%
%      DETECT_LIGHTNING_MAIN_DEV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETECT_LIGHTNING_MAIN_DEV.M with the given input arguments.
%
%      DETECT_LIGHTNING_MAIN_DEV('Property','Value',...) creates a new DETECT_LIGHTNING_MAIN_DEV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Detect_Lightning_Main_Dev_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Detect_Lightning_Main_Dev_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Detect_Lightning_Main_Dev

% Last Modified by GUIDE v2.5 23-May-2017 09:37:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Detect_Lightning_Main_Dev_OpeningFcn, ...
                   'gui_OutputFcn',  @Detect_Lightning_Main_Dev_OutputFcn, ...
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


% --- Executes just before Detect_Lightning_Main_Dev is made visible.
function Detect_Lightning_Main_Dev_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Detect_Lightning_Main_Dev (see VARARGIN)

% Choose default command line output for Detect_Lightning_Main_Dev
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% move GUI in the middle of the screen
movegui('center');

% UIWAIT makes Detect_Lightning_Main_Dev wait for user response (see UIRESUME)
% uiwait(handles.MainGUI);

% Global Variables
global initReady;
global plotReady;
global aChannels;
global psd_info;
global latMag;
global latDir;
global longMag;
global longDir;
global pn;
global statName;
global sampRate;
global sensRef;
global keepRunning;
global IRIGtime;
global suffix;
global plotLive;
global fig1Chan;
global fig2Chan;
global fig_one;
global fig_two;
global ylow;
global yhigh;
global saveType;
global saveMemory;
global saveTime;
global IRIGtype;
global newSave;
global showPlot;

keepRunning = 0;
initReady = [0 0 0 0 0 0 ...
             0 0 0 0 0 1 ...
             0];
% [(1)sampRate (2)statName (3)sensorRef (4)saveFolder (5)latMag (6)latDir
% (7)longMag (8)longDir (9)IRIGtime (10)saveType (11)saveAmount (12)livePlot
% (13)IRIGtype]
plotReady = [0 0 0 0];
% [(1)fig1 (2)fig2 (3)lowYLim (4)highYLim]
aChannels = [1 0 0 0 0 0 0 0];
psd_info = [];
pn = '';
newSave = [];
getConfig(hObject, eventdata, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Detect_Lightning_Main_Dev_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function latMagText_Callback(hObject, eventdata, handles)
% hObject    handle to latMagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of latMagText as text
%        str2double(get(hObject,'String')) returns contents of latMagText as a double
global latMag;
global initReady;
latMag = str2double(get(handles.latMagText,'String'));
if latMag < 0 || latMag > 90
    latMag = [];
    initReady(5) = 0;
else
    initReady(5) = 1;
end
checkReady(handles);

% --- Executes during object creation, after setting all properties.
function latMagText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latMagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in latMenu.
function latMenu_Callback(hObject, eventdata, handles)
% hObject    handle to latMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns latMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from latMenu
global latDir;
global initReady;
if get(handles.latMenu,'Value') == 1;
    initReady(6) = 0;
else
    initReady(6) = 1;
    contents = cellstr(get(handles.latMenu,'String'));
    latDir = contents{get(handles.latMenu,'Value')};
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function latMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to latMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function longMagText_Callback(hObject, eventdata, handles)
% hObject    handle to longMagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of longMagText as text
%        str2double(get(hObject,'String')) returns contents of longMagText as a double
global longMag;
global initReady;
longMag = str2double(get(handles.longMagText,'String'));
if longMag < 0 || longMag > 90
    longMag = [];
    initReady(7) = 0;
else
    initReady(7) = 1;
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function longMagText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to longMagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in longMenu.
function longMenu_Callback(hObject, eventdata, handles)
% hObject    handle to longMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns longMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from longMenu
global longDir;
global initReady;
if get(handles.longMenu,'Value') == 1;
    initReady(8) = 0;
else
    initReady(8) = 1;
    contents = cellstr(get(handles.longMenu,'String'));
    longDir = contents{get(handles.longMenu,'Value')};
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function longMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to longMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in statNameMenu.
function statNameMenu_Callback(hObject, eventdata, handles)
% hObject    handle to statNameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns statNameMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from statNameMenu
global statName;
global initReady;
if get(handles.statNameMenu,'Value') == 1
    initReady(2) = 0;
else
    initReady(2) = 1;
    contents = cellstr(get(handles.statNameMenu,'String'));
    statName = contents{get(handles.statNameMenu,'Value')};
end
switch statName
    case 'Other'
        statName = inputdlg('Enter station name:','Input');
        statName = statName{1};
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function statNameMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statNameMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sampRateMenu.
function sampRateMenu_Callback(hObject, eventdata, handles)
% hObject    handle to sampRateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sampRateMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sampRateMenu
global sampRate;
global initReady;
if get(handles.sampRateMenu,'Value') == 1
    initReady(1) = 0;
else
    initReady(1) = 1;
    contents = cellstr(get(handles.sampRateMenu,'String'));
    sampRate = contents{get(handles.sampRateMenu,'Value')};
    switch sampRate
        case 'Other'
            sampRate = inputdlg('Enter sampling rate:','Input');
            sampRate = str2num(sampRate{1});
        otherwise
            switch sampRate(end);
                case 'k'
                    sampRate = str2num(sampRate(1:(end-1)))*1e3;
                case 'M'
                    sampRate = str2num(sampRate(1:(end-1)))*1e6;
            end
    end
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function sampRateMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampRateMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sensorMenu.
function sensorMenu_Callback(hObject, eventdata, handles)
% hObject    handle to sensorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sensorMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sensorMenu
global sensRef;
global initReady;
if get(handles.sensorMenu,'Value') == 1
    initReady(3) = 0;
else
    initReady(3) = 1;
    contents = cellstr(get(handles.sensorMenu,'String'));
    sensRef = contents{get(handles.sensorMenu,'Value')};
    switch sensRef
    case 'Other'
        sensRef = inputdlg('Enter sensor reference:','Input');
        sensRef = sensRef{1};
    end
end
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function sensorMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensorMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
% hObject    handle to startButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global initReady;
global aChannels;
global psd_info;
global latMag;
global latDir;
global longMag;
global longDir;
global pn;
global statName;
global sampRate;
global sensRef;
global keepRunning;
global IRIGtime;
global suffix;
global fig1Chan;
global fig2Chan;
global ylow;
global yhigh;
global IRIGtype;
global saveTime;
global saveMemory;
global saveType;
global newSave;

psd_info.aChannels = aChannels;
psd_info.latMag = latMag;
psd_info.latDir = latDir;
psd_info.longMag = longMag;
psd_info.longDir = longDir;
psd_info.pn = pn;
psd_info.statName = statName;
psd_info.sampRate = sampRate;
psd_info.sensRef = sensRef;
psd_info.IRIGtime = IRIGtime;
psd_info.suffix = suffix;
psd_info.fig1Chan = fig1Chan;
psd_info.fig2Chan = fig2Chan;
psd_info.ylow = ylow;
psd_info.yhigh = yhigh;
psd_info.IRIGtype = IRIGtype;
psd_info.saveMemory = saveMemory;
psd_info.saveTime = saveTime;
psd_info.saveType = saveType;
keepRunning = 1;
psd_info.axes1 = handles.axes1;
psd_info.axes2 = handles.axes2;
psd_info.clock = handles.dataInLabel;
psd_info.uptime = handles.uptimeLabel;

set(handles.startButton,'Enable','off');
if(newSave)
    set(handles.statusLabel,'String','Saving new configurations');
    cd('Subroutines');
    write_config(handles,psd_info);
    cd('..');
end
set(handles.statusLabel,'String','Starting session... please wait.');
pause(.25);

set(handles.statusLabel,'String','Sampling...');
runEnDis(handles,0);
cd('Subroutines');
samp_and_saveMHz(psd_info);
fprintf('Session stopped\n');






% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global keepRunning
keepRunning = 0;
set(handles.statusLabel,'String','Stopping Session');
runEnDis(handles,1);


% --- Executes on button press in ai0Box.
function ai0Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai0Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai0Box


% --- Executes on button press in ai1Box.
function ai1Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai1Box
global aChannels;
if get(handles.ai1Box,'Value')
    aChannels(2) = 1;
else
    aChannels(2) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai2Box.
function ai2Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai2Box
global aChannels;
if get(handles.ai2Box,'Value')
    aChannels(3) = 1;
else
    aChannels(3) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai3Box.
function ai3Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai3Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai3Box
global aChannels;
if get(handles.ai3Box,'Value')
    aChannels(4) = 1;
else
    aChannels(4) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai4Box.
function ai4Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai4Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai4Box
global aChannels;
if get(handles.ai4Box,'Value')
    aChannels(5) = 1;
else
    aChannels(5) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai5Box.
function ai5Box_Callback(hObject, eventdata, handles);
% hObject    handle to ai5Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai5Box
global aChannels;
if get(handles.ai5Box,'Value')
    aChannels(6) = 1;
else
    aChannels(6) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai6Box.
function ai6Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai6Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai6Box
global aChannels;
if get(handles.ai6Box,'Value')
    aChannels(7) = 1;
else
    aChannels(7) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% --- Executes on button press in ai7Box.
function ai7Box_Callback(hObject, eventdata, handles)
% hObject    handle to ai7Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ai7Box
global aChannels;
if get(handles.ai7Box,'Value')
    aChannels(8) = 1;
else
    aChannels(8) = 0;
end
plotBox_Callback(hObject, eventdata, handles);
checkReady(handles);


% Check initial parameters met
% [(1)sampRate (2)statName (3)sensorRef (4)saveFolder (5)latMag (6)latDir
% (7)longMag (8)longDir (9)IRIGtime (10)saveType (11)saveAmount (12)livePlot
% (13)IRIGtype]
function checkReady(handles)
global initReady;
global aChannels;
global newSave;
if newSave == 0
    newSave = 1;
    set(handles.dataInLabel,'String','Changes detected, config.txt will be updated on start');
end
if initReady(1) && initReady(9) && initReady(10)
    set(handles.memQuantText,'Enable','on');
else
    set(handles.memQuantText,'Enable','off');
    set(handles.memQuantText,'String','Check IRIG and/or Sampling rate');
end
if all(initReady)
    set(handles.startButton,'Enable','on');
    if sum(aChannels) == 1
        set(handles.statusLabel,'String','Only IRIG channel connected, check analog channel selections or continue');
    else
        set(handles.statusLabel,'String','Ready to sample');
    end
else
    set(handles.startButton,'Enable','off');
    if ~initReady(1)
        set(handles.statusLabel,'String','Please select a valid sampling rate');
    elseif ~initReady(9)
        set(handles.statusLabel,'String','Please select a vaild amount of time to save IRIG');
    elseif ~initReady(13)
        set(handles.statusLabel,'String','Please select a valid IRIG type');
    elseif ~initReady(5)
        set(handles.statusLabel,'String','Please input a valid latitude (0-90)');
    elseif ~initReady(6)
        set(handles.statusLabel,'String','Please select a valid latitude direction');
    elseif ~initReady(7)
        set(handles.statusLabel,'String','Please input a valid longitude (0-180)');
    elseif ~initReady(8)
        set(handles.statusLabel,'String','Please select a valid longitude direction');
    elseif ~initReady(3)
        set(handles.statusLabel,'String','Please select a valid sensor reference');
    elseif ~initReady(2)
        set(handles.statusLabel,'String','Please select a valid station name');
    elseif ~initReady(4)
        set(handles.statusLabel,'String','Please select a valid folder to save in');
    elseif ~initReady(10)
        set(handles.statusLabel,'String','Please select a valid save type');
    elseif ~initReady(11)
        set(handles.statusLabel,'String','Please select a valid amount to save');
    elseif ~initReady(12)
        checkPlot(handles);
    end
end


% --- Executes on button press in browseButton.
function browseButton_Callback(hObject, eventdata, handles)
% hObject    handle to browseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pn;
global initReady;
if(isempty(pn))
    folder_name = uigetdir();
else
    folder_name = uigetdir(pn);
end
pn = folder_name;
if ~isempty(pn)
    initReady(4) = 1;
else
    initReady(4) = 0;
end
checkReady(handles);


% --- Executes on selection change in IRIGtimeMenu.
function IRIGtimeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to IRIGtimeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IRIGtimeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IRIGtimeMenu
global IRIGtime;
global initReady;
IRIGtime = get(handles.IRIGtimeMenu,'Value');
if IRIGtime == 1
    initReady(9) = 0;
elseif IRIGtime == 6
    initReady(9) = 1;
    IRIGtime = inputdlg('Enter IRIG amount to save:','Input');
    IRIGtime = str2num(IRIGtime{1});
else
    initReady(9) = 1;
    IRIGtime = IRIGtime - 1;
end
checkReady(handles);

% --- Executes during object creation, after setting all properties.
function IRIGtimeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IRIGtimeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function footerText_Callback(hObject, eventdata, handles)
% hObject    handle to footerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of footerText as text
%        str2double(get(hObject,'String')) returns contents of footerText as a double
global suffix;
suffix = get(handles.footerText,'String');
if isempty(suffix) || ~all(isletter(suffix))
    set(handles.statusLabel,'String','Invalid suffix, filenames will not include suffix');
    suffix = '';
else
    set(handles.statusLabel,'String',['Filenames of results will end with: ' suffix]);
end


% --- Executes during object creation, after setting all properties.
function footerText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to footerText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotBox.
function plotBox_Callback(hObject, eventdata, handles)
% hObject    handle to plotBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotBox
global initReady;
global plotLive;
global showPlot;
global aChannels;
plotLive = get(handles.plotBox,'Value');
showPlot = plotLive;
if plotLive
    initReady(12) = 0;
    set(handles.fig1Menu,'Enable','on');
    set(handles.fig2Menu,'Enable','on');
    set(handles.ylowText,'Enable','on');
    set(handles.yhighText,'Enable','on');
    activeChans = find(aChannels==1);
    tempString = [];
    for k = activeChans
        if k == 1
            tempString = ['         ';'IRIG     '];
        else
            chanString = ['Ch' num2str(k-1) ' (ai' num2str(k-1) ')'];
            tempString = [tempString;chanString];
        end
    end
    set(handles.fig1Menu,'String',tempString);
    set(handles.fig2Menu,'String',tempString);
else
    initReady(12) = 1;
    set(handles.fig1Menu,'Enable','off');
    set(handles.fig2Menu,'Enable','off');
    set(handles.ylowText,'Enable','off');
    set(handles.yhighText,'Enable','off');
    set(handles.updateFigMenu,'Enable','off');
    set(handles.updateButton,'Enable','off');
    set(handles.fig1Menu,'Value',1);
    set(handles.fig2Menu,'Value',1);
end
checkReady(handles);


% --- Executes on selection change in fig1Menu.
function fig1Menu_Callback(hObject, eventdata, handles)
% hObject    handle to fig1Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fig1Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fig1Menu
global plotReady;
global fig1Chan;
contents = cellstr(get(handles.fig1Menu,'String'));
fig1Chan = contents{get(handles.fig1Menu,'Value')};
if ~isempty(fig1Chan)
    switch fig1Chan(1)
        case 'I'
            plotReady(1) = 1;
            fig1Chan = 0;
        otherwise
            plotReady(1) = 1;
            fig1Chan = str2num(fig1Chan(3));
    end
else
    plotReady(1) = 0;
end
checkPlot(handles);


% --- Executes during object creation, after setting all properties.
function fig1Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig1Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fig2Menu.
function fig2Menu_Callback(hObject, eventdata, handles)
% hObject    handle to fig2Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fig2Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fig2Menu
global plotReady;
global fig2Chan;
contents = cellstr(get(handles.fig2Menu,'String'));
fig2Chan = contents{get(handles.fig2Menu,'Value')};
if ~isempty(fig2Chan)
    switch fig2Chan(3)
        case 'I'
            plotReady(2) = 1;
            fig2Chan = 0;
        otherwise
            plotReady(2) = 1;
            fig2Chan = str2num(fig2Chan(3));
    end
else
    plotReady(2) = 0;
end
checkPlot(handles)


% --- Executes during object creation, after setting all properties.
function fig2Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fig2Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ylowText_Callback(hObject, eventdata, handles)
% hObject    handle to ylowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ylowText as text
%        str2double(get(hObject,'String')) returns contents of ylowText as a double
global plotReady;
global ylow;
global keepRunning;
ylow = str2double(get(handles.ylowText,'String'));
if ylow > 0
    plotReady(3) = 0;
else
    plotReady(3) = 1;
end
checkPlot(handles)



% --- Executes during object creation, after setting all properties.
function ylowText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ylowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yhighText_Callback(hObject, eventdata, handles)
% hObject    handle to yhighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yhighText as text
%        str2double(get(hObject,'String')) returns contents of yhighText as a double
global plotReady;
global yhigh;
yhigh = str2double(get(handles.yhighText,'String'));
if yhigh < 0
    plotReady(4) = 0;
else
    plotReady(4) = 1;
end
checkPlot(handles);


% --- Executes during object creation, after setting all properties.
function yhighText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yhighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% [(1)fig1 (2)fig2 (3)lowYLim (4)highYLim]
function checkPlot(handles)
global plotReady;
global initReady;
global keepRunning;
if ~plotReady(1)
    set(handles.statusLabel,'String','Please input a valid figure number for figure 1');
elseif ~plotReady(2)
    set(handles.statusLabel,'String','Please input a valid figure number for figure 2');
elseif ~plotReady(3)
    set(handles.statusLabel,'String','Please input a valid lower Y limit (<0)');
elseif ~plotReady(4)
    set(handles.statusLabel,'String','Please input a valid upper Y limit (>0)');
elseif ~keepRunning
    initReady(12) = 1;
    checkReady(handles);
end


% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global keepRunning;
global fig_one;
global fig_two;
global ylow;
global yhigh;
if ~keepRunning
    set(handles.statusLabel,'String','Figure is not in use');
else
    switch get(handles.updateFigMenu,'Value')
        case 1
            fig_one.YLim = [ylow yhigh];
        otherwise
            fig_two.YLim = [ylow yhigh];
    end
end


% --- Executes on selection change in updateFigMenu.
function updateFigMenu_Callback(hObject, eventdata, handles)
% hObject    handle to updateFigMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns updateFigMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from updateFigMenu


% --- Executes during object creation, after setting all properties.
function updateFigMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to updateFigMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileSizeTypeMenu.
function fileSizeTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileSizeTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileSizeTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileSizeTypeMenu
global initReady;
global saveType;
saveType = get(handles.fileSizeTypeMenu,'Value');
if saveType ~= 1
    initReady(10) = 1;
    set(handles.memQuantText,'Enable','on');
else
    initReady(10) = 0;
    set(handles.memQuantText,'Enable','on');
end
initReady(11) = 0;
set(handles.memQuantText,'String','');
checkReady(handles);


% --- Executes during object creation, after setting all properties.
function fileSizeTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileSizeTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IRIGtypeMenu.
function IRIGtypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to IRIGtypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IRIGtypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IRIGtypeMenu
global initReady;
global IRIGtype;
if get(handles.IRIGtypeMenu,'Value') == 1
    initReady(13) = 0;
else
    initReady(13) = 1;
    contents = cellstr(get(handles.IRIGtypeMenu,'String'));
    IRIGtype = contents{get(handles.IRIGtypeMenu,'Value')};
end
checkReady(handles);




% --- Executes during object creation, after setting all properties.
function IRIGtypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IRIGtypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function memQuantText_Callback(hObject, eventdata, handles)
% hObject    handle to memQuantText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of memQuantText as text
%        str2double(get(hObject,'String')) returns contents of memQuantText as a double
global saveTime;
global saveMemory;
global saveType;
global initReady;
global sampRate;
global IRIGtime;
tempQuant = str2double(get(handles.memQuantText,'String'));
if isempty(tempQuant) || isnan(tempQuant)
    initReady(11) = 0;
else
    if saveType == 2
        scaledQuant = tempQuant*1e6;
        if scaledQuant < 2*IRIGtime*sampRate
            initReady(11) = 0;
        else
            saveMemory = scaledQuant;
            saveTime = 1;
            initReady(11) = 1;
        end
    elseif saveType == 3
        scaledQuant = tempQuant*1e9;
        if scaledQuant < 2*sampR*IRIGtime
            initReady(11) = 0;
        else
            saveMemory = scaledQuant;
            saveTime = 1;
            initReady(11) = 1;
        end
    elseif saveType == 4
        if tempQuant < IRIGtime
            initReady(11) = 0;
        else
            saveTime = tempQuant;
            saveMemory = 1;
            initReady(11) = 1;
        end
    elseif saveType == 5
        scaledQuant = tempQuant * 60;
        if scaledQuant < IRIGtime
            initReady(11) = 0;
        else
            saveTime = scaledQuant;
            saveMemory = 1;
            initReady(11) = 1;
        end
    else
        scaledQuant = tempQuant * 3600;
        if scaledQuant < IRIGtime
            initReady(11) = 0;
        else
            saveTime = scaledQuant;
            saveMemory = 1;
            initReady(11) = 1;
        end
    end
end
checkReady(handles);



% --- Executes during object creation, after setting all properties.
function memQuantText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to memQuantText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function getConfig(hObject, eventdata, handles)
global initReady;
global sensRef;
global statName;
global pn;
global newSave;
cd('Subroutines');
cfid = fopen('config.txt','r');
cd('..');
dne = [];
try
    fread(cfid,'uint16');
    frewind(cfid);
    dne = 1;
catch
    warning('config.txt does not exist! Please manually fill in parameters.');
    dne = 0;
end
if dne
    set(handles.sampRateMenu,'Value',fread(cfid,1,'uint8'));
    sampRateMenu_Callback(hObject, eventdata, handles);
    set(handles.IRIGtimeMenu,'Value',fread(cfid,1,'uint8'));
    IRIGtimeMenu_Callback(hObject, eventdata, handles);
    temp = fread(cfid,1,'uint8');
    set(handles.latMagText,'String',char(fread(cfid,temp,'char'))');
    latMagText_Callback(hObject, eventdata, handles);
    temp = fread(cfid,1,'uint8');
    set(handles.longMagText,'String',char(fread(cfid,temp,'*char'))');
    longMagText_Callback(hObject, eventdata, handles);
    set(handles.latMenu,'Value',fread(cfid,1,'uint8'));
    latMenu_Callback(hObject, eventdata, handles);
    set(handles.longMenu,'Value',fread(cfid,1,'uint8'));
    longMenu_Callback(hObject, eventdata, handles);
    set(handles.IRIGtypeMenu,'Value',fread(cfid,1,'uint8'));
    IRIGtypeMenu_Callback(hObject, eventdata, handles);
    set(handles.sensorMenu,'Value',fread(cfid,1,'uint8'));
    temp = fread(cfid,1,'uint8');
    sensRef = char(fread(cfid,temp,'char'))';
    initReady(3) = 1;
    set(handles.statNameMenu,'Value',fread(cfid,1,'uint8'));
    temp = fread(cfid,1,'uint8');
    statName = char(fread(cfid,temp,'char'))';
    initReady(2) = 1;
    temp = fread(cfid,1,'uint8');
    set(handles.footerText,'String',char(fread(cfid,temp,'char'))');
    footerText_Callback(hObject, eventdata, handles);
    set(handles.fileSizeTypeMenu,'Value',fread(cfid,1,'uint8'));
    fileSizeTypeMenu_Callback(hObject, eventdata, handles);
    temp = fread(cfid,1,'uint8');
    pn = char(fread(cfid,temp,'char'))';
    initReady(4) = 1;
    temp = fread(cfid,1,'uint8');
    set(handles.memQuantText,'String',char(fread(cfid,temp,'char'))');
    memQuantText_Callback(hObject, eventdata, handles);
    set(handles.ai1Box,'Value',fread(cfid,1,'uint8'));
    ai1Box_Callback(hObject, eventdata, handles);
    set(handles.ai2Box,'Value',fread(cfid,1,'uint8'));
    ai2Box_Callback(hObject, eventdata, handles);
    set(handles.ai3Box,'Value',fread(cfid,1,'uint8'));
    ai3Box_Callback(hObject, eventdata, handles);
    set(handles.ai4Box,'Value',fread(cfid,1,'uint8'));
    ai4Box_Callback(hObject, eventdata, handles);
    set(handles.ai5Box,'Value',fread(cfid,1,'uint8'));
    ai5Box_Callback(hObject, eventdata, handles);
    set(handles.ai6Box,'Value',fread(cfid,1,'uint8'));
    ai6Box_Callback(hObject, eventdata, handles);
    set(handles.ai7Box,'Value',fread(cfid,1,'uint8'));
    ai7Box_Callback(hObject, eventdata, handles);
    set(handles.plotBox,'Value',fread(cfid,1,'uint8'));
    plotBox_Callback(hObject, eventdata, handles);
    set(handles.fig1Menu,'Value',fread(cfid,1,'uint8'));
    fig1Menu_Callback(hObject, eventdata, handles);
    set(handles.fig2Menu,'Value',fread(cfid,1,'uint8'));
    fig2Menu_Callback(hObject, eventdata, handles);
    temp = fread(cfid,1,'uint8');
    set(handles.ylowText,'String',char(fread(cfid,temp,'char'))');
    ylowText_Callback(hObject, eventdata, handles);
    temp = fread(cfid,1,'uint8');
    set(handles.yhighText,'String',char(fread(cfid,temp,'char'))');
    yhighText_Callback(hObject, eventdata, handles);
    fclose(cfid);
    newSave = 0;
else
    newSave = 1;
end

function runEnDis(handles, onoff)
global plotLive;
if onoff == 0
    status = 'off';
    notstatus = 'on';
else
    status = 'on';
    notstatus = 'off';
end
set(handles.sampRateMenu,'Enable',status);
set(handles.latMagText,'Enable',status);
set(handles.latMenu,'Enable',status);
set(handles.longMagText,'Enable',status);
set(handles.longMenu,'Enable',status);
set(handles.IRIGtypeMenu,'Enable',status);
set(handles.IRIGtimeMenu,'Enable',status);
set(handles.sensorMenu,'Enable',status);
set(handles.statNameMenu,'Enable',status);
set(handles.footerText,'Enable',status);
set(handles.browseButton,'Enable',status);
set(handles.fileSizeTypeMenu,'Enable',status);
set(handles.memQuantText,'Enable',status);
set(handles.ai1Box,'Enable',status);
set(handles.ai2Box,'Enable',status);
set(handles.ai3Box,'Enable',status);
set(handles.ai4Box,'Enable',status);
set(handles.ai5Box,'Enable',status);
set(handles.ai6Box,'Enable',status);
set(handles.ai7Box,'Enable',status);
set(handles.plotBox,'Enable',status);
if plotLive
    set(handles.fig1Menu,'Enable',status);
    set(handles.fig2Menu,'Enable',status);
else
    set(handles.ylowText,'Enable',notstatus);
    set(handles.yhighText,'Enable',notstatus);
end
set(handles.updateFigMenu,'Enable',notstatus);
set(handles.updateButton,'Enable',notstatus);
set(handles.showHideButton,'Enable',notstatus);
set(handles.startButton,'Enable',status);
set(handles.stopButton,'Enable',notstatus);


% --- Executes on button press in showHideButton.
function showHideButton_Callback(hObject, eventdata, handles)
% hObject    handle to showHideButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global showPlot
showPlot = -(showPlot - 1);
