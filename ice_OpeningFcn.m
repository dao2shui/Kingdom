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

