function corr = patch_correlate(x, im1, im2, org2, mx, my)
% It is assumed that (i) im1 and im2 are centre-origin, and (ii) im2 is
% inflated to allow for transforms (ie., sufficiently bigger than im1).

assert(isfloat(im1) && isfloat(im2), 'Image must be in floating-point format')
%if ~isa(im1, 'double'), im1 = double(im1); end
%if ~isa(im2, 'double'), im2 = double(im2); end

im2t = patch_transform_evaluate(im2, org2, x, mx, my);
imshow(uint8(im2t)), drawnow
corr = -sum(im1(:).*im2t(:)); % note, negative for fminunc
%corr = -median(log(im1(:)) + log(im2t(:)));
