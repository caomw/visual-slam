function demo_plot_results_covariance(y, Y, xsall, Nc, fcount, j)
prob = 0.5;
x = Y\y;

% FIXME: Should condition on scale, but for now do this:
if nargin == 6
    Yp = 1e7;
    jj = j*6 - 6 + 3; % z-coord for camera j
    Y(jj,jj) = Y(jj,jj) + Yp;
    y(jj) = y(jj) + Yp * x(jj);
end

% Condition on xc1
[y,Y] = canonical_condition(y,Y,1:6,x(1:6));
Nc = Nc-1;
xsall = xsall(7:end);

%
x = Y\y;
P = full(inv(Y));
Nclen = 6*Nc;
Nf = (length(y) - Nclen) / 3;
iif = estimator_index2state(find(fcount~=0), 3, Nclen);
xs = xsall([1:Nclen iif(:)']);

% 2D plot: choose x,z
e = []; nn = [nan;nan];
for i = 1:Nc
    ii = estimator_index2state(i, 6, 0);
    ii = ii([1 3]);
    e = [e nn ellipse_mass(x(ii), P(ii,ii), prob)];
end
for i = 1:Nf
    ii = estimator_index2state(i, 3, Nclen);
    ii = ii([1 3]);
    e = [e nn ellipse_mass(x(ii), P(ii,ii), prob)];
end    
figure
plot(x(3:6:Nclen),  -x(1:6:Nclen), '+', ...
    xs(3:6:Nclen), -xs(1:6:Nclen), 'x', ...
     x((Nclen+3):3:end),  -x((Nclen+1):3:end), '.', ...
    xs((Nclen+3):3:end), -xs((Nclen+1):3:end), '.', ...
    e(2,:), -e(1,:))
axis equal
grid

% 3D plot: draw covariance as line along principal axis
figure
plot3(x(3:6:Nclen),  -x(1:6:Nclen),  -x(2:6:Nclen), '+', ...
    xs(3:6:Nclen), -xs(1:6:Nclen), -xs(2:6:Nclen), 'x', ...
     x((Nclen+3):3:end),  -x((Nclen+1):3:end),  -x((Nclen+2):3:end), '.', ...
    xs((Nclen+3):3:end), -xs((Nclen+1):3:end), -xs((Nclen+2):3:end), '.')
axis equal
grid
