function analytical_jacobians()
% FIXME: Incomplete
%Attempt to get analytical jacobians for bearing only obs-models

syms f x0 y0 x y z e1 e2 e3 a b c
K = [f 0 x0; 
     0 f y0];
xc = [x; y; z];
ac = [e1; e2; e3];
xf = [a; b; c];

f = obsmodel2(xc, ac, xf, K);
Hcx = diff(f, x);

%

function im = obsmodel2(xc, ac, xf, K)
% Convert xf (xim,yim,logz) to image projection (xr/zr,yr/zr)
xf(3) = exp(xf(3));
im = obsmodel1(xc, ac, xf, K);

function im = obsmodel1(xc, ac, xf, K)
% Convert xf (xim,yim,z) to image projection (xr/zr,yr/zr)
z = xf(3);
x = xf(1) * z;
y = xf(2) * z;
R = euler2R(ac(1), ac(2), ac(3));
xr = R'*([x;y;z] - xc);
im = K*[xr(1:2)/xr(3); 1];

function R = euler2R(ex, ey, ez)
% [ cy*cz, sz*cx+sy*sx*cz, sz*sx-sy*cx*cz]
% [-cy*sz, cz*cx-sy*sx*sz, cz*sx+sy*cx*sz]
% [    sy,         -cy*sx,          cy*cx]
cx = cos(ex); cy = cos(ey); cz = cos(ez);
sx = sin(ex); sy = sin(ey); sz = sin(ez);
R = [cy*cz, sz*cx+sy*sx*cz, sz*sx-sy*cx*cz;
    -cy*sz, cz*cx-sy*sx*sz, cz*sx+sy*cx*sz;
        sy,         -cy*sx,          cy*cx];
    