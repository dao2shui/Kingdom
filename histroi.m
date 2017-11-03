function [p,npix]=histroi(f,c,r)
% HISTROI computes the histogram of an ROI in an image.
% [p,npix] = histroi(f,c,r) computes the histogram,p,of a polygonal region 
% of interest (ROI) in image f.The polygonal region is defined by the 
% column and row coordinates of its vertices,which are specified
% (sequentially) in vectors C and R,respectively.All pixels of f must be
% >=0.Parameter npix is the number of pixels in the polygonal region.

% Generate the binary mask image.
B =roipoly(f,c,r);

% Compute the histogram of the pixels in the ROI.
p=imhist(f(B));

% Obtian the number of pixels in the ROI if requested in the output.
if nargout >1
    npix = sum(B(:));
end
