function varargout = ice_OutputFcn(hObject, eventdata, handles) 
% After ICE is closed , get the image data of the current figure for the
% output.If 'handles' exists, ICE isn't closed (there was no 'uiwait') so
% output figure handle.
if max(size(handles)) == 0
    figh = get(gcf);
    imageh = get(figh.Children);
    if max(size(imageh)) > 0
        image = get(imageh.Children);
        varargout{1} = image.CData;
    end
else
    % Get default command line output from handles structure
%     varargout{1} = handles.output;
    varargout{1} = hObject;
end

