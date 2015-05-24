function [im, rows, cols] = im_rgb2raw(rgb)
% Convert image to the raw column-array format expected by my OpenCV mex functions

[rows, cols, ~] = size(rgb);
if 1
    r = rgb(:,:,1)'; 
    g = rgb(:,:,2)'; 
    b = rgb(:,:,3)';
    bgr = [b(:) g(:) r(:)]';
    im = bgr(:);
else
    im = uint8(zeros(rows*cols*3, 1));
    im(1:3:end) = rgb(:,:,3)';
    im(2:3:end) = rgb(:,:,2)';
    im(3:3:end) = rgb(:,:,1)';
end
