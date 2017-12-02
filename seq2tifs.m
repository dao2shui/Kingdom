function seq2tifs(s,file)
%SEQ2TIFS Create a multiframe TIFF file from a MATLAB sequence.

% Write the first frame of the sequence to the multiframe TIFF.
imwrite(s(:,:,:,1),file,'Compression','none','WriteMode','overwrite');

% Read the remaining frames and append to the TIFF file.
for i = 2:size(s,4)
    imwrite(s(:,:,:,i),file,'Compression','none','WriteMode','append');
end
