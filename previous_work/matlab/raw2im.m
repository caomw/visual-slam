function im = raw2im(im, rows, cols)
% Reverse operation of im2raw.

N = rows*cols;
dim = length(im)/N;
if dim == 1
    im = reshape(im, cols, rows);
    im = im';
elseif dim == 3
    im = im_raw2rgb(im, rows, cols);
else
    assert('Cannot happen')
end
