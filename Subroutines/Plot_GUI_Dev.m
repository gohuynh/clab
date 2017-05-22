function varargout = Plot_GUI_Dev(varargin)
% PLOT_GUI_DEV MATLAB code for Plot_GUI_Dev.fig
%      PLOT_GUI_DEV, by itself, creates a new PLOT_GUI_DEV or raises the existing
%      singleton*.
%
%      H = PLOT_GUI_DEV returns the handle to a new PLOT_GUI_DEV or the handle to
%      the existing singleton*.
%
%      PLOT_GUI_DEV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_GUI_DEV.M with the given input arguments.
%
%      PLOT_GUI_DEV('Property','Value',...) creates a new PLOT_GUI_DEV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Plot_GUI_Dev_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Plot_GUI_Dev_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Plot_GUI_Dev

% Last Modified by GUIDE v2.5 08-Sep-2016 21:34:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Plot_GUI_Dev_OpeningFcn, ...
                   'gui_OutputFcn',  @Plot_GUI_Dev_OutputFcn, ...
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


% --- Executes just before Plot_GUI_Dev is made visible.
function Plot_GUI_Dev_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Plot_GUI_Dev (see VARARGIN)

% Choose default command line output for Plot_GUI_Dev
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Plot_GUI_Dev wait for user response (see UIRESUME)
% uiwait(handles.PlotGUI);

% move GUI in the middle of the screen
movegui('center');


% --- Outputs from this function are returned to the command line.
function varargout = Plot_GUI_Dev_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
