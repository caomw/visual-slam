function [K, distort, pixerr, offset, trans] = bumblebee_configfile(fname, lrc)
% eg: [K, distort, offset] = bumblebee_configfile('shrimp_data/bumblebee.config', 'left')
lines = get_block(fname, lrc);

offset = parse_line(lines, 'offset'); % x,y,z,r,p,y ??
f = parse_line(lines, 'focal-length');
c = parse_line(lines, 'centre');
distort = parse_line(lines, 'distortion'); % k1,k2,p1,p2,k3
pixerr = parse_line(lines, 'pixel-error');
trans = parse_line(lines, 'translation');

K = [f(1) 0   c(1);
      0  f(2) c(2);
      0   0    1];

%
%

function lines = get_block(fname, lrc)
fid = fopen(fname);
k = 0; 
while 1
    lne = fgetl(fid);
    if ~ischar(lne), break, end
    if k > 0
        lines{k} = lne;
        if ~isempty(strfind(lne, '}')), break, end
        k = k + 1;        
    elseif ~isempty(strfind(lne, lrc))
        k = 1; 
    end
end
fclose(fid);

%

function vals = parse_line(lines, id)
found = false;
for i = 1:length(lines)
    lne = lines{i};
    k = strfind(lne, id);
    if ~isempty(k) && lne(k + length(id)) == '='
        found = true; 
        break
    end
end
assert(found, 'Identifier must exist in file')
k = strfind(lne, '"') + [1 -1]; % index of values between the double quotes
vals = str2num(lne(k(1):k(2)));
