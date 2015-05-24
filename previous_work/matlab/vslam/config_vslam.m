function [R, optadd, optsub] = config_vslam()

VERBOSE = 1;
OBSERVE_STD_DEV = 1;   % measurement standard deviation in pixels
GATE_INNOVATION = 5*5; %chi_square_bound(0.99, 2);
GATE_RESIDUAL = 10*10; %chi_square_bound(0.9, 2);
GATE_RATIO_MAX_RESIDUAL = 0.3;

% ------------------------------------------------------------

R = eye(2) * OBSERVE_STD_DEV^2;
optadd.verbose = VERBOSE;
optadd.gateinnov = GATE_INNOVATION;
optsub.verbose = VERBOSE;
optsub.gateratio = GATE_RATIO_MAX_RESIDUAL;
optsub.gateresid = GATE_RESIDUAL;
