function [xsall, sw, y, Y, fcount] = demo_batch_vslam(z, K, flags, xc, xf)
% Obtain z as, eg: z = convert_sequence_to_matched_observations('../shrimp_data');
% Run as:
%   [xsall, sw, y, Y, fcount] = demo_batch_vslam(z, K);
%   [xsall, sw, y, Y, fcount] = demo_batch_vslam(z, K, flags, xsall);
%   [xsall, sw, y, Y, fcount] = demo_batch_vslam(z, K, flags, xc, xf);

[R, optadd, optsub] = config_vslam;
Nc = length(z);
K23 = K(1:2,:);

% Initialise xs
if nargin == 2
    [xc, xf, flags] = slam_initialise(z, 1, 10, K, 6); % FIXME: put constants in config file
elseif nargin == 4
    xf = zeros(3, length(flags));
    i = 6*Nc;
    xf(:) = xc((i+1):end);
    xc = xc(1:i);
end

xsall = [xc(:); xf(:)];
xf = xf(:, flags);
xs = [xc(:); xf(:)];

for i = 1:5 % Relinearisation loop -- revise xs
    % Compute information for given xs    
    [info, infoaddr] = estimator_compute_information(z, R, K23, xsall);
    if i == 1 % initial switches: Turn ON all observations of active features, and disable the rest
        sw = -ones(1, length(info)); % sw = 1 (ON), 0 (OFF), -1 (DISABLED)
        sw(flags([info.fid])) = 1;        
    end

    % Initialise state estimate
    [y, Y, fcount] = estimator_accumulate_information(info(sw==1), Nc, flags);
    
    % Remove features that are too uncertain or have over-large conditional-information content
    fmap = cumsum(fcount~=0);
    fid1 = estimator_detect_very_uncertain_features(Y, Nc, fmap, find(fcount~=0), 100);
    fid2 = estimator_detect_numerically_unstable_features(Y, Nc, fmap, find(fcount~=0), 1e9);
    fid = union(fid1, fid2);
    if ~isempty(fid)
        [y, Y, xs, fcount, sw] = estimator_remove_features_from_state(y, Y, ...
            xs, Nc, fcount, flags, info, infoaddr, sw, fid);
    end
        
    % Define base frame x(1:6) and scale via x(jj)
    jj = 10*6 - 6 + 3; % z-axis position for frame 10
    ii = [1:6 jj];
    Yb = eye(7)*1e4;  
    yb = Yb * xs(ii);    
    %yb = [zeros(6,1); Yb(7,7)*xs(jj)]; % this form ensures frame 1 is {xc=0,ac=0}
    Y(ii,ii) = Y(ii,ii) + Yb;
    y(ii) = y(ii) + yb;

%figure        
    % Data association loop -- initialise new features, then add and remove information
    for j = 1:2 
        % Attempt to initialise disabled features -- augment state {y, Y, xs, fcount}
%        [y, Y, xs, fcount, info, sw] = estimator_initialise_new_landmarks(y, Y, xs, ...
%            Nc, fcount, info, infoaddr, sw, R, K, optadd);

        % Add information to existing features -- innovation based
        [y, Y, fcount, sw] = estimator_information_add(y, Y, xs, ...
            Nc, fcount, info, sw, R, K23, optadd);

        % Data association removal loop  
        converged = false;
        while ~converged 
            % Subtract information -- residual based -- may reduce xs
            [y, Y, xs, fcount, sw, converged] = ...
                estimator_information_subtract(y, Y, xs, ...
                Nc, fcount, info, infoaddr, sw, R, K23, optsub);
xx = Y\y; s = 6*Nc;
a=1;b=3; 
plot(xs(a:6:s),xs(b:6:s),'+', xs((s+a):3:end), xs((s+b):3:end), '.', ...
     xx(a:6:s),xx(b:6:s),'+', xx((s+a):3:end), xx((s+b):3:end), '.')
grid, axis equal, drawnow
        end
    end
    
    % Update xs and xsall
    xs = full(Y\y);
    xsall = update_all_linearisations(xsall, xs, Nc, fcount);
    flags = (fcount ~= 0);
end

%
%

function xsall = update_all_linearisations(xsall, xs, Nc, fcount)
i = 1:(6*Nc);
j = estimator_index2state(find(fcount~=0), 3, 6*Nc);
xsall([i(:); j(:)]) = xs;
