function [pd, imdiff] = patch_difference(x, im1, im2, org2, gridx, gridy, type)
% It is assumed that (i) im1 and im2 are centre-origin, and (ii) im2 is
% inflated to allow for transforms (ie., sufficiently bigger than im1).
 if nargin == 6, type = 1; end

assert(isfloat(im1) && isfloat(im2), 'Image must be in floating-point format')

im2t = patch_transform_evaluate(im2, org2, x, gridx, gridy);
imshow(uint8(im2t)), drawnow

if 1 % Normalise by average intensity
    im1 = im1 - mean(im1(:));
    im2t = im2t - mean(im2t(:));
end

imdiff = (im1 - im2t);
switch type
    case 1 % L2 norm (SSD)
        pd = sum(imdiff(:).^2);
    case 2 % L1 norm (SAD)
        pd = sum(abs(imdiff(:)));
    case 3 % LMS
        pd = median(imdiff(:).^2);
end
