function [left, right, t, N] = bumblebee_imread_sequence(i, impath)
% Note, these images are NOT rectified. To do this, see the code in
% bumblebee_imread.m
persistent P FL FR
if nargin == 2
    P = impath;
    FL = ls([P '/*.left.png']);
    FR = ls([P '/*.right.png']);
    check_sequence(FL, FR);
end

N = size(FL,1);
if i > N
    t = []; left = []; right = [];
    return
end

[~, t] = get_timestamp(FL(i,:));
left = imread([P '/' FL(i,:)]);
right = imread([P '/' FR(i,:)]);

%
%

function [t1, t2] = get_timestamp(fn)
it = find(fn == 'T');
id = find(fn == '.');
assert(length(id) == 3);
t1 = str2double(fn(1:(it-1)));
t2 = str2double(fn((it+1):(id(2)-1)));

function check_sequence(FL, FR)
[t1, t2] = get_timestamp(FL(1,:));
for i = 2:size(FL,1)
    [t1L, t2L] = get_timestamp(FL(i,:));
    [t1R, t2R] = get_timestamp(FR(i,:));
    assert(t1L == t1 && t1L == t1R);
    assert(t2L > t2 && t2L == t2R);
    t2 = t2L;
end
