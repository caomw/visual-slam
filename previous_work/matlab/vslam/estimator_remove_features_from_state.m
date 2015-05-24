function [y, Y, xs, fcount, sw] = estimator_remove_features_from_state(y, Y, ...
    xs, Nc, fcount, flags, info, infoaddr, sw, fid)
% Subtract all observation information of feature, and disable these observations.

% Determine which observations are affected
total = []; off = [];
for i = 1:length(fid)
    ii = estimator_information_lookup(infoaddr, fid(i)); % set of all information for fid(i)
    total = [total ii];         
    offi = ii(sw(ii)==1);   % set of information currently ON
    off = [off offi];  
    assert(length(offi) == fcount(fid(i)), 'Should detect all ON observations')
end

% Subtract information from state; this disconnects features from camera poses
[yoff, Yoff] = estimator_accumulate_information(info(off), Nc, flags);
Y = Y - Yoff;    
y = y - yoff;

% Update ON observations counter
fcount(fid) = 0;

% Disable observations
assert(all(sw(total) ~= -1), 'Information cannot be already disabled')
sw(total) = -1;

% Remove features from state vector
%[~, idxf] = estimator_index_observation2state([], fid, Nc);
fmap = cumsum(flags);
idxf = estimator_index2state(fmap(fid), 3, 6*Nc);
% FIXME: check that all y(idxf), Y(idxf,idxf) are (almost exactly) zeros
idy = idx_other(idxf, length(y));
y = y(idy);
Y = Y(idy,idy);
xs = xs(idy);
