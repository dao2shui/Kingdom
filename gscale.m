function g=gscale(f,varargin)
%GSCALE Scales the intensity of the input image.
%g=gscale(f,'full8') scales the intensities of f to the full 8-bit
%intensity range [0,255].This is the default if there is only one input
%argument.

%g=gscale(f,'full16') scales the intensities of f to the full 16-bit 
%intensity range [0,65535].
%g=gscale(f,'minmax',low,high) scales the intensities of f to the range
%[low,high].these values must be provided,and they must be in the range
%[0,1],independently of the class of the input.gscale performs any
%necessary scalling.If the input is of class double,and its values are not
%in the range [0,1],then gscale scales it to this range before processing.

if length(varargin)==0  %If only one argument it must be f.
    method='full8';
else
    method =varargin{1};
end

%perform the specified scaling.
switch method 
    case 'full8'
        g=im2uint8(mat2gray(double(f)));
    case 'full16'
        g=im2uint16(mat2gray(double(f)));
    case 'minmax'
        low =varargin{2};high =varargin{3};
        if low >1 || low <0 || high >1 || high <0
            error('Parameters low and high must be in the range [0,1].')
        end
        if strcmp(class(f),'double')
            low_in =min(f(:));
            high_in =max(f(:));
        else if strcmp(class(f),'uint8')
                low_in =double(min(f(:)))./255;
                high_in =double(max(f(:)))./255;
            else if strcmp(class(f),'uint16')
                    low_in =double(min(f(:)))./65535;
                    high_in =doule(max(f(:)))./65535;
                end
            end
        end
        %imadjust automatically matches the classs of the input.
        g=imadjust(f,[low_in,high_in],[low,high]);
    otherwise
        error('Unknown method.')
end