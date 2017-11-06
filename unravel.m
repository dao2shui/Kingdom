%UNRAVEL Decode a variable-length bit stream.
% x = unravel(y,link,xlen) decodes uint16 inout vector y based on
% transition and output table link. The elements of y are considered to be
% a contiguous stream of encoded bits -- i.e., the MSB of one element
% follows the LSB of the previous element.Input XLEN is the number code
% words in y ,and thus the size of output vector x (class double).Input
% link is a transition and output table (that drives a series of binary
% searches);
% 
%   1.link(0) is the entry point for decoding ,i.e.,state n = 0.
%   2.If link(n) < 0,the decoded output is |link(n)\;set n = 0.
%   3.If link(n) > 0,get the next encoded bit and transition to state
%   [link(n) - 1] if the bit is 0,else link(n).