function [xf, xf2, xfave] = localise_landmarks_given_two_cameras(pix1, pix2, xr, Rr, Kinv)
% Feature position state: xf = [x;y;z]

N = size(pix1,2);
z = ones(1, N);
im1 = Kinv*[pix1; z];
im2 = Kinv*[pix2; z];

[r1, r2] = distance2lines(im1, im2, xr, Rr);
r1im = sqrt(sum(im1.^2) + 1); % rim^2 = xim^2 + yim^2 + 1
z = r1 ./ r1im;               % r = z*rim
xf = [im1.*reprow(z,2); z];

if nargout > 1
    r2im = sqrt(sum(im2.^2) + 1);
    z2 = r2 ./ r2im;
    xf2 = [im2.*reprow(z2,2); z2];
    xf2 = Rr*xf2 + repcol(xr,N); % transform to global frame (ie, frame of im1)
    
    if nargout == 3
        xfave = (xf+xf2)/2;
    end
end

% Alternative locations for xf: 
%   (i)  point on line im1, 
%   (ii) point on line im2, 
%   (iii) average of the points on lines im1 and im2.
