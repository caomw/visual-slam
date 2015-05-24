function xc = localise_camera_given_landmarks(xg, pix, K, xc, N, outliers)
% xg are global 3D points [x;y;z], pix are pixel observations of xg as
% taken from camera at xc [x;y;z;r;p;y]. The input xc is a linearisation
% parameter.  
if nargin < 5 || isempty(N), N = 5; end

% Median gate: Reject half of observations with largest residuals
if nargin == 6 && outliers 
    r = compute_residuals(pix, xc, xg, K);
    ii = find(r <= median(r));
    pix = pix(:, ii);
    xg = xg(:, ii);
end

% Iterated LS
for i = 1:N
    xs = xc;
    [H, zs] = numerical_jacobian_i(@model_observation, [], 1, [], xs, xg, K);
    v = pix(:) - zs + H*xs; % note, this is not the innovation, which is just im(:) - zs
    xc = (H'*H)\(H'*v);
    % Assuming R=I means our uncertainty is isotropic with 1-pixel std dev.
    % But the actual value of the variance makes no difference here.
end

%
%

function r = compute_residuals(pix, xc, xf, K)
zs = pix;
zs(:) = model_observation(xc, xf, K);
v = pix - zs;
r = sum(v.*v);
% Note: This simplified version of compute_residuals is possible because:
%   1. We have one camera xc, and multiple landmarks xf
%   2. We assume P is zero (ie, camera and xf known), so S = H*P*H' + R = R
%   3. We do not require residual magnitude, just an ordering, so we don't
%   need explicit R. Instead, we assume R = I such that uncertainty is
%   isotropic in pixels.
