function [left, right] = bumblebee_imread(fname, rectify)
persistent mapxL mapyL mapxR mapyR
if isempty(mapxL)
    [mapxL, mapyL] = bumblebee_rectify_matrix('shrimp.bumblebee-left.bin');
    [mapxR, mapyR] = bumblebee_rectify_matrix('shrimp.bumblebee-right.bin');
end

left = imread([fname '.left.png']);
right = imread([fname '.right.png']);

if nargin == 1 || rectify
    left = im_remap(left, mapxL, mapyL);
    right = im_remap(right, mapxR, mapyR);
end
