function varargout = array_unpack(arr)
% Unpack the array elemenets into named variables.
if nargout < length(arr)
    warning('Some array elements not assigned')
end
for i = 1:nargout
    varargout{i} = arr(i);
end
