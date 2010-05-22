function [model,UV,srfind,srfDerivind,srfDer,numpoints]=projIGES(ParameterData,EntityType,numEntityType,normal,pdir,dp)
% PROJIGES returns points of projections on surfaces from an IGES-file.
% 
% Usage:
% 
% [model,UV,srfind,srfDerivind,srfDer,numpoints]=projIGES(ParameterData,...
%                                  EntityType,numEntityType,normal,pdir,dp)
% 
% Input:
% 
% ParameterData - Parameter data from IGES file. ParameterData
%                 is one of the output from IGES2MATLAB.
% EntityType,numEntityType - Outputs from IGES2MATLAB (see help IGES2MATLAB).
% normal - The projection normal. The direction of normal is toward the surface.
% pdir - The first (primary) direction in which projection points lies.
% dp - the distance between the projected points.
% 
% Output:
% 
% model - points of projetions.
% UV - the parameter values for corresponding model point from original surface.
% srfind - The index of surface in ParameterData for corresponding model point. srfind(i)==0 means no projection.
% srfDerivind - The index of surface derivatives in srfDer for corresponding model point.
% srfDer - Cell array with surface first and second derivative for all model points.
%               
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
% 
% written by Per Bergström 2009-12-04
%

if nargin<6
   error('projIGES must have 6 input arguments!'); 
end

if not(iscell(ParameterData))
    error('ParameterData must be a cell array!');
end

[mnormal,nnormal]=size(normal);

if mnormal<nnormal
    normal=normal';
    [mnormal,nnormal]=size(normal);
end

[mpdir,npdir]=size(pdir);

if mpdir<npdir
    pdir=pdir';
    [mpdir,npdir]=size(pdir);
end

if not(and(mpdir==3,mnormal==3))
    error('Length of normal and pdir must be 3');
end

if length(dp)~=1
    error('dp must be a scalar!');
elseif dp<eps
    error('dp must be larger than eps!');
end

normal=normal/norm(normal);

pdir=pdir-dot(pdir,normal)*normal;   % primary direction

nopd=norm(pdir);
if nopd<1e-6
    error('pdir can not be parallel to normal');
else
    pdir=pdir/nopd;                  % orthogonal to normal
end

sdir=cross(normal,pdir);             % secondary direction
sdir=sdir/norm(sdir);

siz=length(ParameterData);

nn=15;

le=numEntityType(EntityType==128)*nn^2;  %% assume that the only non trimmed surface is entity 128

Pp=zeros(3,le);

ii=0;
for i=1:siz
    if ParameterData{i}.type==128
        
        ii=ii+1;
        
        [V,U]=meshgrid(linspace(ParameterData{i}.v(1),ParameterData{i}.v(2),nn),linspace(ParameterData{i}.u(1),ParameterData{i}.u(2),nn));
        UVtemp=[reshape(U,1,nn^2);reshape(V,1,nn^2)];
        Pp(:,((ii-1)*nn^2+1):(ii*nn^2))=nrbevalIGES(ParameterData{i}.nurbs,UVtemp);
        
    end
end                                 

Pp2=[pdir sdir]\Pp;

% Finds intervals

maPp2_1=max(Pp2(1,:));
miPp2_1=min(Pp2(1,:));
maPp2_2=max(Pp2(2,:));
miPp2_2=min(Pp2(2,:));

clear Pp;

di1=maPp2_1-miPp2_1;
di2=maPp2_2-miPp2_2;

np1=ceil(di1/dp)+1;
np2=ceil(di2/dp)+1;

numpoints=[np1 np2];

dif1=0.5*(dp*np1-di1);
dif2=0.5*(dp*np2-di2);

pvec1=linspace(miPp2_1-dif1,maPp2_1+dif1,np1);
pvec2=linspace(miPp2_2-dif2,maPp2_2+dif2,np2);

pO=[(miPp2_1-dif1);(miPp2_2-dif2)];

[model,UV,srfind,srfDerivind,srfDer,nmodel]=projIGESsub(ParameterData,normal,pdir,sdir,dp,np1,np2,pO);


function [model,UV,srfind,srfDerivind,srfDer,nmodel]=projIGESsub(ParameterData,normal,pdir,sdir,dp,np1,np2,pO)

nmodel=np1*np2;

model=zeros(3,nmodel);

UV=zeros(2,nmodel);

srfind=zeros(1,nmodel);
srfindsup=zeros(1,nmodel);

normalz=Inf*ones(1,nmodel);

% For triangulation comparison

