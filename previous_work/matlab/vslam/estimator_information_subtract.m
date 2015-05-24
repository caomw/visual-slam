function [y, Y, xs, fcount, sw, converged] = estimator_information_subtract(y, Y, ...
    xs, Nc, fcount, info, infoaddr, sw, R, K, options)

% Compute moments
x = full(Y\y); 
P = full(inv(Y)); 

% Gate residuals of observations currently ON
on = find(sw == 1);
r = estimator_compute_residuals(x, P, xs, Nc, fcount, info(on), R, K);
rmax = max(r);
gate = rmax * options.gateratio;
if gate < options.gateresid, gate = options.gateresid; end % limit min gate

if options.verbose ~= 0
    disp(['Max residual: ' num2str(rmax) ', Gate: ' num2str(gate)])
end

% Algorithm has convergenced when all ON observations have residuals less than gate
converged = true;
if rmax < gate, return, end
converged = false;

% Determine observations to turn OFF due to gate
off = on(r > gate);
assert(isempty(off)==false, 'To get here, we must be turning OFF at least one observation')

% Turn OFF observation information
sw(off) = 0;
[yoff, Yoff, fcoff] = estimator_accumulate_information(info(off), Nc, fcount);
Y = Y - Yoff;    
y = y - yoff;

% Update fcount
flags = fcount ~= 0; % need to record original flags, since some fcount may become zero
fcount = fcount - fcoff;
fid = unique([info(off).fid]);
assert(all(fcount(fid) >= 0), 'Cannot turn OFF more observations that were originally ON')

% Find any features that have 0 or 1 observations (ie., are indeterminant)
fid1 = fid(fcount(fid) < 2); % get just the fid's with fcount<2

% Find any features whose range has become uncertain 
fid2 = fid(fcount(fid) >= 2); % get remaining fid's that have been altered above 
fid2 = estimator_detect_very_uncertain_features(Y, Nc, cumsum(flags), fid2);

% Remove marked features
[y, Y, xs, fcount, sw] = estimator_remove_features_from_state(y, Y, xs, ...
    Nc, fcount, flags, info, infoaddr, sw, [fid1 fid2]);

if options.verbose ~= 0
    disp(['Switched OFF: ' num2str(length(off)) ', Totals: ' ...
        num2str(sum(sw==1)) ' on, ' num2str(sum(sw==0)) ' off, ' num2str(sum(sw==-1)) ' disabled'])
end
