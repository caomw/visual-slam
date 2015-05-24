function [xc,Rc] = camera_pose_from_point_observations(xg, im)
% FIXME: Currently broken, needs further testing... For now, use
% camera_pose_from_point_observations_linearised instead. It requires an
% initial guess at (xc,Rc) but should converge quickly from even large
% errors (provided facing in approx the right direction).

% Estimate camera pose given the global 3D point locations (xg) and a set
% of normalised image observations (im=[x/z;y/z]) taken by the camera.
% This solution does not account for uncertainty in xg or im, and so is
% used for an initial estimate only.
% Algorithm from a combination of Hartley p179 and Szelinski p284.

N = size(xg,2);
z = zeros(4,N);
w = ones(1,N);
Ax = [-xg; -w; z; reprow(im(1,:),3).*xg; im(1,:)];
Ay = [z; -xg; -w; reprow(im(2,:),3).*xg; im(2,:)];
A = [Ax Ay]';

% Solve homogeneous equation Ax=0 with constraint norm(x)=1. See Hartley p593.
[~,~,V] = svd(A,0);
V = V(:,12); 

% These are the relative coordinates of the origin, which appear as R,t in Szelinski p284.
%Rc = [V(1:3) V(5:7) V(9:11)]'; 
%xc = V([4 8 12]);

% These are the camera coords wrt the origin: Rc = R'; xc = -R't
Rc = [V(1:3) V(5:7) V(9:11)];
xc = -Rc*V([4 8 12]);
n = norm(Rc(:,3)); % normalise to obtain orthogonal matrix
Rc = Rc/n;
%xc = -Rc*V([4 8 12])/n;
xc = xc/(n*n);
