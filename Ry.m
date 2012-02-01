function R=Rx(theta)
%% Produce a rotation about the X axis, transforming from a local coordinate system to a global coordinate system.
R=[ cos(theta)  0   sin(theta);
    0           1       0;
    -sin(theta) 0   cos(theta)];
end
