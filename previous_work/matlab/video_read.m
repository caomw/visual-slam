function [im, rows, cols] = video_read(fname)

if nargin ~= 0
    assert(nargout == 0, 'No return parameter when initialising video')    
    mex_video_read(fname);
    if ~isempty(fname)
        fprintf('Warning: You must explicitly release video before calling ''clear'', else Matlab will hang.\n');
    end
elseif nargout == 0
    mex_video_read(''); % release
else
    [im, rows, cols] = mex_video_read;
    if nargout == 1
        im = im_raw2rgb(im, rows, cols);
    end
end

% Note: Due to unknown destruction order issues with OpenCV's video
% cleanup, we cannot perform automatic destruction on 'clear'. Attempting
% to do so will cause Matlab to hang. Instead, you must release the video
% by either: 
%   (i) reading through all image frames, or
%   (ii) calling >> video_read or >> video_read('')
%
% A revision of the mex-function may be able to fix this by modifying the
% destructor of VideoCapture so it doesn't call release() after the video
% stream has been cleaned-up. Or I could allocate VideoCapture via new and
% not release it, but then we have a memory leak.
