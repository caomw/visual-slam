function im = flip_image(im, flip)
% flip is a string composed of the letters: t, r, u, and l
% eg., flip = 'tu';
%
% Notes: These operations are redundant: eg.,
%   - 'r' rotates the image anticlockwise 90 degrees
%   - so does 'lt' or 'tu'
%   - 'tl' or 'ut' rotates the image clockwise 90 degrees
%   - 'lu' and 'ul' rotates 180 degrees

R = im(:,:,1); 
G = im(:,:,2); 
B = im(:,:,3); 

for i = 1:length(flip)
    switch flip(i)
        case 't'
            R = R'; G = G'; B = B'; 
        case 'r'
            R = rot90(R); G = rot90(G); B = rot90(B); 
        case 'u'
            R = flipud(R); G = flipud(G); B = flipud(B); 
        case 'l'
            R = fliplr(R); G = fliplr(G); B = fliplr(B); 
        otherwise 
            error('Invalid type')
    end
end

im = cat(3, R, G, B);
