%% Make a mirror image of all left side bodies
listing = dir('Body_L*.wrl');
appearance.ambientIntensity = 1;
appearance.diffuse = [.7 .7 .7];
appearance.specular = [.8 .8 .83];
appearance.shininess = .3;

for k=1:length(listing)
    if ~listing(k).isdir
        fname=listing(k).name;
        
        [pointCloud,K]=importVRMLMesh(fname);
        
        %crude way to flip from left to right
        newName=fname(1:end-4);newName(6)='R';
        
        %Mirror about Y axis
        mirrorCloud=pointCloud;
        mirrorCloud(:,2)=-mirrorCloud(:,2);
        
        exportTriMeshtoVRML(newName,mirrorCloud,K,appearance)
        %demonstrate that it worked (optional)
        importVRMLMesh([newName,'.wrl'],1);
        drawnow;
        pause(1);
    end
    clear mirrorCloud K pointCloud ans
end