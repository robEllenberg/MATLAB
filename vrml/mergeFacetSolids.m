function [P,K]=mergeFacetSolids(P1,K1,P2,K2)
%Merge 2 faceted solids together in the crudest way possible.

% [P,K]=mergeFacetSolids(P1,K1,P2,K2)
% Where P is the pointcloud, K is the face list.
%   Point clouds are defined by m x 3 matrices of points.
%   Face lists are n x 3 lists of faces made up of said points.

P=[P1;P2];

startInd=size(P1,1);
K=[K1;K2+startInd];
end
