function [newCloud,newFaces]=shrinkPointCloud(pCloud,faces)
%After convex hull calculation, a lot of points are no longer necessary. This
%function finds only the points used in the new faces, and throws away the
%rest.  It's probably balls slow, but it's not worth tweaking at this point
%
%Usage:
%   [newCloud,newFaces] = shrinkPointCloud(pCloud,faces)
%
%       newCloud is the new point cloud, reduced in size
%       newFaces is the new set of indices referring to these new pruned
%       points
%       pCloud is the original point cloud
%       faces is the reduced set of faces

    pointsUsed=unique(faces);
    newFaces=zeros(size(faces));
    for k=1:length(pointsUsed)
        %Remap old faces onto new point cloud
        ind= faces==pointsUsed(k);
        newFaces(ind)=k;
    end
    newCloud=pCloud(pointsUsed,:);
end
