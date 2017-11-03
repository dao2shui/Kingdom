function p = manualhist
%MANUALHIST Generates a two-mode histogram interactively.

%Initialize.
repeats = true;
quitnow = 'x';

%compute a defult histogram in case the user quits before estimating at
%least one histogram.
p=twomodegauss(0.15,0.05,0.75,0.05,1,0.07,0.002);

%Cycle until an x is input.
while repeats
    s=input('Enter m1,sig1,m2,sig2,A1,A2,k OR x to quit:','s');
    if strcmp(s,quitnow)
        break
    end
    
    %Convert the input string to vector of numerical values and verify the
    %number of input.
    v=str2num(s);
    if numel(v)~=7
        disp('Incorrect number of input.')
        continue
    end
    p=twomodegauss(v(1),v(2),v(3),v(4),v(5),v(6),v(7));
    %Start a new figure and scale the axes .Specifying only xlim leave ylim
    %on auto.
    figure,plot(p)
    xlim([0 255])
end
