function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 05-Oct-2018 19:36:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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
end

% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Add image to the axes
axes(handles.originalImage)
myImage = imread('lenna.gif');
image(myImage)
axis off
axis image


% Choose default command line output for untitled
handles.output = hObject;

handles.mask = [0.25, 0.5, 0.25; 0.5, 1, 0.5; 0.25, 0.5, 0.25];
handles.zoomScale = 1;
handles.original = myImage;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


function pad = zoomPadding(handles)
% here we pad the image
originalIm = handles.original;
paddedIm = {};
rowLength = size(originalIm,1) * 2;
columnLength = size(originalIm,2) * 2;

ii = 2
paddedIm = originalIm(ii, :);
for i = 2:rowLength
    if mod(i, 2) == 0
%         we want to append zeros
        paddedIm = [paddedIm; zeros(1, size(originalIm, 2))];
    else
%         we want to append the iith row of the original image
        paddedIm = [paddedIm; originalIm(ii, :)];
        ii = ii+1;
    end
end

buff = {};
ii = 2;
buff = paddedIm(:, ii);
for i = 2:columnLength
    if mod(i, 2) == 0
%         we want to append zeros
        buff = [buff, zeros(rowLength, 1)];
    else
%         we want to append the iith row of the original image
        buff = [buff, paddedIm(:, ii)];
        ii = ii+1;
    end
end
buff = [zeros(1, columnLength); buff];
buff = [zeros(rowLength+1, 1), buff];
pad = buff
end


function final = performConvolution(handles)
    buffer = zoomPadding(handles);
    pad = buffer;
%   now we perform convolution
%     buffer = handles.paddedImage;
    
%     sliding window down
    for i = 1:size(pad, 1) - 3
    %     sliding window across
        for j = 1:size(pad, 2) - 3
            inner = dot(reshape(single(pad(i:i+2, j:j+2)), 1, []), reshape(single(handles.mask), 1, []));
            buffer(i+1, j+1) = uint8(floor(inner));
        end
    end
    final = buffer(2: size(buffer, 1) - 2, 2:size(buffer, 2)-2);
end
    

% --- Executes on button press in convolute.
function convolute_Callback(hObject, eventdata, handles)
% hObject    handle to convolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% perform convolution here
final = performConvolution(handles)
res = size(final);


% AxesH = axes(handles.finalImage);
% imshow('lenna.gif');
% axis off
% axis image
AxesH = axes('Units', 'pixels', 'position', [400, 100, res(2), res(1)], 'Visible', 'off');
image(final, 'Parent', AxesH);
axis off
axis image

end





function scaleInput_Callback(hObject, eventdata, handles)
% hObject    handle to scaleInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleInput as text
%        str2double(get(hObject,'String')) returns contents of scaleInput as a double
input = str2double(get(hObject,'String'));
if isnan(input)
  errordlg('You must enter a numeric value','Invalid Input','modal')
  uicontrol(hObject)
  return
else
  display(input);
end
handles.zoomScale = input;
end
