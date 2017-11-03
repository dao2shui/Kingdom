function R = imnoise2(type,varargin)
%IMNOISE2 Generates an array of random number with specified PDF.
%R=imnoise2(type,M,N,A,B) generates an array,R,of size M-by-N,whose
%elements are random numbers of the specified type with parameters A and
%B.If only type is included in the input argument list , a single random
%number of the specified .If only type and default parameters shown below
%is generated .If only type ,M,and N are provided, the defult parameters
%shown below are used.If M=N=1,imnoise2 generates a single random number of
%the specified type and parameters A and B.

% Valid values for type and parameters A and B are:

% 'uniform'       Uniform random numbers in the interval (A,B).The default
%                 values are (0,1).
% 'gaussian'      Gaussian random numbers with mean A and standard 
%                 deviation B.The default values are A=0,B=1.
% 'salt & pepper' Salt and pepper numbers of amplitude 0 with probability
%                 Pa =A , and amplitude 1 with probability Pb = B.The 
%                 default values are Pa=Pb =A =B =0.05. Note that the noise 
%                 has values 0 (with probability Pa=A) and 1 (with 
%                 probability Pb = B), so scaling is necessary if values 
%                 other than 0 and 1 are required .The noise matrix R is 
%                 assigned three values.If R(x,y) =0,the noise at (x,y) is 
%                 pepper (black).If R(x,y) = 1,the noise at (x,y) is salt 
%                (white). If R(x,y) = 0.5,there is no noise assigned  to 
%                coordinates (x,y).
% 'lognormal'    Lognormal numbers with offset A and shape parameter B.The
%                defaults are A = 1 and B= 0.25.
% 'rayleigh'     Rayleigh noise with parameter A and B .The default values
%                are A =0 and B=1.
% 'exponential'  Exponential random numbers with parameter A .The default
%                is A=1.
% 'erlang'       Erlang (gamma) random numbers with parameter A and B .B
%                must be a positive integer .The defaults are A=2 and
%                B=5.Erlang random numbers are approximated as the sum of B
%                exponential random numbers.
% Set default.
[M,N,a,b]=setDefaults2(type,varargin{:});

% Begin processing . Use lower (type) to protect against input being
% capitalized.
switch lower(type)
    case 'uniform'
        R = a+(b-a)*rand(M,N);
    case 'gaussian'
        R =a+b*randn(M,N);
    case 'salt & pepper'
        R =saltpepper(M,N,a,b);
    case 'lognormal'
        R =exp(b*randn(M,N)+a);
    case 'rayleigh'
        R = a+(-b*log(1-rand(M,N))).^0.5;
    case 'exponential'
        R =exponential2(M,N,a);
    case 'erlang'
        R =erlang(M,N,a,b);
    otherwise
        error('Unknown distribution type.')
end
%-----------------------------------------------------------------------%
function R = saltpepper(M,N,a,b)
%Check to make sure that Pa +Pb is not >1.
if (a+b)>1
    error('The sum Pa +Pb must not exceed 1')
end
R(1:M,1:N) =0.5;
%Generate an M-by-N array of uniformly-distributed random numbers in the
%range(0,1).Then,Pa*(M*N) of them will have values <=a.The coordinates od
%these points we call 0 (pepper noise).Similarly,Pb*(M*N) points will have
%values in the range > a & <=(a+b).These we call 1(salt noise).
X=rand(M,N);
R(X<=a) =0;
u=a+b;
R(X>a & X<u) = 1;
%-----------------------------------------------------------------------%
function R =exponential2(M,N,a)
if a <= 0
    error('Parameter a must be positive for exponential type.')
end

K=-1/a;
R = K*log(1-rand(M,N));
%-----------------------------------------------------------------------%
function  R = erlang(M,N,a,b)
if (b~=round(b) || b<=0)
    error('Parameter a must be positive integer for Erlang')
end
k = -1/a;
R = zeros(M,N);
for j = 1:b
    R =R + k*log(1-rand(M,N));
end
% ---------------------------------------------------------------------%
function varargout = setDefaults2(type,varargin)
varargout = varargin;
P = numel(varargin);
if P<4
    %set default b.
    varargout{4} =1;
end
if P<3
    %Set default a.
    varargout{3} =0;
end
if P <2
    %Set default N.
    varargout{2}=1;
end
if P <1
    %Set default M.
    varargout{1}=1;
end
if (P<=2)
    switch type 
        case 'salt & pepper'
            %a=b=0.05
            varargout{3}=0.05;
            varargout{4}=0.05;
        case 'lognormal'
            %a=1,b=0.25.
            varargout{3}=1;
            varargout{4}=0.25;
        case 'exponential'
            %a=1.
            varargout{3}=1;
        case 'erlang'
            %a=2;b=5.
            varargout{3}=2;
            varargout{4}=5;
    end
end
