function D = mahalanobis(varargin)
%MAHALANOBIS Computes the Mahalanobis distance.
% D = mahalanobis(y,x) computes the Mahalanobis distance between each
% vector in y to the mean (centroid) of the vectors in x,and outputs the
% result in vector D, whose length is size(y,1).The vectors in x and y are
% assumed to be organized as rows. The input data can be real or
% complex.The outputs are real quantities.
% 
% D = mahalanobis(y,cx,mx) computes the Mahalanobis distance between each
% vector in y and the given mean vector , mx. The results are output in
% vector D,whose length is size(y,1).The vectors in y are assumed to be
% organized as the rows of this array. The input data cna be real or
% complex .The outputs are real quantities.In addition to the mean vector
% mx,the covariance matrix cx of a population of vectors X must be provided
% also. Use function CIVMATRIX (Section 11.5) to compute mx and cx.

% Reference :Acklam,P.J.[2002]."MATLAB Array Manipulation Tips and Tricks,"
% available at
%   home.online.no/~pjacklam/matlab/doc/mtt/index.html
% or in the Tutorials section at
%   www.imageprocessingplace.com

param = varargin; %Keep in mind that param is a cell array.
Y = param{1};

if length(param) == 2
    X = param{2};
%   Compute the mean vector and covariance matrix of the vectors in X.
    [Cx,mx] = covmatrix(X);
elseif length(param) == 3 %Cov. matrix and mean vector provided.
    Cx = param{2};
    mx = param{3};
else 
    error('Wrong number of inputs.');
end
mx = mx(:)';%Make sure that mx is a row vector for the next step.

% Subtract the mean vector form each vector in Y.
Yc = bsxfun(@minus,Y,mx);

% Compute the Mahalanobis distances.
D = real(sum(Yc/Cx.*conj(Yc),2));
