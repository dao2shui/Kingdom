function varargout = ice(varargin)
% ICE Interactive color Editor.
% 
% OUT = ice('Property Name','Property Value',...) transforms an image's
% color components based on interactively specified mapping functions.Input
% are property Name /Property Value pairs:
% 
%  Name                 Value
% --------------        --------------------------------------------------
% 'image'               An RGB or monochrome input image to be transformed
%                       by interactively specified mapping.
% 'space'               The color space of the components to be
%                       modified.Possible values are
%                       'rgb','cmy','hsi','hsv','ntsc'(or
%                       'yiq'),'ycbcr'.When omitted ,the RGB color space is
%                       assumed.
% 'wait'                If 'on' (the default),OUT is the mapped input image
%                       and ICE returns to the calling function or
%                       workspace when closed.If 'off' ,OUT is the handle
%                       od the mapped input image and ICE returns
%                       immediately.
% 
% EXAMPLES:
%   ice or ice('wait','off')  %Demo user interface.
%   ice('image',f)            %Map RGB or mono image .
%   ice('image',f,'space','hsv') %Map HSV of RGB image.
%   g=ice('image',f)             %Return mapped iamge.
%   g=ice('image',f,'wait', 'off') %Return its handle.

% ICE displays one popup menu selectable mapping function at a time .Each
% image component is mapped by a dedicated curve (e.g.,R,G,or B) and then
% by an all-component curve (e.g.,RGB).Each curve's control points are
% depicted as circles that can be moved ,added ,or deleted with a two- or
% three-button mouse:
%   Mouse Button      Editing Operation
%   ---------------   --------------------------------------------------
%   left              Move control point by pressing and dragging.
%   Middle            Add and position a control point by pressing and 
%                     dragging.(Optionally shift_left) 
%   Right             Delete a control point .(Optionally control-left)
% 
% Checkboxes determine how mapping functions are computed,whether the input
% image and reference pseudo- and full-color bars are mapped,and the
% displayed reference curve information(e.g.,PDF).
%  Checkbox        Function
% -------------    ------------------------------------------------------
%  Smooth          Checked for cubic spline (smooth curve) interpolation.
%                  If unchecked ,piecewise linear.
%  Clamp Ends      Checked to force the starting and ending curve slopes in
%                  cubic spline interpolation to 0.No effect on piecewise
%                  linear.
%  Show PDF        Display probability density function(s)
%                  [i.e.,histogram(s)] of the image components affected by
%                  the mapping function.
%  Show CDF        Display cumulative distributions function(s) instead of
%                  PDFs.
%  Map Image       If checked ,image mapping is enabled ;else not.
%  Map Bars        If checked,pseudo- and full-color bar mapping is enabled
%                  ;else display the unmapped bars (a gray wedge and hue
%                  wedge,respectively).
% 
% Mapping function can be initialized via pushbuttons:
%  Button        Funcion
%  -----------   --------------------------------------------------------
%  Rest          Init the currently dispalyed mapping function and uncheck
%                all curve parameters.
%  Rest All      Initialized all mapping functions.



% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ice_OpeningFcn, ...
                   'gui_OutputFcn',  @ice_OutputFcn, ...
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
%-----------------------------------------------------------------------%
% --- Executes just before ice is made visible.

function ice_OpeningFcn(hObject, eventdata, handles, varargin)
% When ICE is opened ,perform basic initialization (e.g.,setup globals,...)
% before it is made visible.

% Set ICE globals to defaults.
handles.updown = 'none'; %Mouse updown state
handles.plotbox = [0 0 1 1];  %Plot area parameters in pixels
handles.set1 = [0 0;1 1]; %Curve 1 control points
handles.set2 = [0 0;1 1]; %Curve 2 control points
handles.set3 = [0 0;1 1]; %Curve 3 control points
handles.set4 = [0 0;1 1]; %Curve 4 control points
handles.curve = 'set1';   %Structure name of selected curve
handles.cindex = 1;       %Index of selected curve
handles.node = 0;         %Index of selected control point
handles.below = 1;        %Index of node below control point 
handles.above = 2;        %Index of node above control ponit 
handles.smooth = [0;0;0;0]; %Curve smoothing states 
handles.slope = [0;0;0;0];  %Curve end slope control states
handles.cdf = [0;0;0;0];    %Curve CDF states
handles.pdf = [0;0;0;0];    %Curve PDF states
handles.output = [];        %Output image handle
handles.df = [];            %Input PDFs and CDFs
handles.colortype = 'rgb';  %Input image color space
handles.input = [];         %Input image date.
handles.imagemap = 1;       %Image map enable
handles.barmap = 1;         %Bar map enable
handles.graybar = [];       %pseudo (gray) bar image 
handles.colorbar = [];      %color (hue) bar image

