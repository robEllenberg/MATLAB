function R=Rx(theta)
%% Produce a rotation about the X axis, transforming from a local coordinate system to a global coordinate system.
R=[1        0         0;
   0 cos(theta) -sin(theta)
   0 sin(theta) cos(theta)];
end
