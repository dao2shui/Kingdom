function mean = localmean(f,nhood)
%LOCALMEAN Computes an array of local means.
% MEAN = LOCALMEAN(F,NHOOD) computes the mean at the center of every
% neighborhood of F defined by NHOOD ,a dn array of zeros and ones where te
% nonzero elements specify the neighbors used in the computation of the
% local means.The size of NHOOD must be odd in each dimension ;the defualt
% is ones(3).Output MEAN is an array the same size as F containing the
% local mean at each point.

if nargin == 1
    nhood = ones(3) / 9;
else
    nhood = nhood / sum(nhood(:));
end
mean = imfilter(tofloat(f),nhood,'replicate');
