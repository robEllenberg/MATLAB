function processSTL(filelist,mir,hull,check,stlout,reduce)
%% Process VMRL97 files exported from Inventor 20XX by CADStudio's VRML exporter
% Read in a listing of files and process them for OpenRAVE by adding color
% data, and optionally mirroring and finding the convex hulls of each.
% Usage:
%   processVRML(filelist,mir,hull,check,stlout,reduce)
%       filelist is a string that the "dir" command uses to find matching
%           files. Thus, '*.wrl' will return all VRML files, while
%          'Body_L*.wrl' will return only left sides
%       mir is a string indicating what mirror operation to do:
%           'RL' means right to left, 'LR' means left to right
%       hull is a flag to export the convex hull of the body, prefixed with
%           'convhull'
%       check is a flag which optionally shows the processed surfaces.
%       stlout is a flag that optionally exports the finished shape to stl
%           format
%       reduce is a percentage volume preservation tolerance. Usually this
%          should be greater than .99 to minimize distortion. The reduction
%          method is fast but not gauranteed to preserve shape for more
%          drastic reductions.

if ~exist('stlout')
    stlout='';
end

if ~exist('check')
    check=0;
end

if ~exist('mir')
    mir='';
end

if ~exist('hull')
    hull=0;
end

if ~exist('reduce')
    reduce=0;
end

listing = dir(filelist);

appearance.ambientIntensity = 1;
appearance.diffuse = [.7 .7 .7];
appearance.specular = [.8 .8 .83];
appearance.shininess = .3;
tic;
for k=1:length(listing)
    
    if listing(k).isdir
        continue
    end
    
    fname=listing(k).name;
    fname
    [K,pointCloud]=stlread(fname);
    if check>=1
        eztrisurf(K,pointCloud);
        drawnowvim 
        if check>=2
            pause()
        else
            pause(3-toc)
        end
    end
    tic;
    newCloud=pointCloud;
    newName=fname;
    newMesh=K;
    
    %Mirror VRML if specified
    rmatch=strfind(fname,'_R');
    lmatch=strfind(fname,'_L');
    if ~isempty(lmatch) && strcmp(mir,'LR')
        %Read in the string for the mirror operation and choose the
        %output character
        %newName=fname(1:end-4);
        newName(lmatch+1)=mir(2);
        newCloud(:,2)=-newCloud(:,2);
        newMesh=K(:,[1,3,2]);
    elseif ~isempty(rmatch) && strcmp(mir,'RL')
        newName(rmatch+1)=mir(2);
        newCloud(:,2)=-newCloud(:,2);
        newMesh=K(:,[1,3,2]);
    end
    
    if hull
        newMesh=convhull(newCloud);
        [newCloud,newMesh]=shrinkPointCloud(newCloud,newMesh);
        suffixstart=strfind(newName,'_');
        newName=['convhull' newName(suffixstart:end)];
    end
    %Reduce geometry by volume percentage (only if using convex hull!)
    if reduce && hull
        [newCloud, newMesh]=trimeshReduce(newCloud,newMesh,reduce,check);
    end
    
    if ~isempty(stlout) && stlout
        if stlout(1)=='b'
            fmt='binary';
        else
            fmt='ascii';
        end
        outname=[newName(1:end-4),'.stl'];
        fprintf('Mesh has %d faces\n',size(newMesh,1))
        cloud2stl(outname,newCloud,newMesh,fmt)
        
        if check && fmt(1)=='a'
            [p,v,n]=import_stl_fast(outname,1);
            disp('Showing re-imported STL')
            clf
            eztrisurf(v,p)
        end
    end
    clear newCloud K newMesh pointCloud ans
end


