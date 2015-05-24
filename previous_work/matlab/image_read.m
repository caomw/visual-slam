function [im, rows, cols] = image_read(fname)
% This code is just an example for how to interface with OpenCV. In
% practice, read images via the Matlab function imread.
[im, rows, cols] = mex_image_read(fname);
if nargout == 1
    im = im_raw2rgb(im, rows, cols);
end

% Notes: 
% To convert to grayscale: gr = rgb2gray(rgb);
% To convert to hsv: hsv = uint8(255*rgb2hsv(rgb));
%
