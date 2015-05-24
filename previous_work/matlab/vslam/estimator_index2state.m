function i = estimator_index2state(idx, D, offset)

N = length(idx);
if N == 0
    i = [];
elseif N == 1
    i = (1:D)' + D*idx - D + offset;
else
    i = reprow(1:D,N)' + D*reprow(idx,D) - D + offset;
end

% Note, output is (DxN). Be aware that to extract a submatrix using these
% indices together, there is no need to columnise them. That is:
%   Y(i(:),i(:)) - Y(i,i) == 0.
% Thus, the (DxN) form is very convenient, eg, j = i(:,[1 5]); Yj = Y(j,j);
