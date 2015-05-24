function r = estimator_compute_residuals(x, P, xs, Nc, fcount, info, R, K)
% Note, Assumes the same state-vector ordering as estimator_index_observation2state.m
assert(size(K,1) == 2, 'K must be (2x3)')

fmap = cumsum(fcount~=0); % mapping for features actually in the state
r = zeros(1, length(info));
for i = 1:length(info)
    infi = info(i);
    [~, ~, idx] = estimator_index_observation2state(infi.cid, infi.fid, Nc, fmap);
    [H, zs] = numerical_jacobian_i(@observe_model, [], 1, [], xs(idx), K);
    zpred = zs + H*(x(idx) - xs(idx)); 
    v = infi.z - zpred;
    S = H*P(idx,idx)*H' + R;
    r(i) = v'*(S\v);
end

%
%

function z = observe_model(x, K)
z = model_observation(x(1:6), x(7:9), K);
