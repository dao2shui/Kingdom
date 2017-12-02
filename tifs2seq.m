function s = tifs2seq(file)
%TIFS2SEQ Create a MATLAB squence from a multi-frame TIFF file.

% Get the number of frames in the multi-frame TIFF.
frames = size(imfinfo(file),1);

% Read the first frame, preallocate the sequence, and put the first in it 
i = imread(file,1);
s = zeros([size(i) 1 frames],'uint8');
s(:,:,:,1) = i;

% Read the remaining TIFF frames and add to the sequence.
for i = 2:frames
    s(:,:,:,i) = imread(file,i);
end
