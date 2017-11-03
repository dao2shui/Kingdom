function cr = imratio(f1,f2)
%IMRATIO Computes the ratio of the bytes in two image/variables.
% cr = imratio(f1,f2) returns the ratio of the number of bytes in
% variables/files f1 and f2 . If f1 and f2 are an original and compressed
% image,respectively,cr is the copression ratio.
narginchk(2,2);            %Check input arguments
cr = bytes(f1)/bytes(f2);  %Compute the ratio.

% ---------------------------------------------------------------------%
function b = bytes(f)
% Return the number of bytes in input f . If f is a string ,assume that it
% is an image filename; if not ,it is an image variable.

if ischar(f)
    info = dir(f);  b = info.bytes;
elseif isstruct(f)
    %MATLAB'S who function reports an extra 124 bytes of memory per
    %structure field because of the way MATLAB stores structures in memory
    %associated with each field.
    b = 0;
    fields = fieldnames(f);
    for k = 1:length(fields)
        elements = f.(fields{k});
        for m = 1:length(elements)
            b = b + bytes(elements(m));
        end
    end
else
info = whos('f');  b = info.bytes;
end