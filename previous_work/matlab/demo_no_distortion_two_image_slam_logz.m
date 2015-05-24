function [x,idxin] = demo_no_distortion_two_image_slam_logz()

% Tunables
notsliding = 1; % not a stereo pair; ie., also has z offset  
pthresh = 0.02; % SIFT
M = 300;        % SIFT matches
Rp = [1 0; 0 1]*1;% pixel uncertainty (in pixels^2)

% Get data
K = bumblebee_configfile('shrimp_data/bumblebee.config', 'left'); 
[leftim, rightim]  = bumblebee_imread('shrimp_data/20111104T002819.924640', false);
if notsliding
    [~, rightim] = bumblebee_imread('shrimp_data/20111104T002820.235449', false);
end
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
M = size(fa, 2);

% Refine feature alignment
if 0
    B = 35;
    [YMAX, XMAX] = size(leftim);
    for i = 1:M
        f = fa(:,i); if f(1) < B || f(2) < B || f(1) > XMAX-B || f(2) > YMAX-B, continue, end
        f = fb(:,i); if f(1) < B || f(2) < B || f(1) > XMAX-B || f(2) > YMAX-B, continue, end
        disp(M-i)
        [pa, ma] = patch_extract(leftim, fa(:,i), 8);
        [pb, mb] = patch_extract(rightim, fb(:,i), 30);
        xoff = patch_align(double(pa), double(pb), [0;0;0], 4);
        fa(1:2,i) = ma;
        fb(1:2,i) = mb + xoff(1:2);
    end
end

