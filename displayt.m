function displayt(varargin)
%DISPLAYT  函数将秒转换为天，小时，分钟显示，有两种模式：
% 
% displayt(time) 只输入秒数显示耗时多少天，多少小时，多少分钟，多少秒。
% 
% displayt(time,'name') 显示name+天数，小时，分钟，秒。

% Check the input element number.
narginchk(1,2);

s = varargin{1}; %总秒数
m = fix(s/60); s = rem(s,60); %转化分钟和秒数。
h = fix(m/60); m = rem(m,60); %分钟转化为小时。
d = fix(h/24); h = rem(h,60); %小时转化为天。
if nargin == 1
    fprintf('总共耗时%.2f天，%.2f小时，%.2f分钟，%.2f秒\n',d,h,m,s);
elseif nargin == 2
    name = varargin{2};
    fprintf('%s is cost %.2f day , %.2f hour, %.2f minute, %.2f second\n',...
        name,d,h,m,s);
end
