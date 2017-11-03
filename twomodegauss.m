function p= twomodegauss(m1,sig1,m2,sig2,A1,A2,k)
%TWOMODEGAUSS Generate a two-mode gassian function
%A good set of values to try is
%m1=0.15,sig1=0.05,m2=0.75,sig2=0.05,A1=1,A2=0.07,and k=0.002.
c1=A1*(1/((2*pi)^0.5)*sig1);
k1=2*(sig1^2);
c2=A2*(1/((2*pi)^0.5)*sig2);
k2=2*(sig2^2);
z=linspace(0,1,256);
p= k+c1*exp(-((z-m1).^2)./k1)+c2*exp(-((z-m2).^2)./k2);
p=p./sum(p(:));
