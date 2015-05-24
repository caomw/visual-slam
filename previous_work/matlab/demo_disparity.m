function demo_disparity(usecolour)

[left, right] = bumblebee_imread('shrimp_data/20111104T002819.924640');
if nargin == 0 || ~usecolour
    left = rgb2gray(left);
    right = rgb2gray(right);
end
dspty = stereo_sgbm(left, right);

figure
imagesc(cat(2, left, right))
axis image off
figure
imagesc(dspty)
axis image off
