function [p, midp] = patch_extract(im, f, rmin)

if nargin == 3 && rmin > f(3)
    f(3) = rmin; 
end

r = ceil(f(3));
r = -r:r; % always odd number of pixels, so middle pixel is midpoint coordinate
midp = round(f(1:2));
% FIXME: account for image boundaries (ie., features close to im(0,?), im(end,?), etc
x = midp(1) + r; 
y = midp(2) + r;
p = im(y, x, :); % note, indexing for (x,y) reversed
imshow(p)
