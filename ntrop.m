function h = ntrop(x,n)
%NTROP Computess a first-order estimate of the entropy of a matrix.
% H = ntrop(x,n) returns the entropy of matrix x with n symbols.N = 256 if
% omitted but it must be larger than the number of unique values in x for
% accurate results .The estimate assumes a statistically independent source
% characterized by the relative frequency of occurence of the elements in x
%. The estimate is a lower bound on the average number of bits per unique
%value (or symbol) when coding without coding redundancy.
narginchk(1,2); %Check input argumens .
if nargin < 2
    n = 256;   %Default for n.
end

x = double(x);  %Make input double.
xh = hist(x(:),n); % Compute N-bin histogram
xh = xh / sum(xh(:)); %Compute probabilities

% Make mask to eliminate 0,s since log2(0) = -inf.
i = find(xh);
h = -sum(xh(i).*log2(xh(i))); %Compute entropy.
