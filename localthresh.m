function g = localthresh(f, nhood, a , b, meantype)
%LOCALTHRESH Local thresholding.
% g = localthresh(f,nhood, a, b , meantype) thresholds image f by computing
% a local threshold at the center ,(x,y),of every neighborhood in f .The
% size of the neighborhoods is defined by nhood ,an array of zeros and ones
% in which the nonzero elements specify the neighbors used in the
% computation of the local mean and standard deviation.The size of nhood
% must be odd in both dimensions.
% 
%  The segmented image is given by 
%                       1 if (f > a*sig) and (f > b*mean)
%                   g = 
%                       0 otherwise 
% 
% where sig is an array of the same size as f containing the local standard
% deviations.If meantype = 'local' (the default),then mean is an array of
% local means .If meantype = 'global' ,then mean is the global (iamge) mean
% ,a scalar .Constants a and b are nonnegative scalars.

% Intialize.
f = tofloat(f);

% Compute the local standard deviations.
sig = stdfilt(f,nhood);
% Compute mean.
if nargin == 5 && strcmp(meantype,'global')
    mean = mean2(f);
else 
    mean = localmean(f,nhood); % This is a custom function .
end

% Obtain the segmented iamge .
g = (f > a*sig) & (f > b*mean);
