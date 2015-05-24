function [y, Y, xs, fcount, info, sw] = estimator_initialise_new_landmarks(y, Y, xs, ...
            Nc, fcount, info, infoaddr, sw, R, K, options)
% For each fid currently not in state, do RANSAC initialise and add to
% state. 
% This gating strategy accounts for camera pose uncertainty.

% Compute moments for camera poses
x = full(Y\y); 
P = full(inv(Y)); 
ii = 1:6*Nc; % FIXME: clean up magic numbers
xc = x(ii);
Pc = P(ii,ii);

% Select non-intialised landmarks
fid = (fcount == 0); 

% Attempt initialisation
for i = 1:length(fid)
    ii = estimator_information_lookup(infoaddr, fid(i));
    [a, b, xf] = ransac_compatible_observations(xc, Pc, R, K, info(ii), options);
    
    % RANSAC to find compatible info.z and obtain new xs

    % Check for:
    %   compatible 
    %   very uncertain range in new landmarks
    %   very distant range

    % Modify info and sw
end

% Augment data structures
xs
y
Y

%
%

function [i, j, xf] = ransac_compatible_observations(xc, Pc, R, K, info, options)
[ii, Nr] = integer_pair_combinations(M, Nr);
errbest = inf;   
for i = 1:Nr
    xfi = localise_landmark_given_cameras_ij(pixs, xc, ii(1,i), ii(2,i), Kinv);
    r = compute_residuals(im, xfi, xc, M);
    err = mean(r);
    if err < errbest
        errbest = err;
        xf = xfi;
    end
end
