function x = patch_align(im1, im2, x0, type)
% It is assumed that (i) im1 and im2 are centre-origin, and (ii) im2 is
% inflated to allow for transforms (ie., sufficiently bigger than im1).

xr = (size(im1,1)-1)/2;
yr = (size(im1,2)-1)/2;
[X, Y] = meshgrid(-xr:xr, -yr:yr);
org2 = size(im2)/2 + 0.5;

if type < 3
    [x, fval, flag, out] = fminunc(@patch_difference, x0, [], im1, im2, org2, X, Y, type);

else    
    x = x0;
    K = [10, 50]; % angle scaling
    O = [2, 0.5]; % jacobian offset
    N = [10, 10]; % number of iterations
    for i = 1:length(K)
        [x, fval] = gauss_newton_search(x, im1, im2, org2, X, Y, K(i), O(i), N(i));
    end
end

%
%

function [xbest, rbest] = gauss_newton_search(x, im1, im2, org2, X, Y, K, offset, N)
x(3) = x(3)*K; % angle inflation to improve Jacobian scaling
rbest = 9e9;
for i = 1:N
    err = patch_diff(x, im1, im2, org2, X, Y, K);
    H = numerical_jacobian_i(@patch_diff, [], 1, offset, x, im1, im2, org2, X, Y, K);
    YY = H'*H;
    yy = H'*(H*x - err);
    x = YY\yy;
    err = patch_diff(x, im1, im2, org2, X, Y, K);
    res = log(sum(err.^2));    
    if res < rbest, rbest = res; xbest = x; end
end
xbest(3) = xbest(3)/K; % reverse angle inflation

%

function err = patch_diff(x, im1, im2, org2, gridx, gridy, K)
x(3) = x(3)/K; % reverse angle inflation
im2t = patch_transform_evaluate(im2, org2, x, gridx, gridy);
imshow(uint8(im2t)), drawnow
if 1 % Normalise by average intensity
    im1 = im1 - mean(im1(:));
    im2t = im2t - mean(im2t(:));
end
err = im1(:) - im2t(:);
