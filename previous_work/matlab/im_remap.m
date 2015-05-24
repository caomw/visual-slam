function im = im_remap(im, mapx, mapy, rows, cols)
% Matlab wrapping OpenCV remap() function with linear interpolation.

if nargin == 3 % convert from image matrix to column format
    [im, rows, cols] = im2raw(im);
end

if size(mapx,2) == 1
    N = rows*cols; % already in column format
    assert(length(mapx) == N && length(mapy) == N)
else
    [mapx, rx, cx] = im2raw(mapx); % convert to column format
    [mapy, ry, cy] = im2raw(mapy);
    assert(rx == rows && cx == cols && ry == rows && cy == cols)
end

im = mex_remap(im, rows, cols, mapx, mapy);

if nargin == 3 % convert back to image matrix format
    im = raw2im(im, rows, cols);
end
