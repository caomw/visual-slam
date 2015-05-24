function image_correction_ideas(im)
% Things to test: intensity normalise, colour normalise or correction
% (perhaps to a selected patch in a scene),  

% Option 1: gray-scale image
%   - remove/ignore pixels with intensity > T
%   - equalise histogram: histeq, adapthisteq

% Option 2:
%   - adjust histogram to enhance contrast
