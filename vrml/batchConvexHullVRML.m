%% Make a mirror image of all left side bodies
listing = dir('Body_*.wrl');
appearance.ambientIntensity = 1;
appearance.diffuse = [.8 .8 .5];
appearance.specular = [.8 .85 .8];
appearance.shininess = .3;

for k=1:length(listing)
    if ~listing(k).isdir
        fname=listing(k).name;
        
        [pointCloud,K]=importVRMLMesh(fname);
        
        %crude way to flip from left to right
        newName=['convhull_',fname(6:end-4)];
        
        %Mirror about Y axis
        newK=convhull(pointCloud(:,1),pointCloud(:,2),pointCloud(:,3));
        [newP,newK]=shrinkPointCloud(pointCloud,newK);
        
        exportTriMeshtoVRML(newName,newP,newK,appearance)
        %demonstrate that it worked (optional)
        importVRMLMesh([newName,'.wrl'],1);
        drawnow;
        pause(1);
    end
    clear mirrorCloud K pointCloud ans
end