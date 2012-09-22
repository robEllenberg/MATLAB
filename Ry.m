function R=Ry(theta)
%% Produce a rotation about the X axis, transforming from a local coordinate system to a global coordinate system.
%x=tan(theta/2);
R=[cos(theta) 0 sin(theta);
   0 1 0;
   -sin(theta) 0 cos(theta)];
end
