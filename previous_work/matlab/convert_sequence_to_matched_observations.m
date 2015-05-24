function z = convert_sequence_to_matched_observations(seqpath, seqfunc)
% Warning this code is a bit subtle. Be careful you understand it before
% trying to modify it.
if nargin == 1, seqfunc = @bumblefunc; end

pthresh = 0.02;

z(1).z = [];
z(1).idx = [];
z(1).fid = [];
fid = 0;

im = seqfunc(seqpath);
[f1,d1] = vl_sift(im, 'PeakThresh', pthresh);
while 1
    imnew = seqfunc();
    if isempty(imnew), break, end
    [f2,d2] = vl_sift(imnew, 'PeakThresh', pthresh);
    matches = vl_ubcmatch(d1, d2);
    do_plot(im, imnew, f1, f2, matches)
    im = imnew;
    
    % Find which features already have an fid, and which matches are new
    m1 = matches(1,:);
    [~, i1, i2] = intersect(z(end).idx, m1); % existing IDs
    inew = idx_other(i2, length(m1));        % new IDs
    fid = fid(end) + (1:length(inew));        
    
    % Add new features to frame 1
    z(end).z =   [z(end).z,    f1(1:2, m1(inew))];
    z(end).idx = [z(end).idx,  m1(inew)];
    z(end).fid = [z(end).fid,  fid];
    
    % Create frame 2
    m2 = matches(2, [i2 inew]);
    z2.z = f2(1:2, m2);
    z2.idx = m2;
    z2.fid = [z(end).fid(i1) fid];
    
    % Augment observation set
    z = [z z2];
    
    % Set up next iteration 
    f1 = f2;
    d1 = d2;
    fprintf('.')
end
fprintf('\n')

%
%

function im = bumblefunc(seqpath)
persistent COUNT
if nargin ~= 0
    COUNT=1; 
    bumblebee_imread_sequence(1, seqpath);
    if nargout == 0, return, end
end
im = bumblebee_imread_sequence(COUNT);
if ~isempty(im)
    im = im2single(rgb2gray(im));
    COUNT = COUNT + 1;
end

%
%

function do_plot(im1, im2, fa, fb, m)
% Plot results
imagesc(cat(2, im1, im2))
colormap('gray')
axis image off
hold on
fa = fa(1:2, m(1,:));
fb = fb(1:2, m(2,:));
h1 = line([fa(1,:); fb(1,:)], [fa(2,:); fb(2,:)]);
h2 = line([fa(1,:); fb(1,:)]+size(im1,2), [fa(2,:); fb(2,:)]);
set(h1,'linewidth', 1, 'color', 'r');
set(h2,'linewidth', 1, 'color', 'r');
vl_plotframe(fa);
vl_plotframe([fb(1,:)+size(im1,2); fb(2:end,:)]);
drawnow
hold off
