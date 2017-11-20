function y = mat2lpc(x,f)
%MAT2LPC Computes a matrix using 1-D losses predictive coding.
% y = mat2lpc(x,f) encodes matrix x using 1-D lossless predicticve coding
% .A linear prediction of x is made based on the coefficients in f . If f
% is omitted ,F = 1 (for previous pixel coding ) is assumed . The
% prediction error is then computed and output as encode matrix y.
% 
% See also lpc2mat.
narginchk(1,2); %Check input arguments
if nargin < 2   %set default filter if omitted
    f = 1;
end

x = double(x);   %Ensure double for computetions
[m,n] = size(x); %Get dimentions of input matrix
p = zeros(m,n);  %Init linear prediction to 0
xs = x; zc = zeros(m,1)  %Prepare for input shift and pad

for j = 1:length(f)
    xs = [zc xs(:,1:end-1)];  %shift and zero pad x 
    p = p + f(j)*xs;          %form partial prediction sums
end
y = x - round(p);      %Compute prediction error
