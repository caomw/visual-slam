function [i, N] = integer_pair_combinations(M, N)
% Compute a combination of N unique pairs of integers in [1 M]. If there
% are less than N unique combinations, reduce N to all combinations. If
% there are too many unique combinations, return a random subset of all 
% combinations.

i = combnk(1:M, 2)'; % all combinations of M choose 2

Nc = size(i,2);
if Nc < N
    N = Nc; 
elseif Nc > N
    [~,ii] = sort(rand(1,Nc)); % FIXME: Knuth's shuffle algorithm is faster
    i = i(:, ii(1:N));
end
