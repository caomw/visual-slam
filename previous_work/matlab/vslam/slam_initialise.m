function [xcstore, xf, flags] = slam_initialise(z, i1, i2, K, Nfinit)
% To initialise SLAM, all we need is a rough guess at xs

% Use standard two-view SFM to initialise relative camera pose (xc_j relative to xc_i)
[~, a, b] = intersect(z(i1).fid, z(i2).fid); % get matched features
[~, Rc, xc, ~] = sfm_feature_and_camera_poses(z(i1).z(:,a), z(i2).z(:,b), K); 
x2 = [xc; R2a(Rc)];

% Non-homogenous K (2x3 matrix) and its inverse
K23 = K(1:2,:); 
Kinv = inv(K); 
Ki23 = Kinv(1:2,:); 

% Storage for all landmark estimates
xf = zeros(3, max([z.fid]));
flags = false(1, size(xf,2));

% Initialise two-view landmarks 
fid = z(i1).fid(a);
xf(:,fid) = localise_landmarks_given_two_cameras(z(i1).z(:,a), z(i2).z(:,b), xc, Rc, Ki23);
flags(fid) = 1;

% TODO (optional): Improve two-view estimate via robust least squares

% Start to accumulate landmark/observation statistics
obs = initialise_observation_store(z);
obs = store_observations(obs, z(i1), i1);
obs = store_observations(obs, z(i2), i2);
N = length(z);
xcstore = zeros(6, N);
xcstore(:,i2) = x2;

% Use localisation and projection to initialise remaining cameras and landmarks
xc = zeros(6,1); 
dx = xc;
for i = 1:N
    % Compute camera pose
    b = find(flags(z(i).fid) == 1); % index features from z(i) that are initialised
    a = z(i).fid(b);                % index of these features (index==fid)
    xpred = predict_pose(xc, dx);
    xc = localise_camera_given_landmarks(xf(:,a), z(i).z(:,b), K23, xpred, 3, true);
    dx = change_in_pose(xc, xpred);
    disp(['X = ' num2str(xc(1:3)') '(m), A = ' num2str(xc(4:6)'*180/pi) '(deg)'])
    xcstore(:,i) = xc;
    
    % Store new observations
    if i == i1 || i == i2, continue, end
    obs = store_observations(obs, z(i), i);
    
    % Add new landmarks to (xf, fid)
    fidadd = get_new_initialisable_landmarks(z(i).fid, b, obs, Nfinit);
    flags(fidadd) = 1;
    a = [a fidadd];

    % Update existing landmarks
    for j = 1:length(a)
        pj = obs(a(j)).z;
        xj = xcstore(:, obs(a(j)).ic);
        %if size(pj, 2) > Nfinit+2, continue, end
        %xf(:,a(j)) = localise_landmark_given_multiple_cameras(pj, xj, xf(:,a(j)), Ki23, 2, true);
        xf(:,a(j)) = simple_landmark_initialise(pj, xj, Ki23);
    end    
    
    % Plotting
    ii = 1:i;
    plot(xcstore(1,ii), xcstore(3,ii), '*', xf(1,flags), xf(3,flags),'.')
    drawnow
    axis equal
end

%xf = xf(:, flags); % uncomment if we only want xf that has been initialised
i = find(xf(3,:) > 0 & xf(3,:) < 50);
plot3(xcstore(3,:), -xcstore(1,:), -xcstore(2,:), '*', xf(3,i), -xf(1,i), -xf(2,i),'.')
axis normal, grid
%xs = [xcstore(:); xf(:)];

%
%

function xpred = predict_pose(x, dx)
[x, R] = transform2global(dx(1:3), a2R(dx(4:6)), x(1:3), a2R(x(4:6)));
xpred = [x(1:3); R2a(R)];

function dx = change_in_pose(xnew, x)
[x, R] = transform2relative(xnew(1:3), a2R(xnew(4:6)), x(1:3), a2R(x(4:6)));
dx = [x(1:3); R2a(R)];

function obs = initialise_observation_store(z)
M = max([z.fid]);
obs(M).ic = []; 
obs(M).z = [];

function obs = store_observations(obs, z, ic)
for i = 1:length(z.fid)
    ii = z.fid(i);
    obs(ii).ic = [obs(ii).ic ic];
    obs(ii).z = [obs(ii).z z.z(:,i)];
end

function fidadd = get_new_initialisable_landmarks(fid, iold, obs, M)
iadd = idx_other(iold, length(fid));
fidadd = fid(iadd);
for i = 1:length(fidadd)
    if length(obs(fidadd(i)).ic) < M
        fidadd(i) = -1; 
    end
end
fidadd = fidadd(fidadd ~= -1);

function xf = simple_landmark_initialise(pixs, xc, Kinv)
% Get xc pair with biggest baseline and initialise xf with that
d2 = dist_sqr(xc(1:3,:), xc(1:3,:));
[i, j] = find(d2 == max(d2(:)));
xf = localise_landmark_given_cameras_ij(pixs, xc, i(1), j(1), Kinv);
