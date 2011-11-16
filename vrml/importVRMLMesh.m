function data=importVRMLMesh(fname,dispResult)
%% importVRMLMesh
% Author: Robert Ellenberg
%   (Based on wrl2mat by Alireza Bossaghzadeh)
%
%   Extract the coordinate indices and point cloud from a VRML model. Note
%   that this function makes very restrictive assumptions about the nature
%   of the VRML file.  It can basically only handle a single object,
%   defined first by a set of points, then a set of indices.
%

vrfile=fopen(fname);

pointcloud=zeros(2000,3);
coordIndex=zeros(2000,4);
foundData=0;
types={'point','coordIndex','vector'};

while ~feof(vrfile)
    [datatype,foundData]=findVRMLData(vrfile);
    %TODO extratc each type of data and store it appropriately
    %TODO change the other functions to use this new structure
    %cell array format
    data{k}=extractVRMLData(vrfile)

    


pointcloud=pointcloud(1:p,:); %trim padded zeros

p=1;
counter=0;
fprintf('Reading surface mesh data from %s\n', fname)
while counter ~= -1
    data=fgets(vrfile);
    fpoint=strfind(data,'coordIndex');% 2 checkers to find out the begining
    f2point=strfind(data,'[');   %of the x,y,z " point [ "
    while ~isempty(fpoint) && ~isempty(f2point)
        data=fgets(vrfile);
        if isempty(strfind(data,']'));
            t=sscanf(data,'%d, %d, %d, %d,');
            coordIndex(p,:)=t';
            p=p+1;  
        else fpoint=[];counter=-1;
        end
        if p>size(coordIndex,1);
            coordIndex=[coordIndex;zeros(200,4)];
        end
    end
end
coordIndex=coordIndex(1:p,:); %trim padded zeros
fclose(vrfile);

disp('Display results')

K=coordIndex(:,1:3)+1;
X=pointcloud(:,1);Y=pointcloud(:,2);Z=pointcloud(:,3);%Load positions to X,Y,Z

if nargin<2
    dispResult=0;
end
if dispResult
    
    %Display the imported VRML Mesh
    figure(1)
    trisurf(K,X,Y,Z);
    axis equal
   
end

function [datatype,foundType]=findVRMLData(fidi,types)

    if nargin<2
        types={'point','coordIndex','vector'};
    end

    foundType=0;
    dataype='none';

    while ~feof(fid) || ~foundType
        data=fgetl(vrfile);
        for k=1:length(types)
            %TODO: check that this find the headings correctly
            if ~isempty(strfind(data,types{k})) && ~isempty(strfind(data,'['))
                datatype=types{k}
                foundType=1;
                break;
            end
        end
    end
end

function data=extractVRMlData(fid)
    %Extract data from the current location to the end of the vector
    %TODO test this

    dataLine=fgets(fid);
    t=sscanf(dataLine,'%f');
    data=zeros(1000,length(t));

    scanComplete=0;

    while ~scanComplete 
        t=sscanf(dataLine,'%f'); %Scan for data
        data(p,:)=t'; %Store the line of data
        p=p+1;  

        if p>size(data,1);
            data=[data;zeros(200,4)];
        end
        %Read the next line
        dataLine=fgets(fid);
        scanComplete=~isempty(strfind(dataLine,']'));
    end
end
