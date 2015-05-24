function p = patch_extract_transform(im, x, r)
% Get patch at location (x) in image using a mask projected into the frame
% of (x).

assert(r == round(r), 'Mask radius must be an integer number of pixels');
[mx,my] = meshgrid(-r:r, -r:r);
p = patch_transform_evaluate(im, [], x, mx, my);
