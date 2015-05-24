function p = patch_transform_evaluate(im, origin, x, xgrid, ygrid)
% NOTE: does not account for m00 or m11 being outside of image bounds; it
% will trigger an error; must ensure image is bounding

if isempty(origin), origin = [0;0]; end % default origin is top-left of image

% Transform grid
mg = transform_to_global([xgrid(:) ygrid(:)]', x);
mg(1,:) = mg(1,:) + origin(1); % account for offset image origin 
mg(2,:) = mg(2,:) + origin(2);

% Get surrounding pixel locations (for bilinear interpolation)
m00 = floor(mg);
m11 = ceil(mg);
dx = mg(1,:) - m00(1,:);
dy = mg(2,:) - m00(2,:);

% Indices for sampling image
[M,N,D] = size(im);
i00 = index_table_([M,N], [m00(2,:); m00(1,:)]); % note image indices are im(y,x)
i11 = index_table_([M,N], [m11(2,:); m11(1,:)]);
i01 = index_table_([M,N], [m11(2,:); m00(1,:)]);
i10 = index_table_([M,N], [m00(2,:); m11(1,:)]);

% Bilinear interpolation 
pd = zeros(size(xgrid));
for i = 1:D
    imd = double(im(:,:,i));
    f00 = imd(i00);
    f11 = imd(i11);
    f01 = imd(i01);
    f10 = imd(i10);
    pd(:) = f00 + dx.*(f10-f00) + dy.*(f01-f00) + dx.*dy.*(f00+f11-f10-f01);
    p(:,:,i) = pd;
end
