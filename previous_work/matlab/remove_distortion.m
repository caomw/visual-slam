function xu = remove_distortion(x, dist)
% Apply Brown's undistortion model.
% It is assumed that:
%   - x is not in homogenous coordinates (or has the 3rd dimension = 1)
%   - x is centred (ie., xc = (0,0))
%   - x is the image-plane mapped representation of the 3D points (ie., the
%   unitless projection determined by the focal length, not in pixel coordinates)

[K1, K2, p1, p2, K3] = array_unpack(dist); % distortion params as per openCV

r2 = x(1,:).^2 + x(2,:).^2;
r4 = r2.*r2;
r6 = r2.*r4;

dr = 1 + K1*r2 + K2*r4 + K3*r6; % radial distortion

a1 = 2*x(1,:).*x(2,:);
a2 = r2 + 2*x(1,:).^2;
a3 = r2 + 2*x(2,:).^2;
dtx = p1*a1 + p2*a2; % tangential distortion in x
dty = p1*a3 + p2*a1; % tangential distortion in y
% FIXME: Brown has dist(3) and dist(4) swapped around. I based this code on
% Juan's implementation.

xu = reprow(dr,2).*x + [dtx;dty];
