function [fa,fb] = demo_feature_matching(im1, im2, fa, fb)
if nargin == 0
    [im1, im2]  = bumblebee_imread('shrimp_data/20111104T002819.924640', false);
    %[~, im2] = bumblebee_imread('shrimp_data/20111104T002820.235449', false);
end

if nargin < 4
    pthresh = 0.02; % SIFT
    M = 300;        % SIFT matches
    left = im2single(rgb2gray(im1));
    right = im2single(rgb2gray(im2));

    % SIFT features and matches
    [fa,da] = vl_sift(left, 'PeakThresh', pthresh);
    [fb,db] = vl_sift(right, 'PeakThresh', pthresh);
    [matches, scores] = vl_ubcmatch(da,db);
    if M && length(scores)>M
        [~, i] = sort(scores, 'descend');
        matches = matches(:, i(1:M));
    end
    fa = fa(:, matches(1,:)); 
    fb = fb(:, matches(2,:));

    % Mapsac for data association gate
    if 1
        [~, ~, ~, idxin] = torr_estimateF([fa(1:2,:); fb(1:2,:)]', 1, [1e4 1], 'mapsac', 1);
        fa = fa(:, idxin);
        fb = fb(:, idxin);
    end
end
fa = fa(1:2,:);
fb = fb(1:2,:);

% Plot results
figure
imagesc(cat(2, im1, im2))
axis image off
hold on
h1 = line([fa(1,:); fb(1,:)], [fa(2,:); fb(2,:)]);
h2 = line([fa(1,:); fb(1,:)]+size(im1,2), [fa(2,:); fb(2,:)]);
set(h1,'linewidth', 1, 'color', 'r');
set(h2,'linewidth', 1, 'color', 'r');
vl_plotframe(fa);
vl_plotframe([fb(1,:)+size(im1,2); fb(2:end,:)]);
