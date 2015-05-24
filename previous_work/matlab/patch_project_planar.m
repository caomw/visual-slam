function imp = patch_project_planar(im, x, R)
% Three projection methods: 
%   (i) for each pixel in im, compute its location in imp
%   (ii) for each pixel in imp, compute the value in im
%   (iii) project imp as per (ii), spread out over for nearest pixels
%   according to proportion of overlapping square area
