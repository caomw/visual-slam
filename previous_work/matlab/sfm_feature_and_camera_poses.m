function [idxin, Rc, xc, xf] = sfm_feature_and_camera_poses(pix1, pix2, K, options)
% pix1, pix2 are a set of matched image pixels
% c1 is defined as x=[0;0;0], R=eye(3)
% c2 is xc, Rc
%
% Built from existing open-source software. Does not address lens
% distortion.
if nargin==3, options=[]; end

m3 = 1;
mm = [pix1; pix2]';
[f, ~, ~, idxin, F] = torr_estimateF(mm, m3, options, 'mapsac', 1);
mm = mm(idxin, :);
[mm, ~] = torr_correctx4F(f, mm(:,1), mm(:,2), mm(:,3), mm(:,4), [], m3);

N = size(mm, 1);
x1 = [mm(:,1:2)'; m3*ones(1, N)];
x2 = [mm(:,3:4)'; m3*ones(1, N)];

E = K'*F*K;
E = correct4E(E);
Kinv = inv(K);
xr1 = Kinv*x1;
xr2 = Kinv*x2;
[R, t] = RT_from_E(E, xr1, xr2, N);
[xc, Rc] = transform2relative([0;0;0], eye(3), t, R);

if nargout == 4
    [X, lambda] = compute3DStructure(xr1, xr2, R, t);
    xf = X(1:3, :, 1);
end
