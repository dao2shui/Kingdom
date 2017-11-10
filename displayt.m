function displayt(varargin)
%DISPLAYT  ��������ת��Ϊ�죬Сʱ��������ʾ��������ģʽ��
% 
% displayt(time) ֻ����������ʾ��ʱ�����죬����Сʱ�����ٷ��ӣ������롣
% 
% displayt(time,'name') ��ʾname+������Сʱ�����ӣ��롣

% Check the input element number.
narginchk(1,2);

s = varargin{1}; %������
m = fix(s/60); s = rem(s,60); %ת�����Ӻ�������
h = fix(m/60); m = rem(m,60); %����ת��ΪСʱ��
d = fix(h/24); h = rem(h,60); %Сʱת��Ϊ�졣
if nargin == 1
    fprintf('�ܹ���ʱ%.2f�죬%.2fСʱ��%.2f���ӣ�%.2f��\n',d,h,m,s);
elseif nargin == 2
    name = varargin{2};
    fprintf('%s is cost %.2f day , %.2f hour, %.2f minute, %.2f second\n',...
        name,d,h,m,s);
end
