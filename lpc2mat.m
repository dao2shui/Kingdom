function x = lpc2mat(y,f)
%LPC2MAT Decompresses a 1-D lossless predictive encoded matrix.
% x = lpc2mat(y,f) decodes input matrix y based on linear prediction
% coefficients in f and the assumption of 1-D lossless predictive coding.
% If f is omitted ,filter f = 1 (for previous pixel coding ) is assumed.
% 
% See also mat2lpc.
narginchk(1,2);     %Check input arguments
if nargin < 2       %Set default filter if omitted
    f = 1;
end

f = f(end:-1:1);    %Reverse the filter coefficients
[m,n] = size(y);    %Get dimension of output matrix
order = length(f);  %Get order of linear predictor 
f = repmat(f,m,1)   %Duplicate filter for vectorizing
x = zeros(m,n + order); %Pad for 1st 'order' column decodes

% Decode the output one column at a time .Compute a prediction based on the
% 'order' previous elements and add it to the prediction error .The result
% is appended to the output matrix being built.
for j = 1:n
    jj = j + order;
    x(:,jj) = y(:,j) + round(sum(f(:,order:-1:1).*x(:,(jj -1):-1:(jj - order)),2));
end
x = x(:,order +1 :end);  %Remove left padding 