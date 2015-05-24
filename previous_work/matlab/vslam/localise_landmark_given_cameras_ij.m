function xf = localise_landmark_given_cameras_ij(pixs, xc, i, j, Kinv)
% Compute xf given {pixs(:,i),xc(:,i)} and {pixs(:,j),xc(:,j)}

x1 = xc(1:3, i);
R1 = a2R(xc(4:6, i));
[xr, Rr] = transform2relative(xc(1:3,j), a2R(xc(4:6,j)), x1, R1);
%xf = localise_landmarks_given_two_cameras(pixs(:,i), pixs(:,j), xr, Rr, Kinv);
[~,~,xf] = localise_landmarks_given_two_cameras(pixs(:,i), pixs(:,j), xr, Rr, Kinv);
if xf(3) < 0, xf = -xf; end
xf = R1*xf + x1;
