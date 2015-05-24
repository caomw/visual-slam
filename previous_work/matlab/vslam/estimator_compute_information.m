function [info, infoaddr] = estimator_compute_information(z, R, K, xs)
% z - an array of structures containing observations; each structure
% contains the observation set for one camera image, and is composed of
% two arrays {z, fid}
% R - the observation uncertainty, assumed common to all z
% K - (2x3) pixel to image-plane projection-ratio 
% xs - linearisation for [xc1, xc2, ..., f1, f2, ...]
% info - {y,Y,cid,fid,z}
% infoaddr - lookup for location of observations given fid

Nfcount = zeros(1, max([z.fid]));
Nc = length(z);
k = 0;

for i = 1:Nc
    zi = z(i);
    [idxc, idxf] = estimator_index_observation2state(i, zi.fid, Nc);
    xc = xs(idxc);
    xf = xs(idxf);
    [Hsc, zs] = numerical_jacobian_i(@model_observation, [], 1, [], xc, xf, K);    
    %[Hsf, zs] = numerical_jacobian_i(@model_observation, [], 2, [], xc, xf, K);
    
    for j = 1:length(zi.fid)
        Hsf = numerical_jacobian_i(@model_observation, [], 2, [], xc, xf(:,j), K);
        ii = (1:2) + 2*j - 2;
[Hsc(ii,:), zs(ii)] = numerical_jacobian_i(@model_observation, [], 1, [], xc, xf(:,j), K);
% FIXME: What is the cause of the difference in Hsc calculation??
        Hs = [Hsc(ii,:) Hsf];
        xsj = [xc; xf(:,j)];
        
        v = zi.z(:,j) - zs(ii);
        HtRi = Hs'/R;       
        Y = force_symmetry(HtRi*Hs);
        y = HtRi * (v + Hs*xsj); % note, Hs*xsj == Hsc(ii,:)*xc + Hsf*xf(:,j)
        
        fidj = zi.fid(j);
        Nfcount(fidj) = Nfcount(fidj) + 1;

        k = k + 1;
        info(k).y = y;
        info(k).Yc  = Y(1:6,1:6); % camera block-diag
        info(k).Yf  = Y(7:9,7:9); % feature block-diag
        info(k).Ycf = Y(1:6,7:9); % camera-feature off-diag
        info(k).z = zi.z(:,j);
        info(k).cid = i;
        info(k).fid = fidj;    
    end
end

% Lookup data-structure for fast search of info
infoaddr.start = [0 cumsum(Nfcount)];
infoaddr.idx = zeros(1, k);
Nfcount(:) = 0;
for i = 1:k
    fid = info(i).fid;
    Nfcount(fid) = Nfcount(fid) + 1;
    ii = infoaddr.start(fid) + Nfcount(fid);
    assert(ii <= infoaddr.start(fid+1), 'Indices must remain within limits')
    infoaddr.idx(ii) = i;
end
