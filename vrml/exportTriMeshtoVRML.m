function exportTriMeshtoVRML(fileName,pCloud,faces,appearance)
%% Export a point cloud and 1-indexed face set as a simple VRML file
%

    if nargin <4
        appearance.ambientIntensity = 1;
        appearance.diffuse = [.8 .7 .7];
        appearance.specular = [.8 .8 .8];
        appearance.shininess = .6;
    end
    
    fid=fopen([fileName,'.wrl'],'w');
    
    %Dump the header and file name as the model name
    fprintf(fid,'#VRML V2.0 utf8\n\nDEF %s\nTransform {\n\tchildren [\n\t\t Shape {\n',fileName);
    
    fprintf(fid,'\t\t\tappearance Appearance{\n\t\t\tmaterial Material {\n');
    fprintf(fid,'\t\t\t\tambientIntensity %f\n',appearance.ambientIntensity);
    fprintf(fid,'\t\t\t\tdiffuseColor %f %f %f\n',appearance.diffuse);
    fprintf(fid,'\t\t\t\tspecularColor %f %f %f\n',appearance.specular);
    fprintf(fid,'\t\t\t\tshininess %f\n\t\t\t\t}\n\t\t\t}\n',appearance.shininess);
        
    
    %Preface point set
    fprintf(fid,'\t\t\tgeometry IndexedFaceSet {\n\t\t\t\tcoord Coordinate {\n\t\t\t\t\tpoint [\n');
    %Exported the "header portion" i.e. all the junk that leads up to the point cloud.

    for k=1:size(pCloud,1)
        fprintf(fid,'\t\t\t\t\t%f %f %f,\n',pCloud(k,:));
    end

    %2nd text block, copied from example file

    fprintf(fid,'\t\t\t\t]\n\t\t\t}\n\t\t\tcoordIndex [\n');

    %Dump triangle sets
    for k=1:size(faces,1)
        %Note that VRML is 0-indexed, so subtract 1 from each vertex #
        fprintf(fid,'\t\t\t\t\t%d, %d, %d,-1,\n',faces(k,:)-1);
    end
    
    %Terminating text block
    fprintf(fid,'\t\t\t\t]\n\t\t\t}\n\t\t}\n\t]\n}\n');
    fclose(fid);
end