for i=1:length(ParameterData)   % Triangulate each surface and find projection on triangulation
    
    [PTRI,isSCP,isSup,TRI,UV0,srfind0]=retSrfCrvPnt(1,ParameterData,1,i,200,0);
    
    if and(isSCP,not(isSup))
        
        pcoord=pdir'*PTRI;
        
        if (pO(1)+(np1-1)*dp)>min(pcoord)
            if pO(1)<max(pcoord)
                scoord=sdir'*PTRI;
                if (pO(2)+(np2-1)*dp)>min(scoord)
                    if pO(2)<max(scoord)
                        
                        for j=1:size(TRI,1)
                            
                            ind1s=floor((min(pcoord(TRI(j,:)))-pO(1))/dp);
                            if ind1s<np1
                                ind1e=ceil((max(pcoord(TRI(j,:)))-pO(1))/dp);
                                if ind1e>-1
                                    ind2s=floor((min(scoord(TRI(j,:)))-pO(2))/dp);
                                    if ind2s<np2
                                        ind2e=ceil((max(scoord(TRI(j,:)))-pO(2))/dp);
                                        if ind2e>-1
                                            
                                            coordmat=[scoord(TRI(j,2))-scoord(TRI(j,3)) pcoord(TRI(j,3))-pcoord(TRI(j,2));scoord(TRI(j,3))-scoord(TRI(j,1)) pcoord(TRI(j,1))-pcoord(TRI(j,3))];
                                            c=det(coordmat);
                                            
                                            if abs(c)>1e-12
                                                
                                                coordmat=coordmat/c;
                                                
                                                for ii=max(0,ind1s):min(np1-1,ind1e)
                                                    for jj=max(0,ind2s):min(np2-1,ind2e)
                                                        
                                                        p=pO;
                                                        p(1)=p(1)+ii*dp-pcoord(TRI(j,3));
                                                        p(2)=p(2)+jj*dp-scoord(TRI(j,3));
                                                        
                                                        ab=coordmat*p;
                                                        c=1-sum(ab);
                                                        
                                                        if ab(1)>-0.00001 & ab(2)>-0.00001 & c>-0.00001
                                                            
                                                            Ptemp=ab(1)*PTRI(:,TRI(j,1))+ab(2)*PTRI(:,TRI(j,2))+c*PTRI(:,TRI(j,3));
                                                            normalztemp=dot(Ptemp,normal);
                                                            
                                                            if normalztemp<normalz(ii*np2+jj+1)
                                                                normalz(ii*np2+jj+1)=normalztemp;
                                                                UV(:,ii*np2+jj+1)=ab(1)*UV0(:,TRI(j,1))+ab(2)*UV0(:,TRI(j,2))+c*UV0(:,TRI(j,3));
                                                                srfind(ii*np2+jj+1)=srfind0;
                                                                srfindsup(ii*np2+jj+1)=i;
                                                                model(:,ii*np2+jj+1)=Ptemp;
                                                            end
                                                            
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    clear PTRI isSCP isSup TRI UV0 srfind0 runTRI coordmat;
end

[sosrfind,indsoP]=sort(srfind);

sti=1+nmodel;

numbder=0;
soi2=sti;
for i=1:nmodel
    if and(sosrfind(i)>0,numbder==0)
        sti=i;
        soi=sosrfind(i);
        soi2=soi;
        numbder=1;
    elseif sosrfind(i)>soi2
        soi2=sosrfind(i);
        numbder=numbder+1;
    end
end
clear soi2

srfDer=cell(1,numbder);
srfDerivind=zeros(1,nmodel);

if numbder>0
    srfDerind=1;
    if ParameterData{srfind(indsoP(sti))}.type==128
        srfDer{srfDerind}.type=128;
        srfDer{srfDerind}.name='B-NURBS SRF & DERIVATIVE';
        srfDer{srfDerind}.nurbs=ParameterData{soi}.nurbs;
        srfDer{srfDerind}.dnurbs=ParameterData{soi}.dnurbs;
        srfDer{srfDerind}.d2nurbs=ParameterData{soi}.d2nurbs;
        srfDer{srfDerind}.supind=srfindsup(indsoP(sti));
    end
end

for i=sti:nmodel           % For each model point. Find the projection on the corresponding surface.
    if sosrfind(i)>soi
        soi=sosrfind(i);
        srfDerind=srfDerind+1;
        if ParameterData{srfind(indsoP(i))}.type==128
            srfDer{srfDerind}.type=128;
            srfDer{srfDerind}.name='B-NURBS SRF & DERIVATIVE';
            srfDer{srfDerind}.nurbs=ParameterData{soi}.nurbs;
            srfDer{srfDerind}.dnurbs=ParameterData{soi}.dnurbs;
            srfDer{srfDerind}.d2nurbs=ParameterData{soi}.d2nurbs;
            srfDer{srfDerind}.supind=srfindsup(indsoP(i));
        end
    end
    srfDerivind(indsoP(i))=srfDerind;
    [model(:,indsoP(i)),UV(:,indsoP(i))]=closestNrbLinePointIGES(srfDer{srfDerind}.nurbs,srfDer{srfDerind}.dnurbs,srfDer{srfDerind}.d2nurbs,UV(:,indsoP(i)),model(:,indsoP(i)),normal);
end