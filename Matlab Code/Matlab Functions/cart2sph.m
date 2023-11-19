function [az,elev,r] = cart2sph(x,y,z)
%CART2SPH Transform Cartesian to spherical coordinates.
%   [TH,PHI,R] = CART2SPH(X,Y,Z) transforms corresponding elements of data
%   stored in Cartesian coordinates X,Y,Z to spherical coordinates (azimuth
%   TH, elevation PHI, and radius R).  The arrays X,Y, and Z must have
%   compatible sizes. In the simplest cases, they can be the same size or
%   one can be a scalar. Two inputs have compatible sizes if, for every
%   dimension, the dimension sizes of the inputs are either the same or one
%   of them is 1. TH and PHI are returned in radians.
%
%   TH is the counterclockwise angle in the xy plane measured from the
%   positive x axis. PHI is the elevation angle from the xy plane.
%
%   Class support for inputs X,Y,Z:
%      float: double, single
%
%   See also CART2POL, SPH2CART, POL2CART.

%   Copyright 1984-2021 The MathWorks, Inc. 

hypotxy = hypot(x,y);
r = hypot(hypotxy,z);
elev = atan2(z,hypotxy);
az = atan2(y,x);
