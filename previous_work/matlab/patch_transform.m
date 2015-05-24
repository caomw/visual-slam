function [pt, orgnew] = patch_transform(p, origin, x)
% FIXME: Currently broken...
[M,N,D] = size(p);

% Get extent of new patch boundaries
xb1 = [1 M] - origin(1); % original axis aligned bounds 
yb1 = [1 N] - origin(2);
xg = transform_to_global([xb1([1 1 2 2]); yb1([1 2 2 1])], x);
minp = floor(min(xg, [], 2));
maxp = ceil(max(xg, [], 2));
xb2 = [minp(1) maxp(1)]; % transformed patch axis aligned bounds 
yb2 = [minp(2) maxp(2)];

% Determine padding of original image
xr = transform_to_relative([0;0;0], x);
xpad = transform_to_global([xb2([1 1 2 2]); yb2([1 2 2 1])], xr);
dpad = ceil((max(xpad, [], 2) - min(xpad, [], 2) - [M;N])/2);
pp = patch_pad(p, dpad(1), dpad(2));
orgp = origin + dpad;
if 1
    xb3 = [1 size(pp,1)] - orgp(1); % padded image axis aligned bounds 
    yb3 = [1 size(pp,2)] - orgp(2);
    plot(xb1([1 1 2 2 1]), yb1([1 2 2 1 1]), [xg(1,:) xg(1,1)], [xg(2,:) xg(2,1)], ...
        xb2([1 1 2 2 1]), yb2([1 2 2 1 1]), [xpad(1,:) xpad(1,1)], [xpad(2,:) xpad(2,1)], ...
        xb3([1 1 2 2 1]), yb3([1 2 2 1 1]))
    axis equal
    legend('original','transformed','bound1','transback','bound2')
end

% Compute patch values
xp = minp(1):maxp(1);
yp = minp(2):maxp(2);
[X, Y] = meshgrid(xp, yp);
pt = patch_transform_evaluate(pp, orgp, xr, X, Y);
