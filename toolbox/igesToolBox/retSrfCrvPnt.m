function [P,isSCP,isSup,TRI,UV,srfind]=retSrfCrvPnt(SCP,ParameterData,isSup,ind,n,dim)
% RETSRFCRVPNT is a subfunction in IGES2MATLAB file collection.
% No complete documentation is given.
%
% SCP - 1, surface
%     - 2, curve
%     - 3, point
%
% ParameterData - Parameter data from IGES file
%
% isSup - 1, if superior then return isSup=1
%       - 0, isSup=0 (always)
%
% ind - index
%
% n - number of points for curves, n^2 number of poinst for non trimmed surface
%
% dim - [2,3] 2, curve in domain, 3, curve in space
%
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
%
% written by Per Bergström 2009-12-04
%

isSCP=0;

if SCP==1           % SURFACE
    
    if ParameterData{ind}.type==128
        
        isSCP=1;
        srfind=ind;
        
        if and(isSup,ParameterData{ind}.superior)
            P=zeros(3,0);
            TRI=zeros(0,3);
            UV=zeros(2,0);
        else
            
            isSup=0;
            [V,U]=meshgrid(linspace(ParameterData{ind}.v(1),ParameterData{ind}.v(2),n),linspace(ParameterData{ind}.u(1),ParameterData{ind}.u(2),n));
            
            UV=[reshape(U,1,n^2);reshape(V,1,n^2)];
            
            P=nrbevalIGES(ParameterData{ind}.nurbs,UV);
            
            TRI=zeros(2*(n-1)^2,3);
            
            for i=1:(n-1)
                for j=1:(n-1)
                    TRI((2*(i+(j-1)*(n-1))-1),:)=[(i+n*(j-1)) (i+n*(j-1)+1) (i+n*j)];
                    TRI((2*(i+(j-1)*(n-1))),:)=[(i+n*(j-1)+1) (i+n*j) (i+n*j+1)];
                end
            end
        end
        
    elseif ParameterData{ind}.type==144
        
        if ParameterData{ParameterData{ind}.pts}.type==128
            
            isSCP=1;
            isSup=0;
            
            srfind=ParameterData{ind}.pts;
            
            n2=ParameterData{ind}.n2;
            NN=ones(1,n2+1);
            
            if and(nargin==6,ParameterData{ind}.n1)
                NO=max(ceil((ParameterData{ParameterData{ind}.pto}.length/ParameterData{ParameterData{ind}.pto}.gdiagonal)*2500),50);
                NN(1)=NO;
                for j=1:n2
                    NN(j+1)=max(ceil((ParameterData{ParameterData{ind}.pti(j)}.length/ParameterData{ParameterData{ind}.pti(j)}.gdiagonal)*2500),50);
                end
            else
                NO=max(ceil((ParameterData{ParameterData{ind}.pto}.length/ParameterData{ParameterData{ind}.pto}.gdiagonal)*700),40);
                NN(1)=NO;
                for j=1:n2
                    NN(j+1)=max(ceil((ParameterData{ParameterData{ind}.pti(j)}.length/ParameterData{ParameterData{ind}.pti(j)}.gdiagonal)*700),40);
                end
            end
            
            %   Mesh2d options, see
            %   http://www.mathworks.com/matlabcentral/fileexchange/10307
            %
            %   options.mlim   : The convergence tolerance. The maximum percentage
            %                    change in edge length per iteration must be less than
            %                    MLIM { 0.02, 2.0% }.
            %   options.maxit  : The maximum allowable number of iterations { 20 }.
            %   options.dhmax  : The maximum allowable (relative) gradient in the size
            %                    function { 0.3, 30.0% }.
            
            if nargin==6
                options.mlim=0.05;
                options.maxit=5;
                options.dhmax=0.6;
            else
                options.mlim=0.05;
                options.maxit=2;
                options.dhmax=0.4;
            end
            
            NN=cumsum(NN);
            
            NNfull=[0 NN];
            
            UV=zeros(2,NN(n2+1));
            
            umin=ParameterData{srfind}.u(1);
            umax=ParameterData{srfind}.u(2);
            vmin=ParameterData{srfind}.v(1);
            vmax=ParameterData{srfind}.v(2);
            
            if ParameterData{ind}.n1
                UV(:,1:NO)=retCrv(ParameterData,ParameterData{ind}.pto,NO,2);
            else
                UV(1,1:nO)=linspace(umin,umax-(umax-umin)/nO,nO);
                UV(2,1:nO)=vmin*ones(1,nO);
                UV(1,(nO+1):(2*nO))=umax*ones(1,nO);
                UV(2,(nO+1):(2*nO))=linspace(vmin,vmax-(vmax-vmin)/nO,nO);
                UV(1,(2*nO+1):(3*nO))=linspace(umax,umin+(umax-umin)/nO,nO);
                UV(2,(2*nO+1):(3*nO))=vmax*ones(1,nO);
                UV(1,(3*nO+1):(4*nO))=umin*ones(1,nO);
                UV(2,(3*nO+1):(4*nO))=linspace(vmax,vmin+(vmax-vmin)/nO,nO);
            end
            
            for j=1:n2
                UV(:,(NN(j)+1):NN(j+1))=retCrv(ParameterData,ParameterData{ind}.pti(j),(NN(j+1)-NN(j)),2);
            end
            
            P=nrbevalIGES(ParameterData{ParameterData{ind}.pts}.nurbs,UV);
            
            cmp=(ParameterData{srfind}.u(2)-ParameterData{srfind}.u(1))/(ParameterData{srfind}.v(2)-ParameterData{srfind}.v(1));
            
            if and(or(cmp>30,cmp<1/30),n2==0)
                ver=char(version);
                vernum=str2num(ver(1:3));

                if vernum>6.99
                    try
                        TRI = delaunay(UV(1,:),UV(2,:),{'Qt','Qbb','Qc','Pp'});
                    catch
                        TRI = delaunay(UV(1,:),UV(2,:),{'Qt','Qbb','Qc','Qz'});
                    end
                else
                    warning off all
                    dd=sqrt((umax-umin)^2+(vmax-vmin)^2);
                    TRI = delaunay(UV(1,:),UV(2,:),dd*1e-4);
                end

                [mTRI,nTRI]=size(TRI);

                isInside=logical(ones(mTRI,1));

                for j=1:mTRI
                    soTRIj=sort(TRI(j,:));
                    deTRIj=det([(UV(:,soTRIj(2))-UV(:,soTRIj(1))) (UV(:,soTRIj(3))-UV(:,soTRIj(1)))]);
                    if deTRIj<1e-12
                        isInside(j)=0;
                    elseif norm(UV(:,soTRIj(2))-UV(:,soTRIj(1)))>0.3*max(umax-umin,vmax-vmin)
                        isInside(j)=0;
                    elseif norm(UV(:,soTRIj(3))-UV(:,soTRIj(1)))>0.3*max(umax-umin,vmax-vmin)
                        isInside(j)=0;                        
                    end
                end
                
                TRI=TRI(isInside,:);
                
            else
                
                crvtr=zeros(1,NN(end));
                
                for j=1:(1+n2)
                    
                    vecBase=P(:,NNfull(j+1))-P(:,NNfull(j)+2);
                    vecComp=P(:,NNfull(j)+1)-P(:,NNfull(j)+2);
                    vernum=norm(vecBase);
                    if vernum>1e-5
                        vecBase=vecBase/vernum;
                    end
                    vecComp=vecComp-dot(vecBase,vecComp)*vecBase;
                    crvtr(NNfull(j)+1)=norm(vecComp);
                    
                    vecBase=P(:,NNfull(j+1)-1)-P(:,NNfull(j)+1);
                    vecComp=P(:,NNfull(j+1))-P(:,NNfull(j)+1);
                    vernum=norm(vecBase);
                    if vernum>1e-5
                        vecBase=vecBase/vernum;
                    end
                    vecComp=vecComp-dot(vecBase,vecComp)*vecBase;
                    crvtr(NNfull(j+1))=norm(vecComp);
                    
                    for i=(NNfull(j)+2):(NNfull(j+1)-1)
                        vecBase=P(:,i-1)-P(:,i+1);
                        vecComp=P(:,i)-P(:,i+1);
                        vernum=norm(vecBase);
                        if vernum>1e-5
                            vecBase=vecBase/vernum;
                        end
                        vecComp=vecComp-dot(vecBase,vecComp)*vecBase;
                        crvtr(i)=norm(vecComp);
                    end
                end
                
                crvtr2=crvtr;
                
                for j=1:(1+n2)
                    crvtr2((NNfull(j)+2):(NNfull(j+1)-1))=crvtr2((NNfull(j)+2):(NNfull(j+1)-1))-0.5*crvtr((NNfull(j)+1):(NNfull(j+1)-2))-0.5*crvtr((NNfull(j)+3):NNfull(j+1));
                    crvtr2(NNfull(j)+1)=crvtr2(NNfull(j)+1)-0.5*crvtr(NNfull(j)+2)-0.5*crvtr(NNfull(j+1));
                    crvtr2(NNfull(j+1))=crvtr2(NNfull(j+1))-0.5*crvtr(NNfull(j)+1)-0.5*crvtr(NNfull(j+1)-1);
                end
                
                keepP=logical(ones(NN(end),1));
                
                maxCr2=0.4*max(crvtr2);
                addcrv=0.005*maxCr2;
                
                wg1=0.4;
                wg2=0.71;
                
                for j=1:(1+n2)
                    for i=1:ceil(0.65*(NNfull(j+1)-NNfull(j)))
                        [so,soind]=sort(crvtr((NNfull(j)+1):NNfull(j+1)));
                        for k=1:(NNfull(j+1)-NNfull(j))
                            if keepP(NNfull(j)+soind(k))
                                miind=soind(k);
                                break
                            end
                        end
                        
                        if crvtr2(NNfull(j)+miind)>maxCr2
                            break
                        else
                            keepP(NNfull(j)+miind)=0;
                            if miind==1
                                crvtr(NNfull(j+1)-1)=crvtr(NNfull(j+1)-1)+wg1*crvtr(NNfull(j)+1)+wg1*addcrv;
                                crvtr(NNfull(j+1))=crvtr(NNfull(j+1))+wg2*crvtr(NNfull(j)+1)+addcrv;
                                crvtr(NNfull(j)+2)=crvtr(NNfull(j)+2)+wg2*crvtr(NNfull(j)+1)+addcrv;
                                crvtr(NNfull(j)+3)=crvtr(NNfull(j)+3)+wg1*crvtr(NNfull(j)+1)+wg1*addcrv;
                            elseif miind==(NNfull(j+1)-NNfull(j))
                                crvtr(NNfull(j+1)-2)=crvtr(NNfull(j+1)-2)+wg1*crvtr(NNfull(j+1))+wg1*addcrv;
                                crvtr(NNfull(j+1)-1)=crvtr(NNfull(j+1)-1)+wg2*crvtr(NNfull(j+1))+addcrv;
                                crvtr(NNfull(j)+1)=crvtr(NNfull(j)+1)+wg2*crvtr(NNfull(j+1))+addcrv;
                                crvtr(NNfull(j)+2)=crvtr(NNfull(j)+2)+wg1*crvtr(NNfull(j+1))+wg1*addcrv;
                            else
                                crvtr(NNfull(j)+miind-1)=crvtr(NNfull(j)+miind-1)+wg2*crvtr(NNfull(j)+miind)+addcrv;
                                crvtr(NNfull(j)+miind+1)=crvtr(NNfull(j)+miind+1)+wg2*crvtr(NNfull(j)+miind)+addcrv;
                                if miind==2
                                    crvtr(NNfull(j+1))=crvtr(NNfull(j+1))+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                    crvtr(NNfull(j)+4)=crvtr(NNfull(j)+4)+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                elseif miind==(NNfull(j+1)-NNfull(j)-1)
                                    crvtr(NNfull(j+1)-3)=crvtr(NNfull(j+1)-3)+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                    crvtr(NNfull(j)+1)=crvtr(NNfull(j)+1)+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                else
                                    crvtr(NNfull(j)+miind-2)=crvtr(NNfull(j)+miind-2)+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                    crvtr(NNfull(j)+miind+2)=crvtr(NNfull(j)+miind+2)+wg1*crvtr(NNfull(j)+miind)+wg1*addcrv;
                                end
                            end
                        end
                    end
                    NN(j)=sum(keepP((NNfull(j)+1):NNfull(j+1)));
                end
                NN=cumsum(NN);
                
                NNfull=[0 NN];
                crvtr2=crvtr2(keepP);
                
                clear NNfull
                
                UV=UV(:,keepP);
                
                edge = [(1:(NN(1)-1))' (2:NN(1))';NN(1) 1];
                
                for j=2:(n2+1)
                    edge = [edge;((NN(j-1)+1):(NN(j)-1))' ((NN(j-1)+2):NN(j))';NN(j) NN(j-1)+1];
                end

                [qtree.p,qtree.t,qtree.h] = quadtree(UV',edge,[],options.dhmax);
           
                % Discretise edges
                pbnd = boundarynodes(qtree.p,qtree.t,qtree.h,UV',edge);
                
                % Mesh kth polygon
                [UV,TRI] = meshpoly(UV',edge,qtree,pbnd,options);

                % % Ensure consistent, CCW ordered triangulation
                % [UV,TRI] = fixmesh(UV',TRI,[],[]);

                P=nrbevalIGES(ParameterData{ParameterData{ind}.pts}.nurbs,UV);
                
            end
            
        else
            P=zeros(3,0);
            isSCP=0;
            isSup=0;
            TRI=zeros(0,3);
            UV=zeros(2,0);
            srfind=0;
        end
        
    else
        P=zeros(3,0);
        isSCP=0;
        isSup=0;
        TRI=zeros(0,3);
        UV=zeros(2,0);
        srfind=0;
    end
    
elseif SCP==2       % CURVE
    
    if isSup
        if ParameterData{ind}.type==110 | ParameterData{ind}.type==126
            
            isSCP=1;
            
            if ParameterData{ind}.superior
                P=zeros(3,0);
                TRI=0;
            else
                P=retCrv(ParameterData,ind,n,dim);
                isSup=0;
                TRI=0;
            end
        else
            P=zeros(3,0);
            isSup=1;
            TRI=0;
        end
        
        UV=0;
        srfind=0;
        
    else
        if nargout>3
            [P,TRI,UV]=retCrv(ParameterData,ind,n,dim);
        else
            P=retCrv(ParameterData,ind,n,dim);
            TRI=0;
            UV=0;
        end
        
        if not(isempty(P))
            isSCP=1;
        end
        
    end
    
    srfind=0;
    
elseif SCP==3       % POINT
    
    if ParameterData{ind}.type==116
        P=ParameterData{ind}.p;
        isSCP=1;
        isSup=0;
        TRI=0;
    else
        P=zeros(3,1);
        isSCP=0;
        isSup=1;
        TRI=0;
    end
    
    UV=0;
    srfind=0;
    
end


function [rCrv,crvind,crvindred]=retCrv(ParameterData,ind,n,dim)

if ParameterData{ind}.type==142
    
    if nargout==1
        rCrv=retCrv(ParameterData,ParameterData{ind}.bptr,n,dim);
    else
        [rCrv,crvind,crvindred]=retCrv(ParameterData,ParameterData{ind}.bptr,n,dim);
    end
    
elseif ParameterData{ind}.type==102
    
    nvecF=(n/(ParameterData{ind}.length))*(ParameterData{ind}.lengthcnt);
    nvecI=floor(nvecF);
    nrest=n-sum(nvecI);
    nvecre=nvecI-nvecF;
    
    [so,in]=sort(nvecre);
    nvecI(in(1:nrest))=nvecI(in(1:nrest))+1;
    
    rCrv=zeros(dim,n);
    
    if nargout==1
        
        stind=1;
        for i=1:(ParameterData{ind}.n)
            if nvecI(i)>0
                endind=stind+nvecI(i)-1;
                rCrv(:,stind:endind)=retCrv(ParameterData,ParameterData{ind}.de(i),nvecI(i),dim);
                stind=endind+1;
            end
        end
        
    else
        
        crvind=zeros(1,n);
        crvindred=ParameterData{ind}.de;
        stind=1;
        for i=1:(ParameterData{ind}.n)
            if nvecI(i)>0
                endind=stind+nvecI(i)-1;
                [rCrv(:,stind:endind),crvind(stind:endind)]=retCrv(ParameterData,ParameterData{ind}.de(i),nvecI(i),dim);
                stind=endind+1;
            end
        end
        
    end
    
elseif ParameterData{ind}.type==110
    
    if dim==2
        rCrv=zeros(dim,n);
        if nargout==1
            tvec=linspace(0,(1-1/n),n);
            tvec(2:n)=tvec(2:n)+(rand(1,(n-1))-0.5)/(7*n);
        else
            tvec=linspace(0,1,n);
        end
    else
        rCrv=zeros(dim,n);
        tvec=linspace(0,1,n);
    end
    
    rCrv(1,:)=ParameterData{ind}.x1+tvec*(ParameterData{ind}.x2-ParameterData{ind}.x1);
    rCrv(2,:)=ParameterData{ind}.y1+tvec*(ParameterData{ind}.y2-ParameterData{ind}.y1);
    
    if dim>2
        rCrv(3,:)=ParameterData{ind}.z1+tvec*(ParameterData{ind}.z2-ParameterData{ind}.z1);
    end
    
    if nargout>1
        crvind=ind*ones(1,n);
        crvindred=ind;
    end
    
elseif ParameterData{ind}.type==126
    
    tvec=zeros(1,n);
    
    tst=ParameterData{ind}.v(1);
    ten=ParameterData{ind}.v(2);
    
    if dim==2
        if nargout==1
            tvec=linspace(tst,ten-(ten-tst)/n,n);
            tvec(2:n)=tvec(2:n)+(rand(1,(n-1))-0.5)*((ten-tst)/(7*n));
        else
            tvec=linspace(tst,ten,n);
        end
    else
        tvec=linspace(tst,ten,n);
    end
    
    p=nrbevalIGES(ParameterData{ind}.nurbs,tvec);
    
    rCrv=p(1:dim,:);
    
    if nargout>1
        crvind=ind*ones(1,n);
        crvindred=ind;
    end
    
else
    rCrv=zeros(dim,0);
    
    if nargout>1
        crvind=ind*ones(1,0);
        crvindred=ind;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = boundarynodes(ph,th,hh,node,edge)

% Discretise the geometry based on the edge size requirements interpolated
% from the background mesh.

p = node;
e = edge;
i = tsearch(ph(:,1),ph(:,2),th,p(:,1),p(:,2));
h = tinterp(ph,th,hh,p,i);

iter = 1;
while true
    
    % Edge length
    dxy = p(e(:,2),:)-p(e(:,1),:);
    L = sqrt(sum(dxy.^2,2));
    % Size function on edges
    he = 0.5*(h(e(:,1))+h(e(:,2)));
    % Split long edges
    ratio = L./he;
    split = (ratio>=1.5);
    if any(split)
        % Split edge at midpoint
        n1 = e(split,1);
        n2 = e(split,2);
        pm = 0.5*(p(n1,:)+p(n2,:));
        n3 = (1:size(pm,1))' + size(p,1);
        % New lists
        e(split,:) = [n1,n3];
        e = [e; n3,n2];
        p = [p; pm];
        % Size function at new nodes
        i = mytsearch(ph(:,1),ph(:,2),th,pm(:,1),pm(:,2),[]);
        h = [h; tinterp(ph,th,hh,pm,i)];
    else
        break
    end
    iter = iter+1;
end

% Node-to-edge connectivity matrix
ne = size(e,1);
S = sparse(e(:),[1:ne,1:ne],[-ones(ne,1); ones(ne,1)],size(p,1),ne);

% Smooth bounday nodes
del = 0.0;
tol = 0.02;
maxit = 50;
i = zeros(size(p,1),1);
for iter = 1:maxit
    
    delold = del;
    
    % Spring based smoothing
    F = he./L-1.0;
    F = S*(dxy.*[F,F]);
    F(1:size(node,1),:) = 0.0;
    p = p+0.2*F;
    
    % Convergence
    dxy = p(e(:,2),:)-p(e(:,1),:);
    Lnew = sqrt(sum(dxy.^2,2));
    del = norm((Lnew-L)./Lnew,'inf');
    if (del<tol)
        break;
    end
    L = Lnew;
    
    if (del>delold)
        % Interpolate required size at new P
        i = mytsearch(ph(:,1),ph(:,2),th,p(:,1),p(:,2),i);
        h = tinterp(ph,th,hh,p,i);
        he = 0.5*(h(e(:,1))+h(e(:,2)));
    end
    
end

function [p,t,h] = quadtree(node,edge,hdata,dhmax)

%  QUADTREE: 2D quadtree decomposition of polygonal geometry.
%
% The polygon is first rotated so that the minimal enclosing rectangle is
% aligned with the Cartesian XY axes. The long axis is aligned with Y. This
% ensures that the quadtree generated for a geometry input that has
% undergone arbitrary rotations in the XY plane is always the same.
%
% The bounding box is recursively subdivided until the dimension of each
% box matches the local geometry feature size. The geometry feature size is
% based on the minimum distance between linear geometry segments.
%
% A size function is obtained at the quadtree vertices based on the minimum
% neighbouring box dimension at each vertex. This size function is gradient
% limited to produce a smooth function.
%
% The quadtree is triangulated to form a background mesh, such that the
% size function may be obtained at any XY position within the domain via
% triangle based linear interpolation. The triangulation is done based on
% the quadtree data structures directly (i.e. NOT using Qhull) which is
% more reliable and produces a consistently oriented triangulation.
%
% The initial rotations are undone.
%
%  node  : [x1,y1; x2,y2; etc] geometry vertices
%  edge  : [n11,n12; n21,n22; etc] geometry edges as connections in NODE
%  hdata : User defined size function structure
%  dhmax : Maximum allowalble relative gradient in the size function
%  wbar  : Handle to progress bar from MESH2D
%
%   p    : Background mesh nodes
%   t    : Background mesh triangles
%   h    : Size function value at p

%   Darren Engwirda : 2007
%   Email           : d_engwirda@hotmail.com
%   Last updated    : 18/11/2007 with MATLAB 7.0

% Bounding box
XYmax = max(node,[],1);
XYmin = min(node,[],1);

% Rotate NODE so that the long axis of the minimum bounding rectangle is
% aligned with the Y axis.
theta = minrectangle(node);
node = rotate(node,theta);

% Rotated XY edge endpoints
edgexy = [node(edge(:,1),:), node(edge(:,2),:)];

% LOCAL FEATURE SIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get size function data
% [hmax,edgeh,fun,args] = gethdata(hdata);

% Insert test points along the boundaries at which the LFS can be
% approximated.
wm = 0.5*(edgexy(:,[1,2])+edgexy(:,[3,4]));                                % Use the edge midpoints as a first pass
len = sqrt(sum((edgexy(:,[3,4])-edgexy(:,[1,2])).^2,2));                   % Edge length
L = 2.0*dist2poly(wm,edgexy,2.0*len);                                      % Estimate the LFS at these points by calculating
% the distance to the closest edge segment
% In cases where edges are separated by less than their length
% we will need to add more points to capture the LFS in these
% regions. This allows us to pick up "long and skinny" geometry
% features
r = 2.0*len./L;                                                            % Compare L (LFS approximation at wm) to the edge lengths
r = round((r-2.0)/2.0);                                                    % Amount of points that need to be added
add = find(r);                                                             % at each edge
if ~isempty(add)
    num = 2*sum(r(add));                                                    % Total number of points to be added
    start = size(wm,1)+1;
    wm = [wm; zeros(num,2)];                                                % Alloc space
    L = [L; zeros(num,1)];
    next = start;
    for j = 1:length(add)                                                   % Loop through edges to be subdivided
        
        ce = add(j);                                                         % Current edge
        num = r(ce);
        tmp = (1:num)'/(num+1);                                              % Subdivision increments
        num = next+2*num-1;
        
        x1 = edgexy(ce,1); x2 = edgexy(ce,3); xm = wm(ce,1);                 % Edge values
        y1 = edgexy(ce,2); y2 = edgexy(ce,4); ym = wm(ce,2);
        
        wm(next:num,:) = [x1+tmp*(xm-x1), y1+tmp*(ym-y1)                     % Add to list
            xm+tmp*(x2-xm), ym+tmp*(y2-ym)];
        
        L(next:num) = L(ce);                                                 % Upper bound on LFS
        
        next = num+1;
        
    end
    L(start:end) = dist2poly(wm(start:end,:),edgexy,L(start:end));          % Estimate LFS at the new points
end

% Compute the required size along the edges for any boundary layer size
% functions and add additional points where necessary.
% if ~isempty(edgeh)
%     for j = 1:size(edgeh,1)
%         if L(edgeh(j,1))>=edgeh(j,2)
%             
%             cw = edgeh(j,1);
%             r = 2.0*len(cw)/edgeh(j,2);
%             r = ceil((r)/2.0);                                          % Number of points to be added
%             tmp = (1:r-1)'/r;
%             
%             x1 = edgexy(cw,1); x2 = edgexy(cw,3); xm = wm(cw,1);              % Edge values
%             y1 = edgexy(cw,2); y2 = edgexy(cw,4); ym = wm(cw,2);
%             
%             wm = [wm; x1+tmp*(xm-x1), y1+tmp*(ym-y1);                         % Add to list
%                 xm+tmp*(x2-xm), ym+tmp*(y2-ym)];
%             
%             L(cw) = edgeh(j,2);                                                    % Update LFS
%             L = [L; edgeh(j,2)*ones(2*length(tmp),1)];
%             
%         end
%     end
% end

% To speed the point location in the quadtree decomposition
% sort the LFS points based on y-value
[i,i] = sort(wm(:,2));
wm = wm(i,:);
L = L(i);
nw = size(wm,1);

% UNBALANCED QUADTREE DECOMPOSITION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xymin = min([edgexy(:,[1,2]); edgexy(:,[3,4])]);                           % Bounding box
xymax = max([edgexy(:,[1,2]); edgexy(:,[3,4])]);

dim = 2.0*max(xymax-xymin);                                                    % Bbox dimensions
xm = 0.5*(xymin(1)+xymax(1));
ym = 0.5*(xymin(2)+xymax(2));

% Setup boxes with a consistent CCW node order
%  b(k,1) = n1 : bottom left
%  b(k,2) = n2 : bottom right
%  b(k,3) = n3 : top right
%  b(k,4) = n4 : top left

% Start with bbox
p = [xm-0.5*dim, ym-0.5*dim
    xm+0.5*dim, ym-0.5*dim
    xm+0.5*dim, ym+0.5*dim
    xm-0.5*dim, ym+0.5*dim];
b = [1,2,3,4];

% User defined size functions
pr = rotate(p,-theta);
h = inf*ones(size(pr,1),1);

pblock = 5*nw;                                                             % Alloc memory in blocks
bblock = pblock;

np = size(p,1);
nb = size(b,1);
test = true(nb,1);
while true                                                           
   
   vec = find(test(1:nb));                                                 % Boxes to be checked at this step
   if isempty(vec)
      break
   end

   N = np;
   for k = 1:length(vec)                                                   % Loop through boxes to be checked for subdivision
      
      m  = vec(k);                                                         % Current box

      n1 = b(m,1);   n2 = b(m,2);                                          % Corner nodes
      n3 = b(m,3);   n4 = b(m,4);
      x1 = p(n1,1);  y1 = p(n1,2);                                         % Corner xy
      x2 = p(n2,1);  y4 = p(n4,2);

      % Binary search to find first wm with y>=ymin for current box
      if wm(1,2)>=y1
         start = 1;
      elseif wm(nw,2)<y1
         start = nw+1;
      else
         lower = 1;
         upper = nw;
         for i = 1:nw
            start = round(0.5*(lower+upper));
            if wm(start,2)<y1
               lower = start;
            elseif wm(start-1,2)<y1
               break;
            else
               upper = start;
            end
         end
      end
      
      % Init LFS as the min of corner user defined size function values
      LFS = 1.5*h(n1);
      if 1.5*h(n2)<LFS, LFS = 1.5*h(n2); end
      if 1.5*h(n3)<LFS, LFS = 1.5*h(n3); end
      if 1.5*h(n4)<LFS, LFS = 1.5*h(n4); end

      % Loop through all WM in box and take min LFS
      for i = start:nw                                                     % Loop through points (acending y-value order)
         if (wm(i,2)<=y4)                                                  % Check box bounds and current min
            if (wm(i,1)>=x1) && (wm(i,1)<=x2) && (L(i)<LFS)
               LFS = L(i);                                                 % New min found - reset
            end
         else                                                              % Due to the sorting
            break;
         end
      end

      % Split box into 4
      if (x2-x1)>=LFS 
         
         if (np+5)>=size(p,1)                                              % Alloc memory on demand
            p = [p; zeros(pblock,2)];
            pblock = 2*pblock;
         end
         if (nb+3)>=size(b,1)
            b = [b; zeros(bblock,4)];
            test = [test; true(bblock,1)];
            bblock = 2*bblock;
         end

         xm = x1+0.5*(x2-x1);                                              % Current midpoints
         ym = y1+0.5*(y4-y1);

         % New nodes
         p(np+1,1) = xm;   p(np+1,2) = ym;
         p(np+2,1) = xm;   p(np+2,2) = y1;
         p(np+3,1) = x2;   p(np+3,2) = ym;
         p(np+4,1) = xm;   p(np+4,2) = y4;
         p(np+5,1) = x1;   p(np+5,2) = ym;   

         % New boxes
         b(m,1)      = n1;               % Box 1
         b(m,2)      = np+2;
         b(m,3)      = np+1;
         b(m,4)      = np+5;
         b(nb+1,1)   = np+2;             % Box 2
         b(nb+1,2)   = n2;
         b(nb+1,3)   = np+3;
         b(nb+1,4)   = np+1;
         b(nb+2,1)   = np+1;             % Box 3
         b(nb+2,2)   = np+3;
         b(nb+2,3)   = n3;
         b(nb+2,4)   = np+4;
         b(nb+3,1)   = np+5;             % Box 4
         b(nb+3,2)   = np+1;
         b(nb+3,3)   = np+4;
         b(nb+3,4)   = n4;

         nb = nb+3;
         np = np+5;
      else
         test(m) = false;
      end
   end

   % User defined size function at new nodes
   pr = rotate(p(N+1:np,:),-theta);
   h = [h; inf*ones(size(pr,1),1);];

end
p = p(1:np,:);
b = b(1:nb,:);

% Remove duplicate nodes
[p,i,j] = unique(p,'rows');                               
h = h(i);
b = reshape(j(b),size(b));

% FORM SIZE FUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Unique edges
e = unique(sort([b(:,[1,2]); b(:,[2,3]); b(:,[3,4]); b(:,[4,1])],2),'rows');
L = sqrt(sum((p(e(:,1),:)-p(e(:,2),:)).^2,2));                             % Edge length

ne = size(e,1);
for k = 1:ne                                                               % Initial h - minimum neighbouring edge length
   Lk = L(k);
   if Lk<h(e(k,1)), h(e(k,1)) = Lk; end             
   if Lk<h(e(k,2)), h(e(k,2)) = Lk; end
end

% Gradient limiting
tol = 1.0e-06;
while true                                                                 % Loop over the edges of the background mesh ensuring
   h_old = h;                                                              % that dh satisfies the dhmax tolerance
   for k = 1:ne                                                            % Loop over edges
      n1 = e(k,1);
      n2 = e(k,2);
      Lk = L(k);
      if h(n1)>h(n2)                                                       % Ensure grad(h)<=dhmax
         dh = (h(n1)-h(n2))/Lk;
         if dh>dhmax
            h(n1) = h(n2) + dhmax*Lk;
         end
      else
         dh = (h(n2)-h(n1))/Lk;
         if dh>dhmax
            h(n2) = h(n1) + dhmax*Lk;
         end
      end
   end
   if norm((h-h_old)./h,'inf')<tol                                         % Test convergence
      break
   end
end

% TRIANGULATE QUADTREE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if size(b,1)==1
   % Split box diagonally into 2 tri's
   t = [b(1),b(2),b(3); b(1),b(3),b(4)];
else

   % Get node-to-node connectivity
   % First column is column count per row
   % Max neighbours is 8 due to quadtree setup
   n2n = zeros(size(p,1),9);
   for k = 1:size(e,1)
      % Nodes in kth edge
      n1 = e(k,1);
      n2 = e(k,2);
      % Indexing
      n2n(n1,1) = n2n(n1,1)+1;                                             % Node 1
      n2n(n1,n2n(n1,1)+1) = n2;
      n2n(n2,1) = n2n(n2,1)+1;                                             % Node 2
      n2n(n2,n2n(n2,1)+1) = n1;
   end

   % Check for regular boxes with no mid-side nodes
   num = n2n(:,1)<=4;
   reg = all(num(b),2);

   % Split regular boxes diagonally into 2 tri's
   t = [b(reg,[1,2,3]); b(reg,[1,3,4])];
  
   if ~all(reg)
      
      % Use the N2N connectivity to directly triangulate the quadtree
      % nodes. Some additional nodes may be added at the centroids of some
      % boxes to facilitate triangulation. The triangluation is not
      % necessarily Delaunay, but should always be high quality and
      % symmetric where possible.

      b = b(~reg,:);                                                       % Boxes that still need to be dealt with
      nb = size(b,1);
      nt = size(t,1);
      
      % Alloc space
      t = [t; zeros(5*nb,3)];                                              % Has to be a least 5 times as many tri's as boxes
      nlist = zeros(512,1);                                                % Shouldn't ever be exceeded!

      lim = 0.5*nb;
      for k = 1:nb
         
         if k>lim                                                          % Halfway!
            lim = nb+1;
         end

         % Corner nodes
         n1 = b(k,1); n2 = b(k,2);
         n3 = b(k,3); n4 = b(k,4);

         % Assemble node list for kth box in CCW order
         nlist(1) = n1;
         count = 1;
         next = 2;
         while true
            
            cn = nlist(next-1);

            % Find the closest node to CN travelling CCW around box
            old = inf;
            for j = 1:n2n(cn,1)
               nn = n2n(cn,j+1);
               dx = p(nn,1)-p(cn,1);
               dy = p(nn,2)-p(cn,2);
               if count==1                         % Edge 12
                  if (dx>0.0) && (dx<old)
                     old = dx;
                     tmp = nn;
                  end
               elseif count==2                     % Edge 23
                  if (dy>0.0) && (dy<old)
                     old = dy;
                     tmp = nn;
                  end
               elseif count==3                     % Edge 34
                  if (dx<0.0) && (abs(dx)<old)
                     old = abs(dx);
                     tmp = nn;
                  end
               else                                % Edge 41
                  if (dy<0.0) && (abs(dy)<old)
                     old = abs(dy);
                     tmp = nn;
                  end
               end

            end
            
            if tmp==n1                                                     % Back to start - Done!
               break
            elseif (count<4) && (tmp==b(k,count+1))                        % New edge
               count = count+1;
            end
            nlist(next) = tmp;
            next = next+1;
            
         end
         nnode = next-1;

         if (nt+nnode)>=size(t,1)                                          % Realloc memory on demand
            t = [t; zeros(nb,3)];
         end
         if (np+1)>=size(p,1)
            p = [p; zeros(nb,2)];
            h = [h; zeros(nb,1)];
         end
         
         % Triangulate box
         if nnode==4                                                       % Special treatment if no mid-side nodes
                                                                           % Split box diagonally into 2 tri's
            % New tri's
            t(nt+1,1) = n1;                     % t1
            t(nt+1,2) = n2;
            t(nt+1,3) = n3;
            t(nt+2,1) = n1;                     % t2
            t(nt+2,2) = n3;
            t(nt+2,3) = n4;
            
            % Update count
            nt = nt+2;
            
         elseif nnode==5                                                   % Special treatment if only 1 mid-side node
                                                                           % Split box into 3 tri's centred at mid-side node
            % Find the mid-side node
            j = 2;
            while j<=4
               if nlist(j)~=b(k,j)
                  break
               end
               j = j+1;
            end
           
            % Permute indexing so that the split is always between n1,n2
            if j==3
               n1 = b(k,2);   n2 = b(k,3);
               n3 = b(k,4);   n4 = b(k,1);
            elseif j==4
               n1 = b(k,3);   n2 = b(k,4);
               n3 = b(k,1);   n4 = b(k,2);
            elseif j==5
               n1 = b(k,4);   n2 = b(k,1);
               n3 = b(k,2);   n4 = b(k,3);
            end
            
            % New tri's
            t(nt+1,1) = n1;                     % t1
            t(nt+1,2) = nlist(j);
            t(nt+1,3) = n4;
            t(nt+2,1) = nlist(j);               % t2
            t(nt+2,2) = n2;
            t(nt+2,3) = n3;
            t(nt+3,1) = n4;                     % t3
            t(nt+3,2) = nlist(j);
            t(nt+3,3) = n3;

            % Update count
            nt = nt+3;
            
         else                                                              % Connect all mid-side nodes to an additional node
                                                                           % introduced at the centroid
            % New tri's
            xave = 0.0;
            yave = 0.0;
            have = 0.0;
            for j = 1:nnode-1
               jj = nlist(j);
               % New tri's
               t(nt+j,1) = jj;
               t(nt+j,2) = np+1;
               t(nt+j,3) = nlist(j+1);
               % Averaging
               xave = xave+p(jj,1);
               yave = yave+p(jj,2);
               have = have+h(jj);
            end
            jj = nlist(nnode);
            % Last tri
            t(nt+nnode,1) = jj;
            t(nt+nnode,2) = np+1;
            t(nt+nnode,3) = nlist(1);
            % New node
            p(np+1,1)   = (xave+p(jj,1)) /nnode;
            p(np+1,2)   = (yave+p(jj,2)) /nnode;
            h(np+1)     = (have+h(jj))   /nnode;

            % Update count
            nt = nt+nnode;
            np = np+1;

         end

      end
      p = p(1:np,:);
      h = h(1:np);
      t = t(1:nt,:);

   end

end

% Undo rotation
p = rotate(p,-theta);


%% SUB-FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function theta = minrectangle(p)

% Find the rotation angle that must be applied to the 2D points in P so
% that the long axis of the minimum bounding rectangle is aligned with the
% Y axis.

n = size(p,1);
% if numel(p)~=2*n
%    error('P must be an Nx2 array');
% end

if n>2
    
    % Convex hull edge segments
    e = convhulln(p);
    
    % Keep convex points
    i = unique(e(:));
    p = p(i,:);
    
    % Re-index to keep E consistent
    j = zeros(size(p,1),1);
    j(i) = 1;
    j = cumsum(j);
    e = j(e);
    
    % Angles of hull segments
    dxy = p(e(:,2),:)-p(e(:,1),:);
    ang = atan2(dxy(:,2),dxy(:,1));
    
    % Check all hull edge segments
    Aold = inf;
    for k = 1:size(e,1)
        % Rotate through -ang(k)
        pr = rotate(p,-ang(k));
        % Compute area of bounding rectangle and save if better
        dxy = max(pr,[],1)-min(pr,[],1);
        A = dxy(1)*dxy(2);
        if A<Aold
            Aold = A;
            theta = -ang(k);
        end
    end
    
    % Check result to ensure that the long axis is aligned with Y
    pr = rotate(p,theta);
    dxy = max(pr,[],1)-min(pr,[],1);
    if dxy(1)>dxy(2)
        % Need to flip XY
        theta = theta+0.5*pi;
    end
    
else
    % 1 or 2 points, degenerate bounding rectangle in either case
    theta = 0.0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = rotate(p,theta)

% Rotate the 2D points in P through the angle THETA (radians).

stheta = sin(theta);
ctheta = cos(theta);

p = p*[ctheta, stheta; -stheta, ctheta];

function L = dist2poly(p,edgexy,lim)

% Find the minimum distance from the points in P to the polygon defined by
% the edges in EDGEXY. LIM is an optional argument that defines an upper
% bound on the distance for each point.

% Uses (something like?) a double sweep-line approach to reduce the number
% of edges that are required to be tested in order to determine the closest
% edge for each point. On average only size(EDGEXY)/4 comparisons need to
% be made for each point.

% if nargin<3
%    lim = [];
% end
np = size(p,1);
ne = size(edgexy,1);
if isempty(lim)
   lim = inf*ones(np,1);
end

% Choose the direction with the biggest range as the "y-coordinate" for the
% test. This should ensure that the sorting is done along the best
% direction for long and skinny problems wrt either the x or y axes.
dxy = max(p)-min(p);
if dxy(1)>dxy(2)
    % Flip co-ords if x range is bigger
    p       = p(:,[2,1]);
    edgexy  = edgexy(:,[2,1,4,3]);
end

% Ensure edgexy(:,[1,2]) contains the lower y value
swap           = edgexy(:,4)<edgexy(:,2);
edgexy(swap,:) = edgexy(swap,[3,4,1,2]);

% Sort edges
[i,i]          = sort(edgexy(:,2));                                        % Sort edges by lower y value
edgexy_lower   = edgexy(i,:);
[i,i]          = sort(edgexy(:,4));                                        % Sort edges by upper y value
edgexy_upper   = edgexy(i,:);

% Mean edge y value
ymean = 0.5*( sum(sum(edgexy(:,[2,4]))) )/ne;

% Alloc output
L = zeros(np,1);

% Loop through points
tol = 1000.0*eps*max(dxy);
for k = 1:np
    
    x = p(k,1);
    y = p(k,2);
    d = lim(k);
    
    if y<ymean
        
        % Loop through edges bottom up
        for j = 1:ne
            y2 = edgexy_lower(j,4);
            if y2>=(y-d)
                y1 = edgexy_lower(j,2);
                if y1<=(y+d)
                    
                    x1 = edgexy_lower(j,1);
                    x2 = edgexy_lower(j,3);
                    
                    if x1<x2
                        xmin = x1;
                        xmax = x2;
                    else
                        xmin = x2;
                        xmax = x1;
                    end
                    
                    if xmin<=(x+d) && xmax>=(x-d)
                        % Calculate the distance along the normal projection from [x,y] to the jth edge
                        x2mx1 = x2-x1;
                        y2my1 = y2-y1;
                        
                        r = ((x-x1)*x2mx1+(y-y1)*y2my1)/(x2mx1^2+y2my1^2);
                        if r>1.0                                                 % Limit to wall endpoints
                            r = 1.0;
                        elseif r<0.0
                            r = 0.0;
                        end
                        
                        dj = (x1+r*x2mx1-x)^2+(y1+r*y2my1-y)^2;
                        if (dj<d^2) && (dj>tol)
                            d = sqrt(dj);
                        end
                        
                    end
                    
                else
                    break
                end
            end
        end
        
    else
        
        % Loop through edges top down
        for j = ne:-1:1
            y1 = edgexy_upper(j,2);
            if y1<=(y+d)
                y2 = edgexy_upper(j,4);
                if y2>=(y-d)
                    
                    x1 = edgexy_upper(j,1);
                    x2 = edgexy_upper(j,3);
                    
                    if x1<x2
                        xmin = x1;
                        xmax = x2;
                    else
                        xmin = x2;
                        xmax = x1;
                    end
                    
                    if xmin<=(x+d) && xmax>=(x-d)
                        % Calculate the distance along the normal projection from [x,y] to the jth edge
                        x2mx1 = x2-x1;
                        y2my1 = y2-y1;
                        
                        r = ((x-x1)*x2mx1+(y-y1)*y2my1)/(x2mx1^2+y2my1^2);
                        if r>1.0                                                 % Limit to wall endpoints
                            r = 1.0;
                        elseif r<0.0
                            r = 0.0;
                        end
                        
                        dj = (x1+r*x2mx1-x)^2+(y1+r*y2my1-y)^2;
                        if (dj<d^2) && (dj>tol)
                            d = sqrt(dj);
                        end
                        
                    end
                    
                else
                    break
                end
            end
        end
        
    end
    
    L(k) = d;
    
end

function fi = tinterp(p,t,f,pi,i)

%  TINTERP: Triangle based linear interpolation.
%
%  fi = tinterp(p,t,f,pi,i);
%
%  p  : Nx2 array of nodal XY coordinates, [x1,y1; x2,y2; etc]
%  t  : Mx3 array of triangles as indices, [n11,n12,n13; n21,n22,n23; etc]
%  f  : Nx1 function vector, f(x,y)
%  pi : Jx2 matrix of interpolation points
%  fi : Jx1 interpolant function vector, fi(xi,yi)
%
% Performs nearest-neighbour extrapolation for points outside the
% triangulation.

% Darren Engwirda - 2005-2007

% Alloc output
fi = zeros(size(pi,1),1);

% Deal with points oustide convex hull
out = isnan(i);
if any(out)
    % Do nearest neighbour extrapolation for outside points
    d = dsearch(p(:,1),p(:,2),t,pi(out,1),pi(out,2));
    fi(out) = f(d);
end

% Keep internal points
pin = pi(~out,:);
tin = t(i(~out),:);

% Corner nodes
t1 = tin(:,1);
t2 = tin(:,2);
t3 = tin(:,3);

% Calculate areas
dp1 = pin-p(t1,:);
dp2 = pin-p(t2,:);
dp3 = pin-p(t3,:);
A3 = abs(dp1(:,1).*dp2(:,2)-dp1(:,2).*dp2(:,1));
A2 = abs(dp1(:,1).*dp3(:,2)-dp1(:,2).*dp3(:,1));
A1 = abs(dp3(:,1).*dp2(:,2)-dp3(:,2).*dp2(:,1));

% Linear interpolation
fi(~out) = (A1.*f(t1)+A2.*f(t2)+A3.*f(t3))./(A1+A2+A3);

function i = mytsearch(x,y,t,xi,yi,i)

%  MYTSEARCH: Find the enclosing triangle for points in a 2D plane.
%
%  i = mytsearch(x,y,t,xi,yi,iguess);
%
% The indices of the triangles enclosing the points in [XI,YI] are
% returned. The triangulation T of [X,Y] must be convex. Points lying
% outside the triangulation are assigned a NaN index.
%
% IGUESS is an optional initial guess for the indicies. A full search is
% done using the standard TSEARCH function for points with an invalid
% initial guess.

% Darren Engwirda - 2007.

% I/O and error checks

ni = size(xi,1);

% Translate to the origin and scale the min xy range onto [-1,1]
% This is absolutely critical to avoid precision issues for large problems!
maxxy = max([x,y]);
minxy = min([x,y]);
den = 0.5*min(maxxy-minxy);

x  = ( x-0.5*(minxy(1)+maxxy(1))) / den;
y  = ( y-0.5*(minxy(2)+maxxy(2))) / den;
xi = (xi-0.5*(minxy(1)+maxxy(1))) / den;
yi = (yi-0.5*(minxy(2)+maxxy(2))) / den;

% Check initial guess
if ~isempty(i)
    k = find(i>0 & ~isnan(i));
    
    tri = i(k);
    
    n1 = t(tri,1);
    n2 = t(tri,2);
    n3 = t(tri,3);
    
    ok = sameside(x(n1),y(n1),x(n2),y(n2),xi(k),yi(k),x(n3),y(n3)) & ...
        sameside(x(n2),y(n2),x(n3),y(n3),xi(k),yi(k),x(n1),y(n1)) & ...
        sameside(x(n3),y(n3),x(n1),y(n1),xi(k),yi(k),x(n2),y(n2));
    
    j = true(ni,1);
    j(k(ok)) = false;
else
    j = true(ni,1);
end

% Do a full search for points that failed
if any(j)
    i(j) = tsearch(x,y,t,xi(j),yi(j));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i = sameside(xa,ya,xb,yb,x1,y1,x2,y2)

% Test if [x1(i),y1(i)] and [x2(i),y2(i)] lie on the same side of the line
% AB(i).

dx = xb-xa;
dy = yb-ya;
a1 = (x1-xa).*dy-(y1-ya).*dx;
a2 = (x2-xa).*dy-(y2-ya).*dx;

% If sign(a1)=sign(a2) the points lie on the same side
i = false(length(xa),1);
i(a1.*a2>=0.0) = true;


function [p,t] = meshpoly(node,edge,qtree,p,options)

% MESHPOLY: Core meshing routine called by mesh2d and meshfaces.
%
% Do not call this routine directly, use mesh2d or meshfaces instead!
%
% Inputs:
%
%  NODE     : Nx2 array of geometry XY co-ordinates
%  EDGE     : Mx2 array of connections between NODE, defining geometry
%             edges
%  QTREE    : Quadtree data structure, defining background mesh and element
%             size function
%  P        : Qx2 array of potential boundary nodes
%  OPTIONS  : Meshing options data structure
%  WBAR     : Handle to progress bar
%
% Outputs:
%
%  P        : Nx2 array of triangle nodes
%  T        : Mx3 array of triangles as indices into P
%
% Mesh2d is a delaunay based algorithm with a "Laplacian-like" smoothing
% operation built into the mesh generation process.
%
% An unbalanced quadtree decomposition is used to evaluate the element size
% distribution required to resolve the geometry. The quadtree is
% triangulated and used as a backgorund mesh to store the element size
% data.
%
% The main method attempts to optimise the node location and mesh topology
% through an iterative process. In each step a constrained delaunay
% triangulation is generated with a series of "Laplacian-like" smoothing
% operations used to improve triangle quality. Nodes are added or removed
% from the mesh to ensure the required element size distribution is
% approximated.
%
% The optimisation process generally returns well shaped meshes with no
% small angles and smooth element size variations. Mesh2d shares some
% similarities with the Distmesh code:
%
%   [1] P.-O. Persson, G. Strang, A Simple Mesh Generator in MATLAB.
%       SIAM Review, Volume 46 (2), pp. 329-345, June 2004
%
%   Darren Engwirda : 2005-07
%   Email           : d_engwirda@hotmail.com
%   Last updated    : 22/01/2008 with MATLAB 7.0 (Mesh2d v2.3)
%
% Mesh2d is Copyright (C) 2006-2008 Darren Engwirda. See "copyright.m" for
% details.

shortedge   = 0.75;
longedge    = 1.5;
smalltri    = 0.25;
largetri    = 4.0;
qlimit      = 0.5;
dt          = 0.2;

% stats = struct('t_init',0.0,'t_tri',0.0,'t_inpoly',0.0,'t_edge',0.0, ...
%                   't_sparse',0.0,'t_search',0.0,'t_smooth',0.0,'t_density',0.0, ...
%                      'n_tri',0);

% Initialise mesh
%  P     : Initial nodes
%  T     : Initial triangulation
%  TNDX  : Enclosing triangle for each node as indices into TH
%  FIX   : Indices of FIXED nodes in P

[p,fix,tndx] = initmesh(p,qtree.p,qtree.t,qtree.h,node,edge);

% Main loop
for iter = 1:options.maxit
    
    [p,i,j] = unique(p,'rows');                                             % Ensure unique node list
    fix = j(fix);
    tndx = tndx(i);
    
    [p,t] = cdt(p,node,edge);                                               % Constrained Delaunay triangulation
    
    e = getedges(t,size(p,1));                                              % Unique edges
    
    % Sparse node-to-edge connectivity matrix
    nume = size(e,1);
    S = sparse(e(:),[1:nume,1:nume],[ones(nume,1); -ones(nume,1)],size(p,1),nume);
    
    tndx = mytsearch(qtree.p(:,1),qtree.p(:,2),qtree.t,p(:,1),p(:,2),tndx); % Find enclosing triangle in background mesh for nodes
    hn = tinterp(qtree.p,qtree.t,qtree.h,p,tndx);                           % Size function at nodes via linear interpolation
    h = 0.5*(hn(e(:,1))+hn(e(:,2)));                                        % from the background mesh. Average to edge midpoints.
    
    % Inner smoothing sub-iterations
    
    edgev = p(e(:,1),:)-p(e(:,2),:);
    L = max(sqrt(sum((edgev).^2,2)),eps);                                   % Edge lengths
    
    move = 1.0;
    done = false;
    for subiter = 1:(iter-1)
        
        moveold = move;
        
        % Spring based smoothing
        L0 = h*sqrt(sum(L.^2)/sum(h.^2));
        F = max(L0./L-1.0,-0.1);
        F = S*(edgev.*[F,F]);
        F(fix,:) = 0.0;
        p = p+dt*F;
        
        % Measure convergence
        edgev = p(e(:,1),:)-p(e(:,2),:);
        L0 = max(sqrt(sum((edgev).^2,2)),eps);                               % Edge lengths
        move = norm((L0-L)./L,'inf');                                        % Percentage change
        L = L0;
        
        if move<options.mlim                                                 % Test convergence
            done = true;
            break
        end
        
    end
    
    tndx = mytsearch(qtree.p(:,1),qtree.p(:,2),qtree.t,p(:,1),p(:,2),tndx);
    hn = tinterp(qtree.p,qtree.t,qtree.h,p,tndx);                           % Size function at nodes via linear interpolation
    h = 0.5*(hn(e(:,1))+hn(e(:,2)));                                        % from the background mesh. Average to edge midpoints.
    
    r = L./h;
    if done && (max(r)<3.0)                                                 % Main loop convergence
        break
    end
    
    % Nodal density control
    tic
    if iter<options.maxit
        % Estimate required triangle area from size function
        Ah = 0.5*tricentre(t,hn).^2;
        % Remove nodes
        i = find(abs(triarea(p,t))<smalltri*Ah);                             % Remove all nodes in triangles with small area
        k = find(sum(abs(S),2)<2);                                           % Nodes with less than 2 edge connections
        j = find(r<shortedge);                                               % Remove both nodes for short edges
        if ~isempty(j) || ~isempty(k) || ~isempty(i)
            prob = false(size(p,1),1);                                        % True for nodes to be removed
            prob(e(j,:)) = true;                                              % Edges with insufficient length
            prob(t(i,:)) = true;                                              % Triangles with insufficient area
            prob(k) = true;                                                   % Remove nodes with less than 2 edge connections
            prob(fix) = false;                                                % Don't remove fixed nodes
            pnew = p(~prob,:);                                                % New node list
            tndx = tndx(~prob);
            j = zeros(size(p,1),1);                                           % Re-index FIX to keep consistent
            j(~prob) = 1;
            j = cumsum(j);
            fix = j(fix);
        else
            pnew = p;
        end
        % Add new nodes
        i = abs(triarea(p,t))>largetri*Ah;                                   % Large triangles
        r = longest(p,t)./tricentre(t,hn);
        k = (r>longedge) & (quality(p,t)<qlimit);                            % Low quality triangles
        if any(i|k)
            
            k = find(k & ~i);
            i = find(i);
            
            % Add new nodes at circumcentres
            cc = circumcircle(p,[t(i,:); t(k,:)]);
            
            % Don't add multiple points in one circumcircle
            ok = [true(size(i)); false(size(k))];
            for ii = (length(i)+1):size(cc,1)
                % Current point
                x = cc(ii,1);
                y = cc(ii,2);
                % Check if inside any accepted circumcircles
                in = false;
                j = find(ok);
                for jj = 1:length(j)
                    kk = j(jj);
                    dx = (x-cc(kk,1))^2;
                    if dx<cc(kk,3) && (dx+(y-cc(kk,2))^2)<cc(kk,3)
                        in = true;
                        break;
                    end
                end
                if ~in
                    ok(ii) = true;
                end
            end
            cc = cc(ok,:);
            cc = cc(inpoly(cc(:,1:2),node,edge,1e-12),:);                           % Only take internal points
            
            % New arrays
            pnew = [pnew; cc(:,1:2)];
            tndx = [tndx; zeros(size(cc,1),1)];
        end
        p = pnew;
    end
    
end

% Ensure final triangulation is Delaunay
[p,t] = cdt(p,node,edge);
p=p';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p,t] = cdt(p,node,edge)

% Approximate geometry-constrained Delaunay triangulation.

warning off all

try
    t = delaunayn(p);
catch
    
    t = delaunayn(p,{'Pp','Qt','QbB','Qc','Qz'});
    warning on
end

% Delaunay triangulation via QHULL

% Impose geometry constraints
i = inpoly(tricentre(t,p),node,edge,1e-12);                                      % Take triangles with internal centroids
t = t(i,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p,fix,tndx] = initmesh(p,ph,th,hh,node,edge)

% Initialise the mesh nodes

% Boundary nodes for all geometry edges have been passed in. Only take
% those in the current face
i = findedge(p,node,edge,1.0e-08);
p = p(i>0,:);
fix = (1:size(p,1))';

% Initial nodes taken as fixed boundary nodes + internal nodes from
% quadtree.
[i,j] = inpoly(ph,node,edge,1e-12);
p = [p; ph(i&~j,:)];
tndx = zeros(size(p,1),1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e = getedges(t,n)

% Get the unique edges and boundary nodes in a triangulation.

e = sortrows( sort([t(:,[1,2]); t(:,[1,3]); t(:,[2,3])],2) );
idx = all(diff(e,1)==0,2);                                                 % Find shared edges
idx = [idx;false]|[false;idx];                                             % True for all shared edges
bnd = e(~idx,:);                                                           % Boundary edges
e = e(idx,:);                                                              % Internal edges
e = [bnd; e(1:2:end-1,:)];                                                 % Unique edges and bnd edges for tri's


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fc = tricentre(t,f)

% Interpolate nodal F to the centroid of the triangles T.

fc = (f(t(:,1),:)+f(t(:,2),:)+f(t(:,3),:))/3.0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = longest(p,t)

% Return the length of the longest edge in each triangle.

d1 = sum((p(t(:,2),:)-p(t(:,1),:)).^2,2);
d2 = sum((p(t(:,3),:)-p(t(:,2),:)).^2,2);
d3 = sum((p(t(:,1),:)-p(t(:,3),:)).^2,2);

d = sqrt(max([d1,d2,d3],[],2));

function enum = findedge(p,node,edge,TOL)

%  FINDEDGE: Locate points on edges.
%
% Determine which edges a series of points lie on in a 2D plane.
%
%  i = findedge(p,node,edge,tol);
%
% INPUTS
%
%  P     : An Nx2 array of xy co-ordinates of points to be checked.
%  NODE  : An Kx2 array of xy co-ordinates of edge endpoints.
%  EDGE  : An Mx2 array of edges, specified as connections between the
%          vertices in NODE: [n1 n2; n3 n4; etc].
%  TOL   : Tolerance used when testing points.
%
% OUTPUTS
%
%  I     : Nx1 array of edge numbers, corresponding to the edge that each
%          node lies on. Nodes that do not lie on any edges are assigned 0.
%
% See also INPOLYGON

%   Darren Engwirda: 2005-2007
%   Email          : d_engwirda@hotmail.com
%   Last updated   : 25/11/2007 with MATLAB 7.0
%
% Problems or suggestions? Email me.


%% PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n  = size(p,1);
nc = size(edge,1);

% Choose the direction with the biggest range as the "y-coordinate" for the
% test. This should ensure that the sorting is done along the best
% direction for long and skinny problems wrt either the x or y axes.
dxy = max(p,[],1)-min(p,[],1);
if dxy(1)>dxy(2)
    % Flip co-ords if x range is bigger
    p = p(:,[2,1]);
    node = node(:,[2,1]);
end
tol = TOL*min(dxy);

% Sort test points by y-value
[y,i] = sort(p(:,2));
x = p(i,1);

%% MAIN LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
enum = zeros(size(p,1),1);
for k = 1:nc         % Loop through edges
    
    % Nodes in current edge
    n1 = edge(k,1);
    n2 = edge(k,2);
    
    % Endpoints - sorted so that [x1,y1] & [x2,y2] has y1<=y2
    y1 = node(n1,2);
    y2 = node(n2,2);
    if y1<y2
        x1 = node(n1,1);
        x2 = node(n2,1);
    else
        yt = y1;
        y1 = y2;
        y2 = yt;
        x1 = node(n2,1);
        x2 = node(n1,1);
    end
    
    % Binary search to find first point with y<=y1 for current edge
    if y(1)>=y1
        start = 1;
    elseif y(n)<y1
        start = n+1;
    else
        lower = 1;
        upper = n;
        for j = 1:n
            start = round(0.5*(lower+upper));
            if y(start)<y1
                lower = start;
            elseif y(start-1)<y1
                break;
            else
                upper = start;
            end
        end
    end
    
    % Loop through points
    for j = start:n
        % Check the bounding-box for the edge before doing the intersection
        % test. Take shortcuts wherever possible!
        Y = y(j);   % Do the array look-up once & make a temp scalar
        if Y<=y2
            
            % Check if we're "on" the edge
            X = x(j);
            if  (abs((y2-Y)*(x1-X)-(y1-Y)*(x2-X))<tol);
                enum(j) = k;
            end
            
        else
            % Due to the sorting, no points with >y
            % value need to be checked
            break
        end
    end
    
end

% Re-index to undo the sorting
enum(i) = enum;

function [cn,on] = inpoly(p,node,edge,TOL)

%  INPOLY: Point-in-polygon testing.
%
% Determine whether a series of points lie within the bounds of a polygon
% in the 2D plane. General non-convex, multiply-connected polygonal
% regions can be handled.
%
% SHORT SYNTAX:
%
%   in = inpoly(p,node);
%
%   p   : The points to be tested as an Nx2 array [x1 y1; x2 y2; etc].
%   node: The vertices of the polygon as an Mx2 array [X1 Y1; X2 Y2; etc].
%         The standard syntax assumes that the vertices are specified in
%         consecutive order.
%
%   in  : An Nx1 logical array with IN(i) = TRUE if P(i,:) lies within the
%         region.
%
% LONG SYNTAX:
%
%  [in,on] = inpoly(p,node,edge);
%
%  edge: An Mx2 array of polygon edges, specified as connections between
%        the vertices in NODE: [n1 n2; n3 n4; etc]. The vertices in NODE
%        do not need to be specified in connsecutive order when using the
%        extended syntax.
%
%  on  : An Nx1 logical array with ON(i) = TRUE if P(i,:) lies on a
%        polygon edge. (A tolerance is used to deal with numerical
%        precision, so that points within a distance of
%        eps^0.8*norm(node(:),inf) from a polygon edge are considered "on"
%        the edge.
%
% EXAMPLE:
%
%   polydemo;       % Will run a few examples
%
% See also INPOLYGON

% The algorithm is based on the crossing number test, which counts the
% number of times a line that extends from each point past the right-most
% region of the polygon intersects with a polygon edge. Points with odd
% counts are inside. A simple implementation of this method requires each
% wall intersection be checked for each point, resulting in an O(N*M)
% operation count.
%
% This implementation does better in 2 ways:
%
%   1. The test points are sorted by y-value and a binary search is used to
%      find the first point in the list that has a chance of intersecting
%      with a given wall. The sorted list is also used to determine when we
%      have reached the last point in the list that has a chance of
%      intersection. This means that in general only a small portion of
%      points are checked for each wall, rather than the whole set.
%
%   2. The intersection test is simplified by first checking against the
%      bounding box for a given wall segment. Checking against the bbox is
%      an inexpensive alternative to the full intersection test and allows
%      us to take a number of shortcuts, minimising the number of times the
%      full test needs to be done.
%
%   Darren Engwirda: 2005-2007
%   Email          : d_engwirda@hotmail.com
%   Last updated   : 23/11/2007 with MATLAB 7.0
%
% Problems or suggestions? Email me.

%% PRE-PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n  = size(p,1);
nc = size(edge,1);

% Choose the direction with the biggest range as the "y-coordinate" for the
% test. This should ensure that the sorting is done along the best
% direction for long and skinny problems wrt either the x or y axes.
dxy = max(p,[],1)-min(p,[],1);
if dxy(1)>dxy(2)
    % Flip co-ords if x range is bigger
    p = p(:,[2,1]);
    node = node(:,[2,1]);
end
tol = TOL*min(dxy);

% Sort test points by y-value
[y,i] = sort(p(:,2));
x = p(i,1);

%% MAIN LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cn = false(n,1);     % Because we're dealing with mod(cn,2) we don't have
% to actually increment the crossing number, we can
% just flip a logical at each intersection (faster!)
on = cn;
for k = 1:nc         % Loop through edges
    
    % Nodes in current edge
    n1 = edge(k,1);
    n2 = edge(k,2);
    
    % Endpoints - sorted so that [x1,y1] & [x2,y2] has y1<=y2
    %           - also get xmin = min(x1,x2), xmax = max(x1,x2)
    y1 = node(n1,2);
    y2 = node(n2,2);
    if y1<y2
        x1 = node(n1,1);
        x2 = node(n2,1);
    else
        yt = y1;
        y1 = y2;
        y2 = yt;
        x1 = node(n2,1);
        x2 = node(n1,1);
    end
    if x1>x2
        xmin = x2;
        xmax = x1;
    else
        xmin = x1;
        xmax = x2;
    end
    
    % Binary search to find first point with y<=y1 for current edge
    if y(1)>=y1
        start = 1;
    elseif y(n)<y1
        start = n+1;
    else
        lower = 1;
        upper = n;
        for j = 1:n
            start = round(0.5*(lower+upper));
            if y(start)<y1
                lower = start;
            elseif y(start-1)<y1
                break;
            else
                upper = start;
            end
        end
    end
    
    % Loop through points
    for j = start:n
        % Check the bounding-box for the edge before doing the intersection
        % test. Take shortcuts wherever possible!
        
        Y = y(j);   % Do the array look-up once & make a temp scalar
        if Y<=y2
            X = x(j);   % Do the array look-up once & make a temp scalar
            if X>=xmin
                if X<=xmax
                    
                    % Check if we're "on" the edge
                    on(j) = on(j) || (abs((y2-Y)*(x1-X)-(y1-Y)*(x2-X))<tol);
                    
                    % Do the actual intersection test
                    if (Y<y2) && ((y2-y1)*(X-x1)<(Y-y1)*(x2-x1))
                        cn(j) = ~cn(j);
                    end
                    
                end
            elseif Y<y2   % Deal with points exactly at vertices
                % Has to cross edge
                cn(j) = ~cn(j);
            end
        else
            % Due to the sorting, no points with >y
            % value need to be checked
            break
        end
    end
    
end

% Re-index to undo the sorting
cn(i) = cn|on;
on(i) = on;


function A = triarea(p,t)

% TRIAREA: Area of triangles assuming counter-clockwise (CCW) node
% ordering.
%
%  P  : Nx2 array of XY node co-ordinates
%  T  : Mx3 array of triangles as indices into P
%  A  : Mx1 array of triangle areas

% Darren Engwirda - 2007

d12 = p(t(:,2),:)-p(t(:,1),:);
d13 = p(t(:,3),:)-p(t(:,1),:);
A = (d12(:,1).*d13(:,2)-d12(:,2).*d13(:,1));

function q = quality(p,t)

%  QUALITY: Approximate triangle quality.
%
%  q = quality(p,t);
%
%  p: Nx2 array of nodal XY coordinates, [x1,y1; x2,y2; etc]
%  t: Mx3 array of triangles as indices, [n11,n12,n13; n21,n22,n23; etc]
%  q: Mx1 vector of triangle qualities. 0<=q<=1.

% Darren Engwirda - 2007.

% Nodes
p1 = p(t(:,1),:);
p2 = p(t(:,2),:);
p3 = p(t(:,3),:);

% Approximate quality
d12 = p2-p1;
d13 = p3-p1;
d23 = p3-p2;
q = 3.4641*abs(d12(:,1).*d13(:,2)-d12(:,2).*d13(:,1))./sum(d12.^2+d13.^2+d23.^2,2);


function cc = circumcircle(p,t)

% CIRCUMCIRCLE: XY centre co-ordinates and radius of triangle
% circumcircles.
%
% P   : Nx2 array of nodal XY co-ordinates
% T   : Mx3 array of triangles as indices into P
% CC  : Mx3 array of circimcircles CC(:,1:2) = XY, CC(:,3) = R^2

cc = 0.0*t;

% Corner XY
p1 = p(t(:,1),:);
p2 = p(t(:,2),:);
p3 = p(t(:,3),:);

% Set equation for center of each circumcircle:
%    [a11,a12; a21,a22] * [x; y] = [b1; b2] * 0.5;
a1 = p2-p1;
a2 = p3-p1;
b1 = sum(a1.*(p2+p1),2); %a1(:,1).*(p2(:,1)+p1(:,1)) + a1(:,2).*(p2(:,2)+p1(:,2));
b2 = sum(a2.*(p3+p1),2); %a2(:,1).*(p3(:,1)+p1(:,1)) + a2(:,2).*(p3(:,2)+p1(:,2));

% Explicit inversion
idet = 0.5./(a1(:,1).*a2(:,2)-a2(:,1).*a1(:,2));

% Circumcentre XY
cc(:,1) = ( a2(:,2).*b1 - a1(:,2).*b2).*idet;
cc(:,2) = (-a2(:,1).*b1 + a1(:,1).*b2).*idet;

% Radius^2
cc(:,3) = sum((p1-cc(:,1:2)).^2,2);

function [p,t,pfun,tfun] = fixmesh(p,t,pfun,tfun)

%  FIXMESH: Ensure that triangular mesh data is consistent.
%
%  [p,t,pfun,tfun] = fixmesh(p,t,pfun,tfun);
%
%  p     : Nx2 array of nodal XY coordinates, [x1,y1; x2,y2; etc]
%  t     : Mx3 array of triangles as indices, [n11,n12,n13; n21,n22,n23;
%          etc]
%  pfun  : (Optional) NxK array of nodal function values. Each column in
%          PFUN corresponds to a dependent function, PFUN(:,1) = F1(P),
%          PFUN(:,2) = F2(P) etc, defined at the nodes.
%  tfun  : (Optional) MxK array of triangle function values. Each column in
%          TFUN corresponds to a dependent function, TFUN(:,1) = F1(T),
%          TFUN(:,2) = F2(T) etc, defined on the triangles.
%
% The following checks are performed:
%
%  1. Nodes not refereneced in T are removed.
%  2. Duplicate nodes are removed.
%  3. Triangles are ordered counter-clockwise.
%  4. Triangles with an area less than 1.0e-10*eps*norm(A,'inf')
%     are removed

% Darren Engwirda - 2007.

TOL = 1.0e-10;

% Remove duplicate nodes
[i,i,j] = unique(p,'rows');
if ~isempty(pfun)
    pfun = pfun(i,:);
end
p = p(i,:);
t = reshape(j(t),size(t));

% Triangle area
A = triarea(p,t);
Ai = A<0.0;
Aj = abs(A)>TOL*norm(A,'inf');

% Flip node numbering to give a counter-clockwise order
t(Ai,[1,2]) = t(Ai,[2,1]);

% Remove zero area triangles
t = t(Aj,:);
if ~isempty(tfun)
    tfun = tfun(Aj,:);
end

% Remove un-used nodes
[i,j,j] = unique(t(:));
if ~isempty(pfun)
    pfun = pfun(i,:);
end
p = p(i,:)';
t = reshape(j,size(t));



