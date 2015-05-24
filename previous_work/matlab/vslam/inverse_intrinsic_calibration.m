function Kinv = inverse_intrinsic_calibration(K, square)
% 
if nargin == 1, square = false; end

type = 1;
switch type
    case 1
        if size(K,1) == 2, K = [K; [0 0 1]]; end
        Kinv = inv(K);
        if ~square, Kinv = Kinv(1:2,:); end
        
    case 2
        if size(K,1) == 3, K = K(1:2,:); end
        [fx, ~, s, fy, xo, yo] = array_unpack(K(:));
        Kinv = [1/fx, -s/(fx*fy), (s*yo - fy*xo)/(fx*fy);
                  0,     1/fy,       -yo/fy];        
        if square, Kinv = [Kinv; [0 0 1]]; end
end
