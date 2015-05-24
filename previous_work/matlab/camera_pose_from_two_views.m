function xc = camera_pose_from_two_views(im1, im2, xc)
% FIXME: Unfinished, in progress
% im1 and im2 are matched pairs of [x/z, y/z] image plane points.
% xc is for linearisation only.

global USELOGZ


function x = init_feature_position(im1, im2, xr, Rr)
% Feature position state: x = [im1x, im1y, z1]
global USELOGZ
r1im = sqrt(sum(im1.^2) + 1); % rim^2 = xim^2 + yim^2 + 1
r1 = distance2lines(im1, im2, xr, Rr);
z1 = r1 ./ r1im;
if ~USELOGZ, z1 = log(abs(z1)); end 
x = [im1; z1];
x = x(:);

function [y,Y] = canonical_information(obsmodel, z, R, i, varargin) 
H = numerical_jacobian_i(obsmodel, [], i, [], varargin);
HtRi = H'/R;
Y = force_symmetry(HtRi*H);
zs = feval(obsmodel, varargin{:});
y = HtRi * (z - zs + H*varargin{i});

function z = image_plane_obsmodel(xc, xf)
R = a2R(xc(4:6));
xr = R'*(xf - xc(1:3));
z = xr(1:2,:)./xr(3,:);

function x = state_to_position(x)
z = exp(x(3:3:end));
x(1:3:end) = x(1:3:end) .* z;
x(2:3:end) = x(2:3:end) .* z;
x(3:3:end) = z;

function xc = ls_features_marginalised(im1, im2, xc)
Rp = [1 0; 0 1]*1;% pixel uncertainty (in pixels^2)
xf = init_feature_position(im1, im2, xc(1:3), a2R(xc(4:6)));
xs = [xc; xf(:)];
N = length(xs);
y = zeros(N, 1);
Y = zeros(N, N);
Y(1,1) = 1e4; % make xc(1) the baseline
y(1) = Y(1,1)*xs(1);
M = size(im1,2);
for i = 1:M 
    % Observe im1
    ii = (1:3) + i*3 + 3;
    [yi, Yi] = canonical_information(@image_plane_obsmodel, im1(:,i), Rp, 2, zeros(6,1), xs(ii));
    y(ii) = y(ii) + yi;
    Y(ii,ii) = Y(ii,ii) + Yi;
    % Observe im2
    [yi, Yi] = canonical_information(@image_plane_obsmodel, im2(:,i), Rp, [1 2], xs(1:6), xs(ii));
    y(ii) = y(ii) + yi;
    Y(ii,ii) = Y(ii,ii) + Yi;
end
x = full(sparse(Y)\y);


