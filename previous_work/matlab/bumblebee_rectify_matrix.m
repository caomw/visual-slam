function [mapx, mapy] = bumblebee_rectify_matrix(fname, imsize)
% Get the ACFR camera calibration matrices from binary file.
fid = fopen(fname);
data = fread(fid, 'float');
fclose(fid);

if nargin == 1 % For if we want column array format, which we do for mex_remap
    N = length(data)/2;
    mapx = data(1:N);
    mapy = data((N+1):end);

else % Only for if we want actual matrix format, which we do for a Matlab remap
    s = size(imsize);
    if max(s) == 2, s = imsize; end
    mapx = zeros(s(1:2))'; % transpose because data file is row-major
    mapy = mapx;
    N = length(data)/2;
    mapx(:) = data(1:N);
    mapy(:) = data((N+1):end);
    mapx = mapx'; % transpose result 
    mapy = mapy';
end
