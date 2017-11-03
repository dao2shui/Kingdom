function f= spfilt(g,type,varargin)
%SPFILT performs linear and nonlinear spatial filtering.
% f = spfilt(g,type,M,N,parameter) performs spatial filtering of image g
% using a type filter of size M-by-N. Valid calls to spfilt are as follows:

% f=spfilt(g,'amean',M,N)      Arithmetic(算数) mean filtering.
% f=spfilt(g,'gmean',M,N)      Geometric(几何) mean filtering.
% f=spfilt(g,'hmean',M,N)      Harmonic(调和) mean filtering.
% f=spfilt(g,'chmean',M,N,Q)   Contraharmonic mean filtering of order Q.The
%                              default Q is 1.5.(反调和）
% f=spfilt(g,'median',M,N)     Median filtering.
% f=spfilt(g,'max',M,N)        Max filtering.
% f=spfilt(g,'min',M,N)        Min filtering.
% f=spfilt(g,'midpoint',M,N)   Midpoint filtering.
% f=spfilt(g,'atrimmed',M,N,D) Alpha-trimmed mean filtering.Parameter D
%                              must be a nonnegative even integer;its 
%                              default value is 2.(阿尔法均值滤波) 

% The dafault values when only g and type are input are M=N=3,Q=1.5,and
% D=2..

[m,n,Q,d]=processInputs(varargin{:});
%Do the filtering.
switch type
    case 'amean'
        w=fspecial('averrage',[m n]);
        f=imfilter(g,w,'replicate');
    case 'gmean'
        f=gmean2(g,m,n);
    case 'hmean'
        f=harmean(g,m,n);
    case 'chmean'
        f=charmean(g,m,n,Q);
    case 'median'
        f=medfilt2(g,[m,n],'symmetric');
    case 'max'
        f=imdilate(g,ones(m,n));
    case 'min'
        f=imerode(g,ones(m,n));
    case 'midpoint'
        f1=ordfilt2(g,1,ones(m,n),'symmetric');
        f2=ordfilt2(g,m*n,ones(m,n),'symmetric');
        f=imlincomb(0.5,f1,0.5,f2);
    case 'atrimmed'
        f=alphatrim(g,m,n,d);
    otherwise
        error('Unknown filter type.')
end
end
%----------------------------------------------------------------------%
function f=gmean2(g,m,n)
% Implements a geometric mean filterr.
[g,revertClass]=tofloat(g);
f=exp(imfilter(log(g),ones(m,n),'replicate')).^(1/m/n);
f=revertClass(f);
end
%----------------------------------------------------------------------%
function f=harmean(g,m,n)
%Implements a harmonic mean filter.
[g,revertClass]=tofloat(g);
f=m*n./imfilter(1./(g+eps),ones(m,n),'replicate');
f=revertClass(f);
end
%----------------------------------------------------------------------%
function f=charmean(g,m,n,q)
%Implement a harmonic mean filter.
[g,revertClass] =tofloat(g);
f=imfilter(g.^(q+1),ones(m,n),'replicate');
f=f./(imfilter(g.^q,ones(m,n),'replicate')+eps);
f=revertClass(f);
end
%----------------------------------------------------------------------%
function f=alphatrim(g,m,n,d)
% Implement an alpha-trimmed mean filter.
if (d<=0) || (d/2~=round(d/2))
    error('d must be a positive,even integer.')
end
[g,revertClass]=tofloat(g);
f=imfilter(g,ones(m,n),'symmetric');
for k=1:d/2
    f=f-ordfilt2(g,k,ones(m,n),'symmetric');
end
for k=(m*n-(d/2)+1):m*n
    f=f-ordfilt2(g,k,ones(m,n),'symmetric');
end
f=f/(m*n-d);
f=revertClass(f);
end
%---------------------------------------------------------------------%
function [m,n,Q,d] = processInputs(varargin)
m=3;
n=3;
Q=1.5;
d=2;
if nargin>0
    m=varargin{1};
end
if nargin>1
    n=varargin{2};
end
if nargin>2
    Q=varargin{3};
    d=varargin{3};
end
end
