function z = model_observation(xc, xf, K)
% If include K (2x3) then output is pixels

N = size(xf,2);

R = a2R(xc(4:6));
xr = R'*(xf - repcol(xc(1:3), N));
z = xr(1:2,:)./reprow(xr(3,:),2); % FIXME: check for divide-by-zero
if nargin == 3
    z = K*[z; ones(1,N)];
end

z = z(:);
