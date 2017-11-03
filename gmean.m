function v= gmean(A)
%GMEAN Geometric mean of columns.
%V=gmean(A)computes the geometric mean of the columns of A.V is a row
%vector with size(A,2) elements.

m=size(A,1);
v=prod(A,1).^(1/m);
