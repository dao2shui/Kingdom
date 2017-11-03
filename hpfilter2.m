function H=hpfilter2(type,M,N,D0,n)
%HPFILTER2 computes frequency domain highpass filters.

% The tansfer function Hhp of a highpass filter is 1-Hlp,where Hlp is the
% transfer function of the corresponding lowpass filter .Thus, we can use
% function lpfilter to generate highpass filters.

if nargin ==4
    n=1; %default value of n.
end

%Generate highpass filter.
Hlp =lpfilter(type,M,N,D0,n);
H = 1-Hlp;
