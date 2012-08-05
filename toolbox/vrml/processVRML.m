function processVRML(fileName,mir,hull)

switch nargin
    case 1
        mir=0;
        hull=0;
    case 2
        hull=0;
    case 3
end
    
%% Make a mirror image of all left side bodies
if strcmp(fileName,'all')
    listing = dir('Body_L*.wrl');
else
    listing(1).name=fileName;
    listing(1).isdir=0;
end

appearance.ambientIntensity = 1;
appearance.diffuse = [.7 .7 .7];
appearance.specular = [.8 .8 .83];
appearance.shininess = .3;

for k=1:length(listing)
    if ~listing(k).isdir
        fname=listing(k).name;
        
        [pointCloud,K]=importVRMLMesh(fname);
        
        %Mirror VRML if specified
        if mir
            %assume mirror left to right
            newName=fname(1:end-4);newName(6)='R';
            newCloud=pointCloud;
            newCloud(:,2)=-mirrorCloud(:,2);
            newMesh=K(:,[1,3,2]);
        else
            newCloud=pointCloud;
            newName=fname;
            newMesh=K;
        end
        
        if hull
            newMesh=convhull(newCloud);
            [newCloud,newMesh]=shrinkPointCloud(newCloud,newMesh);
            newName=['convhull' newName(5:end)];
        end
        exportTriMeshtoVRML(newName(1:end-4),newCloud,newMesh,appearance)
        %demonstrate that it worked (optional)
        importVRMLMesh(newName,1);
        pause(1);
    end
    clear newCloud K newMesh pointCloud ans
end

end