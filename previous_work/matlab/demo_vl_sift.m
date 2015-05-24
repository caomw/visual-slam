function demo_vl_sift()

[left, right] = bumblebee_imread('20111104T002819.924640');
left = im2single(rgb2gray(left));
right = im2single(rgb2gray(right));

pthresh = 0.02;
[fa,da] = vl_sift(left, 'PeakThresh', pthresh);
[fb,db] = vl_sift(right, 'PeakThresh', pthresh);

[matches, scores] = vl_ubcmatch(da,db);
[~, i] = sort(scores, 'descend');
matches = matches(:, i);
scores  = scores(i);

figure
imagesc(cat(2, left, right));
hold on

xa = fa(1, matches(1,:));
xb = fb(1, matches(2,:)) + size(left,2);
ya = fa(2, matches(1,:));
yb = fb(2, matches(2,:));

h = line([xa; xb], [ya; yb]);
set(h,'linewidth', 1, 'color', 'b') ;

vl_plotframe(fa(:,matches(1,:))) ;
fb(1,:) = fb(1,:) + size(left,2) ;
vl_plotframe(fb(:,matches(2,:))) ;
