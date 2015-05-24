function fid = estimator_detect_numerically_unstable_features(Y, Nc, fmap, fid, maxval)
%
% The values of y or diag(Y) indicate potential numerical instability and
% ill-conditioning. Could potentially do this detection with H...

if nargin == 4, maxval = 1e9; end

ii = estimator_index2state(fmap(fid), 3, 6*Nc);
Yi = Y(ii,ii); % block-diagonal
% alternatively, could use abs(y(ii))

% Simple heuristic, consider only the magnitude of diagonal terms
Yd = zeros(3, length(fid));
Yd(:) = full(diag(Yi));
fid = fid(max(Yd) > maxval);
