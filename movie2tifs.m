function movie2tifs(m,file)
%MOVIE2TIFS Creates a multiframe TIFF file from a MATLAB movie.
% movie2tifs(m,file) creates a multiframe TIFF file from the specified
% MATLAB movie structure ,M.

% Write the first frame of the movie to the multiframe TIFF.
imwrite(frame2im(m(1)),file,'Compression','none','WriteMode','overwrite');
% Read the remaining frames and append to the TIFF file.
for i = 2:length(m)
    imwrite(frame2im(m(i)),file,'Compression','none','WriteMode','append');
end