% Fundamental matrix -> just for mapsac gating
if 1
    [~, ~, ~, idxin] = torr_estimateF([fa(1:2,:); fb(1:2,:)]', 1, [1e4 1], 'mapsac', 1);
    fa = fa(:, idxin);
    fb = fb(:, idxin);
    M = size(fa, 2);
end

% Initialise state linearisation: [x;y;z;r;p;y; x1;y1;z1; x2;y2;z2; ...]
K = K(1:2,:); 
Kinv = K_inverse(K);
ibase = 1;
xc = [1; 0; 0; 0; 0; 0];
if 1 % initialise via SFM
    KK = [K; [0 0 1]];
    [~, Rc, xc, ~] = sfm_feature_and_camera_poses(fa(1:2,:), fb(1:2,:), KK); xc'
    xc = [xc; R2a(Rc)];
end
xf = init_feature_position(fa(1:2,:), fb(1:2,:), xc(1:3), a2R(xc(4:6)), Kinv);
xs = [xc; xf];

% Estimate
figure, c = 'kbrgycm';
for k = 1:40
    % Initialise state estimate: scale (note, base frame is known implicity as 0)
    N = length(xs);
    y = zeros(N, 1);
    Y = zeros(N, N);
    Y(ibase,ibase) = 1e4; % baseline
    y(ibase) = Y(ibase,ibase)*xs(ibase);

    for i = 1:M % observe fa
        ii = (1:3) + i*3 + 3;
        Hs = numerical_jacobian_i(@observation_model, [], 1, [], xs(ii), [0;0;0], [0;0;0], K);
        [yi, Yi] = canonical_update_linearised(zeros(3,1), zeros(3), ...
            @observation_model, [], fa(1:2,i), Rp, xs(ii), Hs, 1:3, 0, [0;0;0], [0;0;0], K);
        y(ii) = y(ii) + yi;
        Y(ii,ii) = Y(ii,ii) + Yi;
    end
    
    for i = 1:M % observe fb
        ii = [1:6, (1:3) + i*3 + 3];
        Hs = numerical_jacobian_i(@observe_wrapper, [], 1, [], xs(ii), K);
        [yi, Yi] = canonical_update_linearised(zeros(9,1), zeros(9), ...
            @observe_wrapper, [], fb(1:2,i), Rp, xs(ii), Hs, 1:9, 0, K);
        y(ii) = y(ii) + yi;
        Y(ii,ii) = Y(ii,ii) + Yi;
    end
    
    x = full(sparse(Y)\y);
    r = compute_residuals(x, full(inv(Y)), xs, fa(1:2,:), fb(1:2,:), Rp, K);
    disp(['X = ' num2str(x(1:3)') ' (m), A = ' num2str(x(4:6)'*180/pi) ' (deg), rcond = ' num2str(rcond(full(Y)))])
    
    ps = state_to_position(xs(7:end));
    pp = state_to_position(x(7:end));
    lne = line_plot_conversion_([ps(1:3:end) ps(3:3:end)]', [pp(1:3:end) pp(3:3:end)]');
    ck = c(mod(k,7)+1);
    plot(x(1),x(3),[ck '*'], pp(1:3:end), pp(3:3:end), [ck '.'], lne(1,:),lne(2,:),ck)
    axis equal, hold on
    hold off, drawnow        
    
    if k <= 5 % revise camera pose only
        [yf, Yf] = canonical_marginalise(y, sparse(Y), 1:6);
        x = full(Yf)\yf;
rc = rcond(full(Yf)) 
if rc < 1e-9
    warning('badstuff')
end
        xf = init_feature_position(fa(1:2,:), fb(1:2,:), x(1:3), a2R(x(4:6)), Kinv);
        xs = [x(1:6); xf];
    else
        disp('Linearise on x')
        xs = x;   
        
        % but don't use x if range uncertainty too large
        P = diag(full(inv(Y))); 
        rs = exp(sqrt(P(9:3:end))); 
        ibad = find(rs > 30)';
        if ~isempty(ibad)
            %xf = init_feature_position(fa(1:2,ibad), fb(1:2,ibad), x(1:3), a2R(x(4:6)), Kinv);
            ii = reprow(1:3,length(ibad))' + reprow(ibad,3)*3 + 3;
            iim = ii(1:2,:);
            faest = K*[reshape(x(iim(:)),2,length(ibad)); ones(1,length(ibad))];
            xf = init_feature_position(faest, fb(1:2,ibad), x(1:3), a2R(x(4:6)), Kinv);
            xs(ii(:)) = xf;
        end
    end
    xs(ibase) = xc(ibase);
end

figure, plot(r')

%
%

function x = init_feature_position(pix1, pix2, xr, Rr, Kinv)
% Feature position state: x = [xim, yim, log(z)]
z = ones(1, size(pix1,2));
im1 = Kinv*[pix1; z];
im2 = Kinv*[pix2; z];
r1im = sqrt(sum(im1.^2) + 1); % rim^2 = xim^2 + yim^2 + 1
r1 = distance2lines(im1, im2, xr, Rr);
logz1 = log(abs(r1 ./ r1im));
x = [im1; logz1];
x = x(:);

function x = state_to_position(x)
z = exp(x(3:3:end));
x(1:3:end) = x(1:3:end) .* z;
x(2:3:end) = x(2:3:end) .* z;
x(3:3:end) = z;

function xc = test_camera_pose_localise(pix, Kinv, xf)
N = size(pix,2);
xf = reshape(xf, 3, N); 
xf(3,:) = exp(xf(3,:));
im = Kinv*[pix; ones(1,N)];
[xc,Rc] = camera_pose_from_point_observations(xf, im);
xc = [xc; R2a(Rc)];

function xc = test_camera_pose_localise_linearised(x, pix, xc, Kinv)
N = size(pix,2);
xg = reshape(x(7:end), 3, N);
xg(3,:) = exp(xg(3,:));                     % convert logz to z
xg(1:2,:) = xg(1:2,:).*reprow(xg(3,:),2);   % convert (x/z;y/z) to (x;y)
im = Kinv*[pix; ones(1,N)];                 % convert pix to (x/z;y/z)
xc = camera_pose_from_point_observations_linearised(xg, im, xc);

function Kinv = K_inverse(K)
% Not really inverse K. Just the inverse transform from pixels to (unitless) image.
%idx = index_table_(size(K), [1 1; 1 2; 1 3; 2 2; 2 3]');
%[fx, s, xo, fy, yo] = array_unpack(K(idx));
[fx, ~, s, fy, xo, yo] = array_unpack(K(:));
Kinv = [1/fx, -s/(fx*fy), (s*yo - fy*xo)/(fx*fy);
          0,     1/fy,       -yo/fy];

function z = observe_wrapper(x, K)
z = observation_model(x(7:9), x(1:3), x(4:6), K);

function z = observation_model(xf, xc, ac, K)
xf = state_to_position(xf);
R = a2R(ac);
xrel = R'*(xf-xc);          % 3D feature in camera frame
xim = xrel(1:2)/xrel(3);    % perspective projection onto 2D plane
z = K*[xim;1];              % convert to pixel coordinates

function r = compute_residuals(x, P, xs, za, zb, R, K)
N = size(za, 2);
r = zeros(2, N);
zpa = zeros(size(za)); zpb = zpa;
for i = 1:N
    ia = (1:3) + i*3 + 3;
    ib = [1:6 ia];
    
    Ha = numerical_jacobian_i(@observation_model, [], 1, [], xs(ia), [0;0;0], [0;0;0], K);
    Hb = numerical_jacobian_i(@observe_wrapper, [], 1, [], xs(ib), K);
    zpa(:,i) = observation_model(xs(ia), [0;0;0], [0;0;0], K) + Ha*(x(ia) - xs(ia));
    zpb(:,i) = observe_wrapper(xs(ib), K) + Hb*(x(ib) - xs(ib));
    
    r(1,i) = single_residual(za(:,i), zpa(:,i), Ha, R, P(ia,ia));
    r(2,i) = single_residual(zb(:,i), zpb(:,i), Hb, R, P(ib,ib));
end
%figure, plot(za(1,:), za(2,:), '.', zpa(1,:), zpa(2,:), '.')

function r = single_residual(z, zpred, H, R, P)
v = z - zpred;
S = H*P*H' + R;                
r = v'*(S\v);                
