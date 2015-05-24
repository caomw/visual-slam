function disparity = stereo_sgbm(im1, im2, rows, cols)
assert(isa(im1, 'uint8') && isa(im2, 'uint8'), 'Images must be 8-bit unsigned')

if nargin == 2
    [im1, rows, cols] = im2raw(im1);
    [im2, r2, c2] = im2raw(im2);
    assert(r2 == rows && c2 == cols)
else
    assert(numel(im1) == numel(im2))
    assert(numel(im1) == rows*cols || numel(im1) == 3*rows*cols)
end
    
disparity = int16(zeros(cols,rows));
disparity(:) = mex_stereo_sgbm(rows, cols, im1, im2);
disparity = disparity';

if 1 % convert to actual disparity in floating point format
    disparity = double(disparity)/16;
end
