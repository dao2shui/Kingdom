function I = colorseg(varargin)
%COLORSEG Performs segmentation of a color image.
% S = colorseg('Euclidean',F,T,M) performs segmenttation of color image f
% using a Euclidean measure of similarity. M is a 1-by-3 vector
% representing the average color used for segmentation (this is the center
% of the sphere in Fig. 6.26 of DIPUM). T is the threshold against which
% the distances are compared.
% 
% S = colorseg('Mahalanobis',F,T,M,C) performs segmentation of color image
% F using the Mahalanobis distancce as a measure of similarity. C is the
% 3-by-3 covariance matrix of the sample color vector of the class of
% interest. see function covmatrix for the computation of C and M.
% 
% S is the segmented image (a binary matrix) in which 0s denote the
% background.

% Preliminaries.
% Recall that varargin is a cell array.
f = varargin{2};
if (ndims(f) ~=3) || (size(f,3) ~= 3)
    error('Input image must be RGB.');
end
M = size(f,1);N = size(f,2);
% Convert f to vector format using function imstack2vectors.
f = imstack2vectors(f);
f = double(f);
% Initialize I as a colimn vector . It will be reshaped later into an
% iamge.
I = zeros(M*N,1);
T = varargin{3};
m = varargin{4};
m = m(:)'; %Make sure that m is a row vector .

if length(varargin) == 4
    method = 'euclidean';
elseif length(varargin) == 5
    method = 'mahalanobis';
else
    error('Wrong number of inputs.');
end

switch method
    case 'euclidean'
        %Compute the Euclidean distance between all rows of X and m. See
        %section 12.2 of DIPUM for an explanation of the following
        %expression. D(i) is the Euclidean distance between vector X(i,:)
        %and vector m.
        p = length(f);
        D = sqrt(sum(abs(f - repmat(m,p,1)).^2,2));
    case 'mahalanobis'
        C = varargin{5};
        D = mahalanobis(f,C,m);
    otherwise 
        error('Unknown segmentation method.')
end

% D is a vector of size MN-by-1 containing the distance computations from
% all the color pixels to vector m. Find the distance <= T.
J = find(D <= T);

% Set the values of I(J) to 1.These are the segmented color pixels.
I(J) = 1;

% Reshape I into an M-by-N image .
I = reshape(I,M,N);
