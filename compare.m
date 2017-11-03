function rmse = compare(f1,f2,scale)
%COMPARE Computes and displays the error between two matrices.
% rmse = compare(f1,f2,scale) returns the root-mean-square error between
% input f1 and f2 ,displays a histogram of the difference , and displays a
% scaled difference image .when scale is omitted ,a scale factor of 1 is
% used.

% Check input arguments and set defaults.
narginchk(2,3);
if nargin < 3
    scale = 1;
end

% Compute the root-mean-square error.
e = double(f1) - double(f2);
[m,n] = size(e);
rmse = sqrt(sum(e(:).^2)/(m*n));

% Output error image & histogram if an error (i.e.,rmse ~= 0).
if rmse
    %From error histogram.
    emax = max(abs(e(:)));
    [h,x] = hist(e(:),emax);
    if length(h) >= 1
        figure;bar(x,h,'k');
        
        %Scale the error image symmetrically and display
        emax = emax/scale;
        e = mat2gray(e,[-emax,emax]);
        figure;imshow(e);
    end
end