% Peocess Property Name /Property Value input argument pairs.
wait = 'on';
if (nargin > 3)
    for i = 1:2:(nargin - 3)
        if nargin - 3 ==i
            break;
        end
        switch lower(varargin{i})
            case 'image'
                if ndims(varargin{i+1}) == 3
                    handles.input = varargin{i+1};
                else if ndims(varargin{i+1}) == 2
                        handles.input = cat(3,varargin{i+1},varargin{i+1},varargin{i+1});
                    end
                end
                handles.input = double(handles.input);
                inputmax = max(handles.input(:));
                if inputmax >255
                    handles.input = handles.input/65535;
                else if inputmax >1
                        handles.input = handles.input/255;
                    end
                end
            case 'space'
                hanles.colortype = lower(varargin{i+1});
                switch handles.colortype
                    case 'cmy'
                        list = {'CMY' 'Cyan' 'Magenta' 'Yellow'};
                    case {'ntsc','yiq'}
                        list = {'YIQ' 'Luminance' 'Hue' 'Saturation'};
                        handles.colortype = 'ntsc';
                    case 'ycbcr'
                        list = {'YCbCr' 'Luminance' 'Blue' 'Difference' 'Red Difference'};
                    case 'hsv'
                        list = {'HSV' 'Hue' 'Saturation' 'Value'};
                    case 'hsi'
                        list = {'HSI' 'Hue' 'Saturation' 'Intensity'};
                    otherwise
                        list = {'RGB' 'Red' 'Green' 'Blue'};
                        handles.colortype = 'rgb';
                end
                set(handles.component_popup,'String',list);
            case 'wait'
                wait = lower(varargin{i+1});
        end
    end
end

