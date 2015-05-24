function fid = estimator_detect_very_uncertain_features(Y, Nc, fmap, fid, maxvar)
%
% A cheap way to determine whether features have very uncertain depth is to
% condition on the camera poses (which makes the feature estimates
% independent).
%
% Need to call this function after:
%   - initialising a feature (augmenting the state)
%   - removing a feature
if nargin == 4, maxvar = 100; end % default std-dev of 10 metres

ii = estimator_index2state(fmap(fid), 3, 6*Nc);

% Note, Y(ii,ii) is block-diagonal, and we can treat each block separately.
% However, it is an error to treat just the diagonal terms. We can do this
% with P and still have a good approximation, but with Y we get completely
% wrong results.

N = size(ii, 2);
var = zeros(1, N);
for i = 1:N
    j = ii(:,i);
    P = inv(full(Y(j,j)));
    var(i) = max(eig(P));
    %var(i) = max(diag(P)); % an efficient alternative
end

fid = fid(var > maxvar);
