function write_matrix(Y, file)
% Y is our information matrix

L = chol(Y, 'lower');
Li = inv(L);
P = Li'*Li;
L = sparse(L);
[i,j,s] = find(L);

fid = fopen(file, 'w');

fprintf(fid, '%d %d\n', size(Y,1), length(i));
for a=1:length(i)
    fprintf(fid, '%d %d %2.10f\n', i(a)-1, j(a)-1, s(a));
end
fprintf(fid, '\n');

for a=1:size(P,1)
    for b=1:size(P,2)
        fprintf(fid, '%2.10f ', P(a,b));
    end
    fprintf(fid, '\n');    
end


fclose(fid);
