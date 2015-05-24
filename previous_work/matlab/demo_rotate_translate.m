function demo_rotate_translate(type)

if type == 1
% mostly y-axis rotate
figure
video_read('myvideo/P1000431.mp4')
for i = 1:83, leftim = video_read; imshow(leftim); drawnow, end
for i = 1:35, rightim = video_read; imshow(rightim); drawnow, end
close
demo_feature_matching(leftim, rightim);

% mostly translate and yaw (z-axis rotate)
elseif type == 2
figure
video_read('myvideo/P1000432.mp4')
for i = 1:50, leftim = video_read; imshow(leftim); drawnow, end
for i = 1:100, rightim = video_read; imshow(rightim); drawnow, end
close
demo_feature_matching(leftim, rightim);
 
% mostly translate
elseif type == 3
figure
video_read('myvideo/P1000432.mp4')
for i = 1:40, leftim = video_read; imshow(leftim); drawnow, end
for i = 1:50, rightim = video_read; imshow(rightim); drawnow, end
close
demo_feature_matching(leftim, rightim);
end

video_read
