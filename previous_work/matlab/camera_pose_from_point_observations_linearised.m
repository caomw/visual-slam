function xc = camera_pose_from_point_observations_linearised(xg, im, xc, N)
% xg are global 3D points [x;y;z], im are [x/z;y/z] observations of xg as
% taken from camera at xc [x;y;z;r;p;y]. The input xc is a linearisation
% parameter.  
% Note, im is NOT in pixels.
if nargin == 3, N = 5; end
for i = 1:N
    [H, zpred] = numerical_jacobian_i(@observation_model, [], 1, [], xc, xg);
    v = im(:) - zpred + H*xc; % note, this is not the innovation, which is just im(:) - zpred
    xc = (H'*H)\(H'*v);
end

%
%

function z = observation_model(xc, xg)
R = a2R(xc(4:6));
xr = R'*(xg - repcol(xc(1:3), size(xg,2)));
z = xr(1:2,:)./reprow(xr(3,:),2);
z = z(:);
