function [im, rows, cols] = im2raw(im)
% Convert colour and gray-scale images to column-order format required by
% my mex files.

[rows, cols, dim] = size(im);
if dim == 1
    im = im';
    im = im(:);
elseif dim == 3
    [im, r, c] = im_rgb2raw(im);
    assert(r == rows && c == cols)
else
    assert('Cannot happen')
end
