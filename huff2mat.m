function x = huff2mat(y)
%HUFF2MAX Decodes a huffman encoded matrix.
% X = huff2mat(y) decodes a huffman encoded structure y with uint16 fields:
%   y.min  Minimum value of x plus 32768
%   y.size Size of x
%   y.hist Histogram of x
%   y.code Huffman code
% 
% The output x is of class double.
% 
% See also mat2huff.

if ~isstruct(y) || ~isfield(y,'min') || ~isfield(y,'size') || ...
        ~isfield(y,'hist') || ~isfield(y,'code')
     error('The input must be a structure as returned by mat2huff.');
end

sz = double(y.size); m = sz(1); n = sz(2);
xmin = double(y.min) - 32768;  %Get x minimum
map = huffman(double(y.hist)); %Get huffman code (cell)

% Create a binary search table for the huffman decoding process .'code'
% contains source symbol strings corresponding to 'link' nodes ,while
% 'link' contains the addresses (+) to node pairs for node symbol strings
% plus '0' and '1' or addressess (-) to decoded huffman codewords in
% 'map'.Array  'left' is a list of nodes yet to be processed for
% 'link' entries.

code = cellstr(char('','0','1'));  %Set starting conditions as 3 nodes w/2 unprocessed 
link = [2;0;0]; left = [2 3];
found = 0; tofind = length(map);   %Tracking variables.

while ~isempty(left) && (found < tofind)
    look = find(strcmp(map,code{left(1)})); %Is string in map 
    if look 
        link(left(1)) = ~look;
        left = left(2:end);
        found = found + 1;
    else
        len = length(code);
        link(left(1)) = len + 1;
        
        link = [link; 0;0];           %Add unprocessed nodes
        code{end + 1} = strcat(code{left(1)},'0');
        code{end + 1} = strcat(code{left(1)},'1');
        left = left(2:end);           %Remove processed node
        left = [left len+1 len+2];    %Add 2 unprocessed nodes 
    end
end

x = unravel(y.code',link,m * n);      %Decode using C 'unravel'
x = x + xmin -1;                      %X minimum offset adjust
x = reshape(x,m,n);                   %Make vector an array
