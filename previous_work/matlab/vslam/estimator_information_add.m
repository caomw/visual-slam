function [y, Y, fcount, sw] = estimator_information_add(y, Y, xs, Nc, fcount, info, sw, R, K, options)
% Innovation gating to determine the addition of observations to the state

% Compute moments
x = full(Y\y); 
P = full(inv(Y)); 

% Compute innovations and gate to turn observations ON
off = find(sw == 0); % compute innovations (of OFF observations)
r = estimator_compute_residuals(x, P, xs, Nc, fcount, info(off), R, K);
on = off(r < options.gateinnov); % turn acceptable constraints ON

% Update state
if ~isempty(on)
    sw(on) = 1;
    
    [yon, Yon, fcon] = estimator_accumulate_information(info(on), Nc, fcount);
    Y = Y + Yon;    
    y = y + yon;
    fcount = fcount + fcon;
end

if options.verbose ~= 0
    disp(['Switched ON: ' num2str(length(on)) ', Totals: ' ...
        num2str(sum(sw==1)) ' on, ' num2str(sum(sw==0)) ' off, ' num2str(sum(sw==-1)) ' disabled'])
end