% Create pseudo- and full-color mapping bar (grays and hues).Store a color
% space converted 1*128*3 line of each bar for mapping.
xi = 0:1/127:1; x = 0:1/6:1; x = x';
y= [1 1 0 0 0 1 1;0 1 1 1 0 0 0;0 0 0 1 1 1 0]';
gb = repmat(xi,[1 1 3]); cb = interp1q(x,y,xi');
cb = reshape(cb,[1 128 3]);
if ~strcmp(handles.colortype,'rgb');
    gb = eval(['rgb2' handles.colortype '(gb)']);
    cb = eval(['rgb2' handles.colortype '(cb)']);
end
gb = round(255*gb); gb = max(0,gb); gb = min(255,gb);
cb = round(255*cb); cb = max(0,cb); cb = min(255,cb);
handles.graybar = gb; handles.colorbar = cb;

% Do color space transforms ,clamp to [0,255], compute histograms and
% cumulative distribution functions,and create output figure.
if size(handles.input,1)
    if ~strcmp(handles.colortype,'rgb')
        handles.input = eval(['rgb2' handles.colortype '(handles.input)']);
    end
    handles.input = round(255*handles.input);
    handles.input = max(0,handles.input);
    handles.input = min(255,handles.input);
    for i=1:3
        color = handles.input(:,:,i);
        df = hist(color(:),0:255);
        handles.df = [handles.df;df/max(df(:))];
        df = df/sum(df(:)); df = cumsum(df);
        handles.df = [handles.df;df];
    end
    figure; handles.output = gcf;
end

% Compute ICE's screen position and display image /graph.
set(0,'Units','pixels');  ssz = get(0,'Screensize');
set(handles.ice,'Units','pixels');
uisz = get(handles.ice,'Position');
if size(handles.input,1)
    fsz = get(handles.output,'Position');
    bc = (fsz(4)-uisz(4))/3;
    if bc>0
        bc = bc + fsz(2);
    else 
        bc = fsz(2) + fsz(4) - uisz(4) - 10;
    end
    lc = fsz(1) + (size(handles.input,2)/4) +(3*fsz(3)/4);
    lc = min(lc,ssz(3) - uisz(3) - 10);
    set(handles.ice,'Position',[lc bc 463 391]);
else
    bc = round((ssz(4) - uisz(4))/2)-10;
    lc = round((ssz(3) - uisz(3))/2)-10;
    set(handles.ice,'Position',[lc bc uisz(3) uisz(4)]);
end
set(handles.ice,'Units','normalized');
graph(handles);     render(handles);

% Update handles and make ICE wait befort exit if required.

    
% Choose default command line output for ice
% handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
if strcmp(wait,'on');
    uiwait(handles.ice);
end
% ======================================================================%

% UIWAIT makes ice wait for user response (see UIRESUME)
% uiwait(handles.ice);

% --- Outputs from this function are returned to the command line.
%-----------------------------------------------------------------------%
function graph(handles)
% Interpolate and plot mapping function and optional reference PDFs or CDFs
nodes1 = getfield(handles,handles.curve);
c=handles.cindex; dfx = 0:1/255:1;
colors = ['k' 'r' 'g' 'b'];
% For piecewise linear interpolation ,plot a map ,map + PDF/CDF,or map +3
% PDFs/CDFs.
if ~handles.smooth(handles.cindex)
    if (~handles.pdf(c) && ~handles.cdf(c)) ||(size(handles.df,2) == 0)
        plot(nodes1(:,1),nodes1(:,2),'b-',nodes1(:,1),nodes1(:,2),'ko',...
            'Parent',handles.curve_axes);
    elseif c>1
        i = 2*c - 2 - handles.pdf(c);
        plot(dfx,handles.df(i,:),[colors(c) '-'],nodes1(:,1),nodes1(:,2),'k-',...
            nodes1(:,1),nodes1(:,2),'ko','Parent',handles.curve_axes);
    elseif c==1
        i=handles.cdf(c);
        plot(dfx,handles.df(i+1,:),'r-',dfx,handles.df(i+3,:),'g-',...
             dfx,handles.df(i+5,:),'b-',nodes1(:,1),nodes1(:,2),'k-',...
             nodes1(:,1),nodes1(:,2),'ko','Parent',handles.curve_axes);
    end
    
% Do the same for smooth (cubic spline) interpolations.
else
    x=0:0.01:1;
    if ~handles.slope(handles.cindex)
        y=spline(nodes1(:,1),nodes1(:,2),x);
    else
        y=spline(nodes1(:,1),[0;nodes1(:,2);0],x);
    end
    i= find(y>1); y(i) = 1;
    i=find(y<0);  y(i) = 0;
    if (~handles.pdf(c) && ~handles.cdf(c)) || (size(handles.df,2)==0)
        plot(nodes1(:,1),nodes1(:,2),'ko',x,y,'b-','Parent',handles.curve_axes);
    elseif c>1
        i=2*c - 2- handles.pdf(c);
        plot(dfx,handles.df(i,:),[colors(c) '-'],nodes1(:,1),nodes1(:,2),'ko',...
            x,y,'k-','Parent',handles.curve_axes);
    elseif c==1
        i=handles.cdf(c);
        plot(dfx,handles.df(i+1,:),'r-',dfx,handles.df(i+3,:),'g-',...
             dfx,handles.df(i+5,:),'b-',nodes1(:,1),nodes1(:,2),'ko',...
             x,y,'k-','Parent',handles.curve_axes);
    end
end

% Put legend if more than two curves are shown.
s = handles.colortype;
if strcmp(s,'ntsc')
    s='yip';
end
if (c==1) && (handles.pdf(c) || handles.cdf(c))
    s1 = ['-- ' upper(s(1))];
    if length(s) == 3
        s2 = ['-- ' upper(s(2))];s3 = ['-- ' upper(s(3))];
    else
        s2 = ['-- ' upper(s(2)) s(3)];s3 = ['-- ' upper(s(4)) s(5)];
    end
else
    s1 = '';s2 = ''; s3='';
end
set(handles.red_text,'String',s1);
set(handles.green_text,'String',s2);
set(handles.blue_text,'String',s3);
%-----------------------------------------------------------------------%
function [inplot,x,y] = cursor1(h,handles)
% Translate the mouse position to a coordinate with respect to the current
% plot area,check for the mouse in the area and if so save the location and
% write the coordinates below the plot.
set(h,'Units','pixels');
p = get(h,'CurrentPoint');
x = (p(1,1) - handles.plotbox(1))/handles.plotbox(3);
y = (p(1,2) - handles.plotbox(2))/handles.plotbox(4);
if x > 1.05 || x < -0.05 || y > 1.05 || y < -0.05
    inplot = 0 ;
else
    x = min(x,1); x = max(x,0);
    y = min(y,1); y = max(y,0);
    nodes1 = getfield(handles,handles.curve);
    x = round(256*x)/256;
    inplot = 1;
    set(handles.input_text,'String',num2str(x,3));
    set(handles.output_text,'String',num2str(y,3));
end
set(h,'Units','normalized');

%-----------------------------------------------------------------------%
function y = render(handles)
% Map the input image and bar components and convert them to RGB (if
% needed)and display.
set(handles.ice,'Interruptible','off');
set(handles.ice,'Pointer','watch');
ygb = handles.graybar; ycb = handles.colorbar;
yi = handles.input;  mapon = handles.barmap;
imageon = handles.imagemap & size(handles.input,1);

for i = 2:4
    nodes1 = getfield(handles,['set' num2str(i)]);
    t = lut(nodes1,handles.smooth(i),handles.slope(i));
    if imageon
        yi(:,:,i-1) = t(yi(:,:,i-1)+1);
    end
    if mapon 
        ygb(:,:,i-1) = t(ygb(:,:,i-1)+1);
        ycb(:,:,i-1) = t(ycb(:,:,i-1)+1);
    end
end
t = lut(handles.set1,handles.smooth(1),handles.slope(1));
if imageon 
    yi = t(yi+1);
end
if mapon 
    ygb = t(ygb + 1); ycb = t(ycb +1);
end
if ~strcmp(handles.colortype,'rgb')
    if size(handles.input,1)
        yi = yi/255;
        yi = eval([handles.colortype '2rgb(yi)']);
        yi = uint8(255*yi);
    end
    ygb = ygb/255;  ycb = ycb/255;
    ygb = eval([handles.colortype '2rgb(ygb)']);
    ycb = eval([handles.colortype '2rgb(ycb)']);
    ygb = uint8(255*ygb); ycb =uint8(255*ycb);
else
    yi = uing8(yi); ygb = uint8(ygb); ycb = uint8(ycb);
end

if size(handles.input,1)
    figure(handles.output); imshow(yi);
end

ygb = repmat(ygb,[32 1 1]);   ycb = repmat(ycb,[32 1 1]);
axes(handles.gray_axes);   imshow(ygb);
axes(handles.color_axes);  imshow(ycb);
figure(handles.ice);
set(handles.ice,'Pointer','arrow');
set(handles.ice,'Interruptible','on');
% ----------------------------------------------------------------------%
function t = lut(nodes1,smooth,slope)
% Create a 256 element mapping function from a set of control points.The
% output values are integers in the interval [0,255].Use piecewise linear
% or cubic spline with or without zero end slope interpolation.
t = 255*nodes1; i = 0:255;
if ~smooth
    t = [t;256 256]; t = interp1q(t(:,1),t(:,2),i');
else 
    if ~slope
        t = spline(t(:,1),t(:,2),i);
    else
        t = spline(t(:,1),[0;t(:,2);0],i);
    end
end
t=round(t);  t=max(0,t); t=min(255,t);
% ----------------------------------------------------------------------%
function out = spreadout(in)
% Make all x values unique.

% Scan forward for non-unique x's and bump the higher indexed x-- but don't
% exceed 1.Scan the entire range.
nudge = 1/256;
for i = 2:size(in,1)-1
    if in(i,1) <= in(i-1,1)
        in(i,1) = min(in(i-1,1)+ nudge,1);
    end
end
% Scan in reverse for non-unique x's and decrease the lower indexed x-- but
% don't go below 0.Stop on the first non-unique pair.
if in(end,1) == in(end-1,1)
    for i=size(in,1):-1:2
        if in(i,1) <= in(i-1,1)
            in(i-1,1) = max(in(i,1) - nudge,0);
        else
            break;
        end
    end
end

% If the first two x's are now the same ,init the curve.
if in(1,1) == in(2,1)
    in = [0 0 ;1 1];
end
out = in;
% ----------------------------------------------------------------------%
function g=rgb2cmy(f)
% Covert RGB to CMY using IPT's imcomplement.
g=imcomplement(f);
% ----------------------------------------------------------------------%
function g=cmy2rgb(f)
% Convert CMY to RGB using IPT's imcomplement.
g = imcomplement(f);
% ----------------------------------------------------------------------%

%-----------------------------------------------------------------------%
% --- Executes on selection change in component_popup.
function smooth_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to component_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept smoothing parameter for currently selected color component and
% redraw mapping function.
if get(hObject,'Value')
    handles.smooth(handles.cindex) = 1;
    nodes1 = getfield(handles,handles.curve);
    nodes1 = spreadout(nodes1);
    handles = setfield(handles,handles.curve,nodes1);
else
    hanles.smooth(handles.cindex) =0;
end
guidata(hObject,handles);
set(handles.ice,'Pointer','watch');
graph(handles);  render(handles);
set(handles.ice,'Pointer','arrow');

% Hints: contents = cellstr(get(hObject,'String')) returns component_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from component_popup
% ---------------------------------------------------------------------%



% --- Executes on button press in mapbar_checkbox.
function reset_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to mapbar_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Init all display parameter for currently selected color component ,make
% map 1:1,and redraw it.

handles = setfield(handles,handles.curve,[0 0;1 1]);
c = handles.cindex;
handles.smooth(c) = 0; set(handles.smooth_checkbox,'Value',0);
handles.slope(c) = 0;  set(handles.slope_checkbox,'Value',0);
handles.pdf(c) = 0;    set(handles.pdf_checkbox,'Value',0);
handles.cdf(c) = 0;    set(handles.cdf_checkbox,'Value',0);
guidata(hObject,handles);
set(handles.ice,'Pointer','watch');
graph(handles);   render(handles);
set(handles.ice,'Pointer','arrow');
% Hint: get(hObject,'Value') returns toggle state of mapbar_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in mapimage_checkbox.
function slope_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to mapimage_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept slope clamp for currently selected color component and draw
% function if smoothing is on.
if get(hObject,'Value');
    handles.slope(handles.cindex) = 1;
else
    handles.slope(handles.cindex) = 0;
end
guidata(hObject,handles);
if handles.smooth(handles.cindex)
    set(handles.ice,'Pointer','watch');
    graph(handles);   render(handles);
    set(handles.ice,'Pointer','arrow');
end
% Hint: get(hObject,'Value') returns toggle state of mapimage_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in resetall_pushbutton.
function resetall_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetall_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Init display parameters for color components,make all maps 1:1,and redraw
% display.
for c = 1:4
    handles.smooth(c) = 0;     handles.slope(c) = 0;
    handles.pdf(c) = 0;        handles.cdf(c) = 0;
    handles = setfield(handles,['set' num2str(c)],[0 0;1 1]);
end
set(handles.smooth_checkbox,'Value',0);
set(handles.slope_checkbox,'Value',0);
set(handles.pdf_checkbox,'Value',0);
set(handles.cdf_checkbox,'Value',0);
guidata(hObject,handles);
set(handles.ice,'Pointer','watch');
graph(handles);  render(handles);
set(handles.ice,'Pointer','arrow');
% ---------------------------------------------------------------------%


% --- Executes on button press in smooth_checkbox.
function pdf_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to smooth_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept PDF (probability density function or histogram) display parameter
% for currently selected color component and redraw mapping function if
% smoothing is on .If set ,clear CDF display.
if get(hObject,'Value')
    handles.pdf(handles.cindex) = 1;
    set(handles.cdf_checkbox,'Value',0);
    handles.cdf(handles.cindex) = 0;
else
    handles.pdf(handles.cindex) = 0;
end
guidata(hObject,handles);  graph(handles);
% Hint: get(hObject,'Value') returns toggle state of smooth_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in slope_checkbox.
function cdf_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to slope_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept CDF (cumulative distribution function) display parameter for
% selected color component and redraw mapping function if smoothing is on
% .If set,clear CDF display.

if get(hObject,'Value')
    handles.cdf(handles.cindex) = 1;
    set(handles.pdf_checkbox,'Value',0);
    handles.pdf(handles.cindex) = 0;
else
    handles.cdf(handles.cindex) = 0;
end
guidata(hObject,handles);  graph(handles);
% Hint: get(hObject,'Value') returns toggle state of slope_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in pdf_checkbox.
function mapbar_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to pdf_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept change to bar map enable state and redraw image.

handles.barmap = get(hObject,'Value');
guidata(hObject,handles);  render(handles);
% Hint: get(hObject,'Value') returns toggle state of pdf_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in cdf_checkbox.
function mapimage_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to cdf_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept change to the iamge map state and redraw image.

handles.imagemap = get(hObject,'Value');
guidata(hObject,handles);  render(handles);

% Hint: get(hObject,'Value') returns toggle state of cdf_checkbox
% ---------------------------------------------------------------------%


% --- Executes on button press in reset_pushbutton.
function component_popup_Callback(hObject, eventdata, handles)
% hObject    handle to reset_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Accept color component selection ,update component specific parameters on
% GUI,and draw the selected mapping function.

c = get(hObject,'Value');
handles.cindex = c;
handles.curve = strcat('set',num2str(c));
guidata(hObject,handles);
set(handles.smooth_checkbox,'Value',handles.smooth(c));
set(handles.slope_checkbox,'Value',handles.slope(c));
set(handles.pdf_checkbox,'Value',handles.pdf(c));
set(handles.cdf_checkbox,'Value',handles.cdf(c));
graph(handles);
% ---------------------------------------------------------------------%


% --- Executes during object creation, after setting all properties.
function component_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to component_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% ---------------------------------------------------------------------%


% ---------------------------------------------------------------------%
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function ice_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Start mapping function control point editing .Do move ,add,or delete for
% left ,middle ,and right button mouse clicks ('normal',extend',and 'alt'
% cases) over plot zrea.

set(handles.curve_axes,'Units','pixels');
handles.plotbox = get(handles.curve_axes,'Position');
set(handles.curve_axes,'Units','normalized');
[inplot,x,y] = cursor1(hObject,handles);
if inplot
    nodes1 = getfield(handles,handles.curve);
    i = find(x>=nodes1(:,1)); below = max(i);
    above = min(below + 1,size(nodes1,1));
    if (x - nodes1(below,1)) > (nodes1(above,1) - x)
        node = above;
    else
        node = below;
    end
    deletednode = 0;
    
    switch get(hObject,'SelectionType')
        case 'normal'
            if node == above
                above = min(above +1,size(nodes1,1));
            elseif node == below
                below = max(below - 1,1);
            end
            if node == size(nodes1,1)
                below = above;
            elseif node ==1
                above = below;
            end
            if x > nodes1(above,1)
                x = nodes1(above,1);
            elseif x < nodes1(below,1)
                x=nodes1(below,1);
            end
            handles.node = node;  handles.updown = 'down';
            handles.below = below; handles.above = above;
            nodes1(node,:) = [x y];
        case 'extend'
            if ~any(nodes1(:,1) == x)
                nodes1 = [nodes1(1:below,:);[x y];nodes1(above:end,:)];
                handles.node =above;   handles.updown = 'down';
                handles.below = below; handles.above = above +1;
            end
        case 'alt'
            if (node ~= 1) && (node ~= size(nodes1,1))
                nodes1(node,:) = [];  deletednode = 1;
            end
            handles.node = 0;
            set(handles.input_text,'String','');
            set(handles.output_text,'String','');
    end
    
    handles = setfield(handles,handles.curve,nodes1);
    guidata(hObject,handles);
    graph(handles);
    if deletednode
        render(handles);
    end
end
% ---------------------------------------------------------------------%


% --- Executes on mouse motion over figure - except title and menu.
function ice_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to ice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Do nothing unless a mouse 'down' event has occurred.If it has,modify
% control point and make new mapping function.

if ~strcmpi(handles.updown,'down')
    return;
end
[inplot,x,y] = cursor1(hObject,handles);
if inplot
    nodes1 = getfield(handles,handles.curve);
    nudge = handles.smooth(handles.cindex)/256;
    if (handles.node ~=1) && (handles.node ~= size(nodes1,1))
        if x>=nodes1(handles.above,1)
            x = nodes1(hanles.above,1)-nudge;
        elseif x<=nodes1(handles.below,1)
            x=nodes1(handles.below,1) +nudge;
        end
    else
        if x>nodes1(handles.above,1)
            x = nodes1(handles.above,1);
        elseif x<nodes1(handles.below,1)
            x = nodes1(handles.below,1);
        end
    end
    nodes1(hanles.node,:) = [x y];
    hanles = setfield(handles,hanles.curve,nodes1);
    guidata(hObject,handles);
    graph(handles);
end
% ---------------------------------------------------------------------%


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function ice_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to ice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Terminate ongoing control point move or add operation .Clear coordinate
% text below plot and update display.

update = strcmpi(handles.updown,'down');
handles.updown = 'up';  handles.node =0;
guidata(hObject,handles);
if update
    set(handles.input_text,'String','');
    set(handles.output_text,'String','');
    render(handles);
end
