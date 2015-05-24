function varargout = bumblebee_sequence(varargin)
% BUMBLEBEE_SEQUENCE M-file for bumblebee_sequence.fig
%      BUMBLEBEE_SEQUENCE, by itself, creates a new BUMBLEBEE_SEQUENCE or raises the existing
%      singleton*.
%
%      H = BUMBLEBEE_SEQUENCE returns the handle to a new BUMBLEBEE_SEQUENCE or the handle to
%      the existing singleton*.
%
%      BUMBLEBEE_SEQUENCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BUMBLEBEE_SEQUENCE.M with the given input arguments.
%
%      BUMBLEBEE_SEQUENCE('Property','Value',...) creates a new BUMBLEBEE_SEQUENCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bumblebee_sequence_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bumblebee_sequence_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bumblebee_sequence

% Last Modified by GUIDE v2.5 03-Jul-2013 13:54:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bumblebee_sequence_OpeningFcn, ...
                   'gui_OutputFcn',  @bumblebee_sequence_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && length(varargin) > 1 % TIM added last statement
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before bumblebee_sequence is made visible.
function bumblebee_sequence_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bumblebee_sequence (see VARARGIN)

% Choose default command line output for bumblebee_sequence
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bumblebee_sequence wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% TIM **************
bumblebee_imread_sequence(1, varargin{:});
[left,~,~,N] = bumblebee_imread_sequence(1);
set(handles.text1, 'String', '1')
set(handles.slider2, 'Min', 1);
set(handles.slider2, 'Max', N);
set(handles.slider2, 'Value', 1);
imshow(left)

% --- Outputs from this function are returned to the command line.
function varargout = bumblebee_sequence_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% TIM **************
val = ceil(get(hObject, 'Value'));
N = get(hObject, 'Max');
disp_images_loop(handles, val, false, N)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
persistent STATE
if isempty(STATE), STATE=false; end
STATE = ~STATE;
i = ceil(get(handles.slider2, 'Value'));
N = get(handles.slider2, 'Max');
disp_images_loop(handles, i, STATE, N)
STATE = false;

% --------------------------------------------------------
function disp_images_loop(handles, val, loop, N)
persistent LOOP
LOOP = loop;
for i = val:N
    set(handles.text1, 'String', num2str(i))
    set(handles.slider2, 'Value', i);
    left = bumblebee_imread_sequence(i);
    imshow(left)
    drawnow
    if ~LOOP, break, end
end
