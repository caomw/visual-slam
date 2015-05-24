function [y, Y, fcount, info] = estimator_compute_information_sanity_check(z, R, K, xs, flags)

K = K(1:2,:);
fmap = cumsum(flags);
fcount = zeros(size(flags));

Nc = length(z);
Nf = fmap(end);
N = 6*Nc + 3*Nf;
assert(length(xs) == N)

y = zeros(N,1);
Y = zeros(N);

k = 0;
for i = 1:length(z)
    zi = z(i);
    
    for j = 1:length(zi.fid)
        fid = zi.fid(j);
        if flags(fid) == 0, continue, end
        
        [~, ~, ii] = estimator_index_observation2state(i, fid, Nc, fmap);        
        [Hs, zs] = numerical_jacobian_i(@obs_model, [], 1, [], xs(ii), K);    
        
        v = zi.z(:,j) - zs;
        HtRi = Hs'/R;     
     
        k = k + 1;
        info(k).Y = force_symmetry(HtRi*Hs);
        info(k).y = HtRi * (v + Hs*xs(ii));
        info(k).cid = i;
        info(k).fid = fid;
        
        Y(ii,ii) = Y(ii,ii) + info(k).Y;
        y(ii) = y(ii) + info(k).y;
        fcount(fid) = fcount(fid) + 1;
    end    
end

%
%

function z = obs_model(x, K)
z = model_observation(x(1:6), x(7:9), K);
