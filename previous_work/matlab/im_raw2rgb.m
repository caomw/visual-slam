function rgb = im_raw2rgb(im, rows, cols)
R = uint8(zeros(cols, rows)); G = R; B = R;
B(:) = im(1:3:end); % note, OpenCV default colour order is BGR
G(:) = im(2:3:end);
R(:) = im(3:3:end);
rgb = cat(3, R', G', B');
