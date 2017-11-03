function av= average(A)
%AVERAGE computes the average value of an array.
%which must be a 1-D or 2-D array.

%Check the validity of the input,(keep in mind that a 1-D array is a
%special case of a 2-D array.)
if ndims(A)>2
    error('The dimensions of the input cannot exceed 2');
end

%Compute the average
av =sum(A(:))/length(A(:));
