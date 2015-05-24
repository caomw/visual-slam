function imp = patch_pad(im, x, y)
% Pad image patch with border of (x,y) zeros to facilitate
% cross-correlation. Shifted image origin is [org(1)+x; org(2)+y]
if nargin == 2, y = x; end
[M,N,D] = size(im);
imp = zeros(M+2*y, N+2*x, D, class(im));
imp(y+(1:M), x+(1:N), :) = im;
%imshow(imp)
