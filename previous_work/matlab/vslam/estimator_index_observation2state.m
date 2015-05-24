function [idxc, idxf, idx] = estimator_index_observation2state(icam, ifeat, Nc, fmap)
% Convert a set of object indices to state indices
% icam - indices of cameras
% ifeat - indices of features
% Nc - total number of cameras, only required if isempty(ifeat)==false
% fmap - (optional) mapping of feature ID to its position in state vector.
%
% Note, given a vector of binary flags denoting which features are in the
% state vector, then
%       fmap = cumsum(flags);
%       i = fmap(fid);
% The reverse mapping -- to determine the original fid of feature i in the
% state vector -- is found as follows: 
%       imap = find(flags);
%       fid = imap(i);

idxc = estimator_index2state(icam, 6, 0);
if nargin == 4, ifeat = fmap(ifeat); end
idxf = estimator_index2state(ifeat, 3, 6*Nc);
idx = [idxc(:); idxf(:)];
