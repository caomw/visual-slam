function demo_features(type, im)

if nargin == 1
    video_read('myvideo/P1000387.mp4')
    for i = 1:50, im = video_read; end
    video_read
end
imgr = im2single(rgb2gray(im));

switch type
    case 1
        % vl_sift
        pthresh = 0.02;
        [fa,da] = vl_sift(imgr, 'PeakThresh', pthresh);
        figure
        imagesc(im)
        axis image off
        hold on
        vl_plotframe(fa);
        
    case 2
        % vl_harris
        si = 2;
        sd = 0;
        imh = double(imgr);
        if sd > 0
            imh = vl_imsmooth(imh, sd);
        end
        [H,details] = vl_harris(imh, si);
        figure, imshow(uint8(H*255/max(H(:))))
        
        idx = vl_localmax(H) ;
        [i,j] = ind2sub(size(imh), idx);
        figure
        imagesc(im)
        axis image off
        hold on
        vl_plotframe([j;i]);
        
    case 3
        [c_coord] = torr_charris(im, ncorners, width, sigma, subpixel)
end
