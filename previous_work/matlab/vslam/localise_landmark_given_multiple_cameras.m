function xf = localise_landmark_given_multiple_cameras(pixs, xc, xf, Kinv, N, outlier)
% Get an estimate of a single landmark as seen from multiple known camera locations
if nargin < 5, N = 5; end

M = size(pixs, 2);
im = Kinv*[pixs; ones(1,M)];

if all(xf==0)
    % RANSAC-like trials to minimise mean innovation
    Nr = 10;
    [ii, Nr] = integer_pair_combinations(M, Nr);
    errbest = inf;   
    for i = 1:Nr
        xfi = localise_landmark_given_cameras_ij(pixs, xc, ii(1,i), ii(2,i), Kinv);
        r = compute_residuals(im, xfi, xc, M);
        err = mean(r);
        if err < errbest
            errbest = err;
            xf = xfi;
        end
    end
end

% Residual based outlier removal
if nargin == 6 && outlier 
    r = compute_residuals(im, xf, xc, M);
    ii = find(r <= median(r)); % FIXME: Use mean or median?
    im = im(:, ii);
    xc = xc(:, ii);
    M = length(ii);
end

% Iterated LS
H = zeros(2*M, 3);
zpred = zeros(2*M, 1);
for i = 1:N
    % FIXME: MAXXF is a hack to prevent failure of numerical jacobians; fix
    % problem by using analytical jacobians 
    MAXXF = 1e4; if any(abs(xf) > MAXXF), xf = xf * (MAXXF/max(abs(xf))); end
    for j = 1:M
        ii = (1:2) + 2*j - 2;
        [H(ii,:), zpred(ii)] = numerical_jacobian_i(@model_observation, [], 2, [], xc(:,j), xf);
    end
    v = im(:) - zpred + H*xf; % note, this is not the innovation, which is just im(:) - zpred
    xf = (H'*H)\(H'*v);
    % FIXME: perhaps fix chiralty here (maybe just partially, force in front of at least one non-outlier camera)
end

%
%

function r = compute_residuals(im, xf, xc, M)
zs = im;
for i = 1:M
    zs(:,i) = model_observation(xc(:,i), xf);
end
v = im - zs;
r = sum(v.*v);
% Note: This simplified compute_residuals is possible because we assume
% {xc,xf} are perfect, and R=I. So, S=R=I.
