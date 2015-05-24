function [y, Y, fcount] = estimator_accumulate_information_slow(info, Nc, flags)
% Just a sanity check of estimator_accumulate_information.m

fmap = cumsum(flags);
Nf = fmap(end);
N = 6*Nc + 3*Nf;
y = zeros(N,1);
Y = zeros(N);
fcount = zeros(size(flags));

for i = 1:length(info)
    infi = info(i);
    [~, ~, idx] = estimator_index_observation2state(infi.cid, infi.fid, Nc, fmap);
    
    Yi = [infi.Yc infi.Ycf; infi.Ycf' infi.Yf];
    
    y(idx) = y(idx) + infi.y;
    Y(idx,idx) = Y(idx,idx) + Yi;
    fcount(infi.fid) = fcount(infi.fid) + 1;
end
