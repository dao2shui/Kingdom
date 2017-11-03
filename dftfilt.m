function g=dftfilt(f,H,classout)
%DFTFILT perform frequency domain filtering.
%g=dftfilt(f,H,classout) filters f in the frequency domain using the filter 
%transfer function H.The output ,g,is the filtered image,which has the same
%size as f.
% 
% valid values of calssout are
% 
% 'original' The output is of the same class as the input .This is the
%            default if classout is not included in the call.
% 'fltpoint' The output is floating point of class single,unless both f and
%            H are of class double ,in which cass the output also is of 
%            class double.
% 
% DFTFILT automatically pads of f to be the same size as H.Both f and H
% must be real.In addition ,H must be an uncenteres,circularly-symmetric
% filter function.

% Convert the input to floating point.
[f,revertClass]=tofloat(f);

% Obtain the fft of the padded input.
F = fft2(f,size(H,1),size(H,2));

% Perform filtering.
g = ifft2(H.*F);

%Crop to original size.
g=g(1:size(f,1),1:size(f,2)); % g is of class single here.

% Convert the output to the same class as the intput if so specified.
if nargin ==2 ||strcmp(classout,'original')
   g=revertClass(g);
else if strcmp(classout,'fltpoint')
        return
    else
        error('Undefinded class for the output image.')
    end
end
