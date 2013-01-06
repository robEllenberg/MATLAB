function processVRML(filelist,mir,hull,check)
%% Process VMRL97 files exported from Inventor 20XX by CADStudio's VRML exporter
% Read in a listing of files and process them for OpenRAVE by adding color
% data, and optionally mirroring and finding the convex hulls of each.
% Usage:
%   processVRML(filelist,mir,hull)
%       filelist is a string that the "dir" command uses to find matching
%           files. Thus, '*.wrl' will return all VRML files, while
%          'Body_L*.wrl' will return only left sides
%       mir is a string indicating what mirror operation to do:
%           'RL' means right to left, 'LR' means left to right
%       hull is a flag to export the convex hull of the body, prefixed with
%           'convhull'

switch nargin
    case 1
        mir=0;
        hull=0;
    case 2
        hull=0;
    case 3
end
    
listing = dir(filelist);

appearance.ambientIntensity = 1;
appearance.diffuse = [.7 .7 .7];
appearance.specular = [.8 .8 .83];
appearance.shininess = .3;

for k=1:length(listing)
    if ~listing(k).isdir
        fname=listing(k).name;
        
        [pointCloud,K]=importVRMLMesh(fname);
        
        %Mirror VRML if specified
        if (fname(6)=='R' || fname(6)=='L') && (strcmp(mir,'RL') || strcmp(mir,'LR'))
            %Read in the string for the mirror operation and choose the
            %output character
            newName=fname(1:end-4);newName(6)=mir(2);
            newCloud=pointCloud;
            newCloud(:,2)=-newCloud(:,2);
            newMesh=K(:,[1,3,2]);
        else
            newCloud=pointCloud;
            newName=fname;
            newMesh=K;
        end
        
        %Export and check
        exportTriMeshtoVRML(newName,newCloud,newMesh,appearance)
        if check
            importVRMLMesh(newName,1);
            pause(1);
        end
        
        if hull
            newMesh=convhull(newCloud);
            [newCloud,newMesh]=shrinkPointCloud(newCloud,newMesh);
            newName=['convhull' newName(5:end)];
        end
        
        %Export and check
        exportTriMeshtoVRML(newName,newCloud,newMesh,appearance)
        if check
            importVRMLMesh(newName,1);
            pause(1);
        end
    end
    clear newCloud K newMesh pointCloud ans
end

end