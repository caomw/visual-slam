function demo_vl_sift_pose(type)

pthresh = 0.02;
%pthresh = 0;
M = 300;
optF = [1e4 1];

% Get data
[~, dL] = bumblebee_configfile('shrimp_data/bumblebee.config', 'left'); 
[K, dR] = bumblebee_configfile('shrimp_data/bumblebee.config', 'right'); 
[leftim, rightim]  = bumblebee_imread('shrimp_data/20111104T002819.924640', false);
%[~, rightim] = bumblebee_imread('shrimp_data/20111104T002820.235449', false);
left = im2single(rgb2gray(leftim));
right = im2single(rgb2gray(rightim));

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
%plot_matches(leftim, rightim, fa, fb)

% Fundamental matrix
m3 = 1;
switch type
    case 1 % use torr's fundamental matrix
    mm = [fa(1:2,:); fb(1:2,:)]';
    [f, ferrs, nin, idxin, F] = torr_estimateF(mm, m3, optF, 'mapsac', 1);
    mm = mm(idxin, :);
    %plot_matches(leftim, rightim, [mm(:,1:2)'; fa(3:4,idxin)], [mm(:,3:4)'; fb(3:4,idxin)])
    [mm, err2] = torr_correctx4F(f, mm(:,1), mm(:,2), mm(:,3), mm(:,4), [], m3);
    plot_matches(leftim, rightim, [mm(:,1:2)'; fa(3:4,idxin)], [mm(:,3:4)'; fb(3:4,idxin)])
    case 2 % use Matlab version
    [F, x1in, x2in] = vipfmatrix_ransac(fa(1:2,:), fb(1:2,:), 10000, 1);
    plot_matches(leftim, rightim, x1in, x2in)
    mm = [x1in; x2in]';
    case 3 % Korvesi
        %[F, inliers] = ransacfitfundmatrix7(fa(1:2,:), fb(1:2,:), 0.01);
        [F, inliers] = ransacfitfundmatrix(fa(1:2,:), fb(1:2,:), 0.001);
        mm = [fa(1:2,inliers); fb(1:2,inliers)]';
        plot_matches(leftim, rightim, fa(1:2,inliers), fb(1:2,inliers))
end
F
N = size(mm, 1)
x1 = [mm(:,1:2)'; m3*ones(1, N)];
x2 = [mm(:,3:4)'; m3*ones(1, N)];

% Average motion in pixels
xd = mm(:,1:2) - mm(:,3:4);
d = mean(vectorNorm(xd, 2))

% Convert from pixels to 2D-projected image (metres/metre), and undistort
Kinv = inv(K);
xr1 = Kinv*x1;
xr2 = Kinv*x2;
xr1(1:2,:) = apply_distortion(xr1(1:2,:), dL);
xr2(1:2,:) = apply_distortion(xr2(1:2,:), dR);

% Essential matrix
E = K'*F*K;
E = correct4E(E);
[R, t] = RT_from_E(E, xr1, xr2, N);
disp(['Translate: ' num2str(t', '%9.5f,') ' Rotate (deg): ' num2str(R2a(R)' *180/pi, '%9.5f,')])

plot_structure(xr1, xr2, R, t)

% Try to optimise pose to minimise distance
distance2lines(xr1(1:2,:), xr2(1:2,:), t, R', 1);
x = [t(1:2); R2a(R')];
for i = 1:10
    x = fminunc(@disterr, x, [], xr1(1:2,:), xr2(1:2,:), t(3));
end
to = [x(1:2); t(3)];
Ro = a2R(x(3:5))';
distance2lines(xr1(1:2,:), xr2(1:2,:), to, Ro', 1);

plot_structure(xr1, xr2, Ro, to)

%
%

function plot_matches(left, right, fa, fb)
figure
imagesc(cat(2, left, right))
axis image off
hold on
h = line([fa(1,:); fb(1,:)+size(left,2)], [fa(2,:); fb(2,:)]);
set(h,'linewidth', 1, 'color', 'b');
vl_plotframe(fa);
vl_plotframe([fb(1,:)+size(left,2); fb(2:end,:)]);

function plot_structure(xr1, xr2, R, t)
%[X, lambda] = compute3DStructure(xr1, xr2, R, t, K);
[X, lambda] = compute3DStructure(xr1, xr2, R, t);
for i = 1:1
    if 0
        figure, plot3(X(1,:,i), X(2,:,i), X(3,:,i), '.'), axis equal
    else
        figure, plot(X(1,:,i), X(3,:,i), '.'), axis equal, xlabel('x'), ylabel('z')
        figure
        subplot(2,1,1), plot(X(1,:,i), -X(2,:,i), '.'), axis equal, xlabel('x'), ylabel('-y')
        subplot(2,1,2), plot(X(3,:,i), -X(2,:,i), '.'), axis equal, xlabel('z'), ylabel('-y')
    end
end

function D = disterr(x, im1, im2, z)
xy = x(1:2);
[r1, r2, D] = distance2lines(im1, im2, [xy; z], a2R(x(3:5)));
D = sum(D./(r1.^2 + r2.^2));
