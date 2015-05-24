function [r1, r2, D] = distance2lines(im1, im2, xr, Rr, doplot)
% im1 and im2 matched pairs of are normalised image coordinates [x/z; y/z] 
% xr,Rr is the relative pose of camera2 to camera1
% Line distance formula based on Schneider & Eberly pp 409-412. 
if nargin == 4, doplot = 0; end

% Convert from image coordinates to point/direction form expected by Schneider
z = ones(1, size(im1,2));
v1 = [im1; z];
v2 = Rr * [im2; z]; % rotate v2 according to rotation of camera 2

% Distance formula based on Schneider pp 409-412.
a = sum(v1.*v1); % use this form of inner product for (3xN) to (3xN)
b = sum(v1.*v2); 
c = sum(v2.*v2);
d = xr'*v1;      % use this form of inner product for (3x1) to (3xN)
e = xr'*v2;
f = xr'*xr;

denom = a.*c - b.*b;
denom(denom < 1e-12) = 1; % account for parallel lines, see note (5) below

s = (c.*d - b.*e) ./ denom;
t = (b.*d - a.*e) ./ denom; 
D = f + s.*(a.*s - b.*t - 2*d) + t.*(c.*t - b.*s + 2*e); 

% Compute lines lengths
r1 = sqrt(a).*s;
r2 = sqrt(b).*t;

% Notes:
%   1. Calculation of (b) is according to the code (p411), not the
%   equation (p410); it is the negative of the equation. 
%`  2. (d,e) are negative of the Schneider formulae (xr=P1-P0, not P0-P1).
%   3. (s,t) signs are changed to account for change in (d,e). Also, the
%   equation for t (p411) is wrong; the code (p412) is correct.
%   4. (D) is incorrect in the code (p412), see the errata on the book's
%   website. Our formula is different again due to the change in (d,e).
%   5. In theory, parallel lines meet at infinity, but this is not useful
%   numerically. In practice, any arbitrary range will do, and we choose to
%   just set denom = 1.

% Plot results
if doplot
    p1 = reprow(s,3).*v1;
    p2 = reprow(t,3).*v2 + repcol(xr, size(im1,2));
    figure, plot3(p1(1,:),p1(2,:),p1(3,:),'.', p2(1,:),p2(2,:),p2(3,:),'.', ...
        0,0,0,'b*', xr(1),xr(2),xr(3),'*')
    axis equal
    D2 = dist_sqr_(p1, p2);
    figure, plot(D), hold on, plot(D2,'r:'), hold off
end
