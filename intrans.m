function g =intrans(f,method,varargin)
%INTRANS performs intensity (gray-level) tansformation.

%verify the correct number of input.
error(nargchk(2,4,nargin));

if strcmp(method,'log')
    %The log tansform handles image classes differently than the other
    %tansforms ,so let teh logTransform function handle that and then
    %return.
    g =logTransform(f,varargin{:});
    return;
end
[f,revertclass] = tofloat(f);%Store class of f for use later.
%perform the intensity transformation specified.
switch method
    case 'neg'
        g=imcomplement(f);
    case 'gamma'
        g=gammaTransform(f,varargin{:});
    case 'stretch'
        g= stretchTransform(f,varargin{:});
    case 'specified'
        g= spcfiedTransform(f,varargin{:});
    otherwise
        error('Unknown enhancement method')
end

%Convert to the class of the input image.
g=revertclass(g)
%---------------------------------------------------%
function g=gammaTransform(f,gamma)
g=imadjust(f,[],[],gamma);
%---------------------------------------------------%
function g=stretchTransform(f,varargin)
%À­Éì±ä»»
if isempty(varargin)
    %Use defaults.
    m=mean2(f);
    E=4.0;
else if length(varargin) == 2
        m=varargin{1};
        E=varargin{2};
    else
        error('Incorrect number of inputs for the stretch method.');
    end
end
 g=1./(1+(m./f).^E);
 %--------------------------------------------------%
function g=spcfiedTransform(f,txfun)
        %f is floating point with values in the range [0 1].
txfun =txfun(:);%Force it to be a column vector.
if any(txfun) >1 ||any(txfun)<=0
    error('All elements of txfun must be in the range [0 1].');
end
T=txfun;
X=linspace(0,1,numel(T))';
g=interp1(X,T,f);
%-------------------------------------------------%
function g= logTransform(f,varargin)
[f,revertclass] = tofloat(f);
if numel(varargin)>=2
    if strcmp(varargin{2},'uint8')
        revertclass =@im2uint8;
    else if strcmp(varargin{2},'uint16')
            revertclass =@im2uint16;
        else
            error('Unsupported class option for "log" method.');
        end
    end
end
if numel(varargin) <1
    %Set dafault for C
    C=1;
else
    C=varargin{1};
end
g=C*(log(1+f));
g=revertclass(g);
