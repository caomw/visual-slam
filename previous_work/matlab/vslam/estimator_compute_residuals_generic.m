function r = estimator_compute_residuals_generic(model, norm, x, P, z, R, i, varargin)

[H, zs] = numerical_jacobian_i(model, norm, i, [], varargin{:});
zpred = zs + H*(x - varargin{i}); % xs = varargin{i}
v = z(:,i) - zpred;
S = H*P*H' + R;
r = v'*(S\v);
