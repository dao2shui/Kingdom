function m = tifs2movie(file)
%TIFS2MOVIE Create a MATLAB movie from a multiframe TIFF file.
% M = TIFS2MOVIE(FILE) creates a MATLAB MOVIE structure from a multiframe
% tiff file.

% Get file imfo like number of frames in the multi-frame TIFF .
info = imfinfo(file);
frames = size(info,1);

% Create a gray scale map for the uint8 image in the matlab movie
gmap = linspace(0,1,256);
gmap = [gmap' gmap' gmap'];

% Read the tiff frames and add to a matlab movie structure.
for i = 1:frames
    [f,fmap] = imread(file,i);
    if (strcmp(info(i).ColorType,'grayscale'))
        map = gmap;
    else
        map = fmap;
    end
    m(i) = im2frame(f,map);
end
