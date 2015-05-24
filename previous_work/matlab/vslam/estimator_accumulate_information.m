function [y, Y, fcount] = estimator_accumulate_information(info, Nc, flags)
% Note: we convert to triplet-form and then to col-compressed form because
% Matlab does not provide a way to efficiently add to the col-compressed
% form directly. A C++ implementation could avoid this difficulty.
% Warning: there are magic numbers here, 3, 6, 9=3*3, 36=6*6, 18=3*6
map = cumsum(flags~=0); % mapping of features currently in state-vector
Ni = length(info);       % number of observations
Nf = map(end);           % number of features (turned ON)
N = 6*Nc + 3*Nf;         % total number of states
y = zeros(N, 1);         % information vector
Yc = zeros(36*Nc, 1);    % triplet-form block-diagonal terms for camera
Yf = zeros(9*Nf, 1);     % triplet-form block-diagonal terms for features
Ycf = zeros(18*Ni, 3);   % triplet-form off-diagonal terms
fcount = zeros(size(flags)); % count of feature observations in info

% Accumulate y, Yii, Yij
k = 1:18;
for i = 1:Ni
    infi = info(i);
    fcount(infi.fid) = fcount(infi.fid) + 1;
    
    % Index for state vector 
    fid = map(infi.fid);
    [iic, iif, idx] = estimator_index_observation2state(infi.cid, fid, Nc);
    
    % Info-vector is additive
    y(idx) = y(idx) + infi.y;
    
    % Info-matrix Block-diagonal terms are additive
    ii = estimator_index2state(infi.cid, 36, 0);
    Yc(ii) = Yc(ii) + infi.Yc(:);
    ii = estimator_index2state(fid, 9, 0);
    Yf(ii) = Yf(ii) + infi.Yf(:);
    
    % Off-diagonal terms are unique (a camera never sees the same feature twice)
    [ii,jj] = compute_off_diagonal_triplet_indices(iic, iif);
    Ycf(k,:) = [ii jj infi.Ycf(:)];
    k = k + 18;
end
assert(all(flags(fcount ~= 0)), 'Only active landmarks should accumulate information')

% Convert triplet form to column-compressed form
[i1, j1] = compute_block_diagonal_triplet_indices(Nc, 6);
[i2, j2] = compute_block_diagonal_triplet_indices(Nf, 3);
i2 = i2 + 6*Nc; % offset feature indices to below the camera block
j2 = j2 + 6*Nc;
Yc = sparse(i1, j1, Yc, N, N); 
Yf = sparse(i2, j2, Yf, N, N); 
Ycf = sparse(Ycf(:,1), Ycf(:,2), Ycf(:,3), N, N); 
Y = Yc + Yf + Ycf + Ycf';

%
%

function [i, j] = compute_block_diagonal_triplet_indices(N, D)
% Compute indices of the triplet-form block-diagonal terms
ND = N*D;
i = zeros(D, N); 
i(:) = 1:ND; 
i = repmat(i, D, 1); i = i(:);
j = reprow(1:ND, D); j = j(:);

function [i, j] = compute_off_diagonal_triplet_indices(iic, iif)
% Get off-diagonal block of Y represented in triplet form
rows = reprow(1:6, 3)';
cols = reprow(1:3, 6);
i = rows(:) + iic(1) - 1;
j = cols(:) + iif(1) - 1;
