function [ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab(igsfile,showlines)
% IGES2MATLAB converts the parameter data in an IGES-file to MATLAB format.
%
% Usage:
%
% [ParameterData,EntityType,numEntityType,unknownEntityType,numunknownEntityType]=iges2matlab(igsfile,showlines)
%
% Input:
%
% igsfile - IGES file
% showlines - information flag to plotIGES (optional). 
%             0 (default) show only lines in plotIGES corresponding to surfaces.
%             1 show all lines in plotIGES.
%
% Output:
%
% ParameterData - cell array with Parameter Data from igsfile
% EntityType - vector with entities in igsfile converted to matlab
% numEntityType - vector with number of entities belonging to EntityType
% unknownEntityType - vector with unknown entities for iges2matlab
% numunknownEntityType - vector with number of unknown entities
%                        belonging to unknownEntityType
%
% For entity type 126 and 128 ParameterData also contains a nurbs
% representation same as in the NURBS toolbox. The NURBS toolbox can be
% downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/14247-nurbs
%
% ParameterData also contains other useful information for usage in other
% functions. For curves the length is given as a parameter in ParameterData.
% superior is another parameter for curves and surfaces. For curves superior=1
% means that they are defined in the parameter space for a surface. superior=0
% means that they are defined in the 3D-space. For surfaces superior=1 means
% that their domain is limited by one or more closed curves. superior=0 means
% that their domain is the domain given in the ParameterData.
%
% For other parameters see the IGES specificaton version5x.pdf found at
% http://www.iges5x.org/archives/version5x/version5x.pdf
%
% All pointers in ParameterData points to the index
% in cell-array ParameterData.
%
% This version can not handle all possible IGES entities.
%
% Example:
%
% [ParameterData,EntityType,numEntityType,unknownEntityType]=iges2matlab('example.igs');
%
% will convert the parameter data in example.igs to MATLAB format.
%
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
%
% written by Per Bergström 2009-12-04
%

if nargin<2
    showlines=0;
end
if isempty(showlines)
    showlines=0;
end
if not(or(showlines==0,showlines==1))
    showlines=0;
end

[fid,msg]=fopen(igsfile);

if fid==-1
    error(msg);
end

c = fread(fid,'uint8=>uint8')';

fclose(fid);

nwro=sum((c((81:82))==10))+sum((c((81:82))==13));

edfi=nwro-sum(c(((end-1):end))==10)-sum(c(((end-1):end))==13);

siz=length(c);

ro=round((siz+edfi)/(80+nwro));

if rem((siz+edfi),(80+nwro))~=0
    error('Input file must be an IGES-file!');
end

roind=1:ro;

SGDPT=c(roind*(80+nwro)-7-nwro);

Sfind=SGDPT==83;
Gfind=SGDPT==71;
Dfind=SGDPT==68;
Pfind=SGDPT==80;
Tfind=SGDPT==84;

sumSfind=sum(Sfind);
sumGfind=sum(Gfind);
sumDfind=sum(Dfind);
sumPfind=sum(Pfind);
sumTfind=sum(Tfind);

%------S Line information (The initial line to get things started)---------
for i=roind(Sfind)
    disp(char(c(((i-1)*(80+nwro)+1):(i*(80+nwro)-8-nwro))));
end

%---------------G Line information  (Header infomation)--------------------

G=cell(1,25);
Gstr=zeros(1,72*sumGfind);
j=1;
for i=roind(Gfind)
    Gstr(((j-1)*72+1):(j*72))=c(((i-1)*(80+nwro)+1):(i*(80+nwro)-8-nwro));
    j=j+1;
end

if and(Gstr(1)==49,Gstr(2)==72)
    G{1}=Gstr(3);
    st=4;
else
    G{1}=44;
    st=1;
end

if and(Gstr(st+1)==49,Gstr(st+2)==72)
    G{2}=Gstr(st+3);
    st=st+4;
else
    G{2}=59;
    st=st+1;
end

le=length(Gstr);

for i=3:25
    for j=(st+1):le
        if or(Gstr(j)==G{1},Gstr(j)==G{2})
            break
        end
    end
    G{i}=Gstr((st+1):(j-1));
    st=j;
end

for i=[3 4 5 6 12 15 18 21 22 25]   %string
    stind=1;
    for j=1:length(G{i})
        if G{i}(j)~=32
            stind=j;
            break
        end
    end

    for j=stind:length(G{i})
        if G{i}(j)==72
            stind=j+1;
            break
        end
    end

    endind=length(G{i});
    for j=length(G{i}):-1:1
        if G{i}(j)~=32
            endind=j;
            break
        end
    end
    G{i}=G{i}(stind:endind);
end

for i=[7 8 9 10 11 13 14 16 17 19 20 23 24]   %num
    G{i}=str2num(char(G{i}));
end

%--D Line information (Data information) & P Line information (All data)---

noent=round(sumDfind/2);

ParameterData=cell(1,noent);

roP=sumSfind+sumGfind+sumDfind;

entty=zeros(1,520);
entunk=zeros(1,520);

entiall=0;

for i=(sumSfind+sumGfind+1):2:(sumSfind+sumGfind+sumDfind-1)

    entiall=entiall+1;

    Dstr=c(((i-1)*(80+nwro)+1):(i*(80+nwro)-8-nwro));

    type=str2num(char(Dstr(1:8)));

    ParameterData{entiall}.type=type;

    Pstart=str2num(char(Dstr(9:16)))+roP;

    if i==roP-1
        Pend=ro-sumTfind;
    else
        Pend=str2num(char(c(((i+1)*(80+nwro)+9):((i+1)*(80+nwro)+16))))+roP-1;
    end

    Pstr=zeros(1,64*(Pend-Pstart+1));
    j=1;
    for k=Pstart:Pend
        Pstr(((j-1)*64+1):(j*64))=c(((k-1)*(80+nwro)+1):(k*(80+nwro)-16-nwro));
        j=j+1;
    end

    Pstr(Pstr==G{1})=44;
    Pstr(Pstr==G{2})=59;

    Pvec=str2num(char(Pstr));

    % SURFACES

    if type==128

        entty(type)=entty(type)+1;

        A=1+Pvec(2)+Pvec(4);
        B=1+Pvec(3)+Pvec(5);
        C=(Pvec(2)+1)*(Pvec(3)+1);

        ParameterData{entiall}.name='B-NURBS SRF';
        ParameterData{entiall}.original=1;        

        ParameterData{entiall}.superior=0;

        ParameterData{entiall}.k1=Pvec(2);
        ParameterData{entiall}.k2=Pvec(3);
        ParameterData{entiall}.m1=Pvec(4);
        ParameterData{entiall}.m2=Pvec(5);

        ParameterData{entiall}.prop1=Pvec(6);
        ParameterData{entiall}.prop2=Pvec(7);
        ParameterData{entiall}.prop3=Pvec(8);
        ParameterData{entiall}.prop4=Pvec(10);
        ParameterData{entiall}.prop5=Pvec(11);

        ParameterData{entiall}.s=Pvec(11:(11+A));
        ParameterData{entiall}.t=Pvec((12+A):(12+A+B));
        
        ParameterData{entiall}.w=reshape(Pvec((13+A+B):(12+A+B+C)),Pvec(2)+1,Pvec(3)+1);
        ParameterData{entiall}.p=reshape(Pvec((13+A+B+C):(12+A+B+4*C)),3,Pvec(2)+1,Pvec(3)+1);
        
        if entiall>1
            if ParameterData{entiall-1}.type==124
                for scndInd=1:(Pvec(3)+1)
                    ParameterData{entiall}.p(:,:,scndInd)=(ParameterData{entiall-1}.R)*(ParameterData{entiall}.p(:,:,scndInd))+repmat(ParameterData{entiall-1}.T,1,Pvec(2)+1);
                end
            end
        end
        
        ParameterData{entiall}.u=zeros(1,2);
        ParameterData{entiall}.u(1)=Pvec(13+A+B+4*C);
        ParameterData{entiall}.u(2)=Pvec(14+A+B+4*C);

        ParameterData{entiall}.v=zeros(1,2);
        ParameterData{entiall}.v(1)=Pvec(15+A+B+4*C);
        ParameterData{entiall}.v(2)=Pvec(16+A+B+4*C);

        % NURBS surface

        ParameterData{entiall}.nurbs.form='B-NURBS';

        ParameterData{entiall}.nurbs.dim=4;

        ParameterData{entiall}.nurbs.number=zeros(1,2);
        ParameterData{entiall}.nurbs.number(1)=Pvec(2)+1;
        ParameterData{entiall}.nurbs.number(2)=Pvec(3)+1;

        ParameterData{entiall}.nurbs.coefs=zeros(4,Pvec(2)+1,Pvec(3)+1);
        ParameterData{entiall}.nurbs.coefs(4,:,:)=reshape(Pvec((13+A+B):(12+A+B+C)),Pvec(2)+1,Pvec(3)+1);
        ParameterData{entiall}.nurbs.coefs(1:3,:,:)=ParameterData{entiall}.p;

        ParameterData{entiall}.nurbs.coefs(1:3,:,:)=repmat(ParameterData{entiall}.nurbs.coefs(4,:,:),3,1).*ParameterData{entiall}.nurbs.coefs(1:3,:,:);

        ParameterData{entiall}.nurbs.knots=cell(1,2);
        ParameterData{entiall}.nurbs.knots{1}=Pvec(11:(11+A));
        ParameterData{entiall}.nurbs.knots{2}=Pvec((12+A):(12+A+B));

        ParameterData{entiall}.nurbs.order=zeros(1,2);
        ParameterData{entiall}.nurbs.order(1)=Pvec(4)+1;
        ParameterData{entiall}.nurbs.order(2)=Pvec(5)+1;
        
    elseif type==120

        ParameterData{entiall}.name='SURFACE OF REVOLUTION';

        ParameterData{entiall}.l=round((Pvec(2)+1)/2);
        ParameterData{entiall}.c=round((Pvec(3)+1)/2);
        ParameterData{entiall}.sa=Pvec(4);
        ParameterData{entiall}.ta=Pvec(5);

        boool=1;

        if ParameterData{ParameterData{entiall}.c}.type==110

            CRV.k=1;
            CRV.m=2;
            CRV.t=[0 0 0 1 1 1];
            CRV.w=[1 1];
            CRV.p=[ParameterData{ParameterData{entiall}.c}.p1 ParameterData{ParameterData{entiall}.c}.p2];
            CRV.v=[0 1];

        elseif ParameterData{ParameterData{entiall}.c}.type==126

            CRV.k=ParameterData{ParameterData{entiall}.c}.k;
            CRV.m=ParameterData{ParameterData{entiall}.c}.m;
            CRV.t=ParameterData{ParameterData{entiall}.c}.t;
            CRV.w=ParameterData{ParameterData{entiall}.c}.w;
            CRV.p=ParameterData{ParameterData{entiall}.c}.p;
            CRV.v=ParameterData{ParameterData{entiall}.c}.v;

        else

            disp(['Warning: Can not handle entity type 120 correctly in ',igsfile,'.']);
            boool=0;

        end

        if boool

            entty(128)=entty(128)+1;

            ctrlpnts=CRV.p;

            N=ParameterData{ParameterData{entiall}.l}.p2-ParameterData{ParameterData{entiall}.l}.p1;
            M=ctrlpnts(:,1)-ParameterData{ParameterData{entiall}.l}.p1;

            t=dot(M,N)/dot(N,N);
            Q=ParameterData{ParameterData{entiall}.l}.p1+t*N;

            M=ctrlpnts(:,end)-ParameterData{ParameterData{entiall}.l}.p1;

            t=dot(M,N)/dot(N,N);

            S=ParameterData{ParameterData{entiall}.l}.p1+t*N;

            dis1=norm(Q-CRV.p(:,1));

            dis2=norm(S-Q);

            A=[ctrlpnts(:,1) Q S];
            B=zeros(3,3);
            B(1,1)=dis1;
            B(3,3)=dis2;

            meA=mean(A,2);
            meB=mean(B,2);

            [U,Sigm,V]=svd((A-repmat(meA,1,3))*(B-repmat(meB,1,3))');
            R=V*U';
            Rinv=U*V';
            T=meB-R*meA;

            CRV.p=R*(CRV.p)+repmat(T,1,CRV.k+1);

            ParameterData{entiall}.type=128;

            ParameterData{entiall}.name='B-NURBS SRF';
            ParameterData{entiall}.original=0;
            ParameterData{entiall}.previous_name='SURFACE OF REVOLUTION';

            ParameterData{entiall}.superior=0;

            ParameterData{entiall}.k1=CRV.k;            
            ParameterData{entiall}.k2=6;

            ParameterData{entiall}.m1=CRV.m;            
            ParameterData{entiall}.m2=2;

            ParameterData{entiall}.prop1=0;
            ParameterData{entiall}.prop2=0;
            ParameterData{entiall}.prop3=0;
            ParameterData{entiall}.prop4=0;
            ParameterData{entiall}.prop5=0;

            ParameterData{entiall}.s=CRV.t;
            ParameterData{entiall}.t=[0 0 0 1/3 1/3 2/3 2/3 1 1 1]*(Pvec(5)-Pvec(4))+Pvec(4);

            wodd=cos((Pvec(5)-Pvec(4))/6);

            ParameterData{entiall}.w=[CRV.w;wodd*(CRV.w);CRV.w;wodd*(CRV.w);CRV.w;wodd*(CRV.w);CRV.w];
            ParameterData{entiall}.p=zeros(3,CRV.k+1,7);

            betavec=linspace(Pvec(4),Pvec(5),7);

            eve=1;

            for i=1:7
                if eve
                    ParameterData{entiall}.p(:,:,i)=Rinv*([cos(betavec(i)) -sin(betavec(i)) 0;
                        sin(betavec(i)) cos(betavec(i)) 0;
                        0   0   1]*(CRV.p)-repmat(T,1,CRV.k+1));
                    eve=0;
                else
                    ParameterData{entiall}.p(:,:,i)=Rinv*([cos(betavec(i))/wodd -sin(betavec(i))/wodd 0;
                        sin(betavec(i))/wodd cos(betavec(i))/wodd 0;
                        0   0   1]*(CRV.p)-repmat(T,1,CRV.k+1));
                    eve=1;
                end
            end
            
            if entiall>1
                if ParameterData{entiall-1}.type==124
                    for scndInd=1:7
                        ParameterData{entiall}.p(:,:,scndInd)=(ParameterData{entiall-1}.R)*(ParameterData{entiall}.p(:,:,scndInd))+repmat(ParameterData{entiall-1}.T,1,Pvec(2)+1);
                    end
                end
            end
            
            ParameterData{entiall}.u=CRV.v;
            ParameterData{entiall}.v=ParameterData{entiall}.t([1 end]);


            % NURBS surface

            ParameterData{entiall}.nurbs.form='B-NURBS';

            ParameterData{entiall}.nurbs.dim=4;

            ParameterData{entiall}.nurbs.number=[ParameterData{entiall}.k1+1 ParameterData{entiall}.k2+1];

            ParameterData{entiall}.nurbs.coefs=zeros(4,CRV.k+1,7);
            
            ParameterData{entiall}.nurbs.coefs(4,:,1)=ParameterData{entiall}.w(1,:);
            ParameterData{entiall}.nurbs.coefs(4,:,2)=ParameterData{entiall}.w(2,:);
            ParameterData{entiall}.nurbs.coefs(4,:,3)=ParameterData{entiall}.w(3,:);
            ParameterData{entiall}.nurbs.coefs(4,:,4)=ParameterData{entiall}.w(4,:);
            ParameterData{entiall}.nurbs.coefs(4,:,5)=ParameterData{entiall}.w(5,:);
            ParameterData{entiall}.nurbs.coefs(4,:,6)=ParameterData{entiall}.w(6,:);
            ParameterData{entiall}.nurbs.coefs(4,:,7)=ParameterData{entiall}.w(7,:);
            ParameterData{entiall}.nurbs.coefs(1:3,:,:)=ParameterData{entiall}.p;

            ParameterData{entiall}.nurbs.coefs(1:3,:,:)=repmat(ParameterData{entiall}.nurbs.coefs(4,:,:),3,1).*ParameterData{entiall}.nurbs.coefs(1:3,:,:);

            ParameterData{entiall}.nurbs.knots=cell(1,2);
            ParameterData{entiall}.nurbs.knots{1}=ParameterData{entiall}.s;
            ParameterData{entiall}.nurbs.knots{2}=ParameterData{entiall}.t;

            ParameterData{entiall}.nurbs.order=[ParameterData{entiall}.m1+1 ParameterData{entiall}.m2+1];

        end        

    elseif type==144

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='TRIMMED SURFACE';

        ParameterData{entiall}.pts=round((Pvec(2)+1)/2);

        ParameterData{entiall}.n1=Pvec(3);
        ParameterData{entiall}.n2=Pvec(4);

        if Pvec(5)~=0
            ParameterData{entiall}.pto=round((Pvec(5)+1)/2);
        else
            ParameterData{entiall}.pto=0;
        end

        ParameterData{entiall}.pti=round((Pvec(6:(5+Pvec(4)))+1)/2);
        
    elseif type==108
        
        entty(type)=entty(type)+1;
        
        ParameterData{entiall}.name='Unknown type!';
        entunk(type)=entunk(type)+1;
        ParameterData{entiall}.original=1;
        ParameterData{entiall}.length=0.00000000001;
        ParameterData{entiall}.previous_name='PLANE';
        
        ParameterData{entiall}.a=Pvec(2);
        ParameterData{entiall}.b=Pvec(3);
        ParameterData{entiall}.c=Pvec(4);
        ParameterData{entiall}.d=Pvec(5);
        ParameterData{entiall}.ptr=round((Pvec(6)+1)/2);
        ParameterData{entiall}.x=Pvec(7);
        ParameterData{entiall}.y=Pvec(8);
        ParameterData{entiall}.z=Pvec(9);
        ParameterData{entiall}.size=Pvec(10);
     
        % CURVES
        
    elseif type==126

        entty(type)=entty(type)+1;

        N=1+Pvec(2)-Pvec(3);
        A=1+Pvec(2)+Pvec(3);

        ParameterData{entiall}.name='B-NURBS CRV';

        if showlines
            ParameterData{entiall}.superior=0;
        else
            ParameterData{entiall}.superior=1;
        end

        ParameterData{entiall}.k=Pvec(2);
        ParameterData{entiall}.m=Pvec(3);

        ParameterData{entiall}.prop1=Pvec(4);
        ParameterData{entiall}.prop2=Pvec(5);
        ParameterData{entiall}.prop3=Pvec(6);
        ParameterData{entiall}.prop4=Pvec(7);

        ParameterData{entiall}.t=Pvec(8:(8+A));

        ParameterData{entiall}.w=Pvec((9+A):(9+A+Pvec(2)));

        ParameterData{entiall}.p=reshape(Pvec((10+A+Pvec(2)):(12+A+4*Pvec(2))),3,Pvec(2)+1);
        
        if entiall>1
            if ParameterData{entiall-1}.type==124
                ParameterData{entiall}.p=(ParameterData{entiall-1}.R)*(ParameterData{entiall}.p)+repmat(ParameterData{entiall-1}.T,1,Pvec(2)+1);
            end
        end
        
        ParameterData{entiall}.v=zeros(1,2);
        ParameterData{entiall}.v(1)=Pvec(13+A+4*Pvec(2));
        ParameterData{entiall}.v(2)=Pvec(14+A+4*Pvec(2));

        if Pvec(4)
            ParameterData{entiall}.xnorm=Pvec(15+A+4*Pvec(2));
            ParameterData{entiall}.ynorm=Pvec(16+A+4*Pvec(2));
            ParameterData{entiall}.znorm=Pvec(17+A+4*Pvec(2));
        else
            ParameterData{entiall}.xnorm=0;
            ParameterData{entiall}.ynorm=0;
            ParameterData{entiall}.znorm=0;
        end

        % NURBS curve

        ParameterData{entiall}.nurbs.form='B-NURBS';

        ParameterData{entiall}.nurbs.dim=4;

        ParameterData{entiall}.nurbs.number=Pvec(2)+1;

        ParameterData{entiall}.nurbs.coefs=zeros(4,Pvec(2)+1);
        ParameterData{entiall}.nurbs.coefs(4,:)=Pvec((9+A):(9+A+Pvec(2)));

        ParameterData{entiall}.nurbs.coefs(1:3,:)=ParameterData{entiall}.p;

        ParameterData{entiall}.nurbs.coefs(1:3,:)=repmat(ParameterData{entiall}.nurbs.coefs(4,:),3,1).*ParameterData{entiall}.nurbs.coefs(1:3,:);

        ParameterData{entiall}.nurbs.order=Pvec(3)+1;

        ParameterData{entiall}.nurbs.knots=Pvec(8:(8+A));

        nup=500;
        p = nrbevalIGES(ParameterData{entiall}.nurbs,linspace(ParameterData{entiall}.v(1),ParameterData{entiall}.v(2),nup));
        len=sum(sqrt(sum((p(:,1:(nup-1))-p(:,2:nup)).^2,1)));
        if norm(p(:,1)-p(:,nup))<1e-3
            ParameterData{entiall}.length=3*len;
        else
            ParameterData{entiall}.length=min((len/norm(p(:,1)-p(:,nup))-1)*10+1,3)*len;
        end
        
        clear nup p len N A

    elseif type==100

        ParameterData{entiall}.type=126;

        entty(126)=entty(126)+1;

        zt=Pvec(2);
        x1=Pvec(3);
        y1=Pvec(4);
        x2=Pvec(5);
        y2=Pvec(6);
        x3=Pvec(7);
        y3=Pvec(8);

        R=0.5*(sqrt((x2-x1)^2+(y2-y1)^2)+sqrt((x3-x1)^2+(y3-y1)^2));

        if (x2-x1)*(y3-y1)-(x3-x1)*(y2-y1)<=0
            beta=2*pi-acos(((x2-x1)*(x3-x1)+(y2-y1)*(y3-y1))/(R^2));
        else
            beta=acos(((x2-x1)*(x3-x1)+(y2-y1)*(y3-y1))/(R^2));
        end

        if beta<1e-12
            beta=2*pi;
        end

        wodd=cos(beta/6);

        P0=[x2;y2];

        P1=[cos(beta/6) -sin(beta/6);sin(beta/6) cos(beta/6)]*[x2-x1;y2-y1]/wodd+[x1;y1];

        P2=[cos(beta/3) -sin(beta/3);sin(beta/3) cos(beta/3)]*[x2-x1;y2-y1]+[x1;y1];

        P3=[cos(beta/2) -sin(beta/2);sin(beta/2) cos(beta/2)]*[x2-x1;y2-y1]/wodd+[x1;y1];

        P4=[cos(2*beta/3) -sin(2*beta/3);sin(2*beta/3) cos(2*beta/3)]*[x2-x1;y2-y1]+[x1;y1];

        P5=[cos(5*beta/6) -sin(5*beta/6);sin(5*beta/6) cos(5*beta/6)]*[x2-x1;y2-y1]/wodd+[x1;y1];

        P6=[x3;y3];
        
        PP=[P0 P1 P2 P3 P4 P5 P6;zt*ones(1,7)];
        
        if entiall>1
           if ParameterData{entiall-1}.type==124
               PP=(ParameterData{entiall-1}.R)*PP+repmat(ParameterData{entiall-1}.T,1,7);
           end
        end

        ParameterData{entiall}.name='B-NURBS CRV';
        ParameterData{entiall}.previous_name='CIRCULAR ARC';

        if showlines
            ParameterData{entiall}.superior=0;
        else
            ParameterData{entiall}.superior=1;
        end
        
        ParameterData{entiall}.k=6;
        ParameterData{entiall}.m=2;

        ParameterData{entiall}.prop1=1;
        ParameterData{entiall}.prop2=0;
        ParameterData{entiall}.prop3=0;
        ParameterData{entiall}.prop4=0;

        ParameterData{entiall}.t=[0 0 0 1 1 2 2 3 3 3];

        ParameterData{entiall}.w=[1 wodd 1 wodd 1 wodd 1];

        ParameterData{entiall}.p=PP;

        ParameterData{entiall}.v=[0 3];

        ParameterData{entiall}.xnorm=0;
        ParameterData{entiall}.ynorm=0;
        ParameterData{entiall}.znorm=1;

        % NURBS curve

        ParameterData{entiall}.nurbs.form='B-NURBS';

        ParameterData{entiall}.nurbs.dim=4;

        ParameterData{entiall}.nurbs.number=7;

        ParameterData{entiall}.nurbs.coefs=zeros(4,7);
        ParameterData{entiall}.nurbs.coefs(4,:)=[1 wodd 1 wodd 1 wodd 1];

        ParameterData{entiall}.nurbs.coefs(1:3,:)=PP;

        ParameterData{entiall}.nurbs.coefs(1:3,:)=repmat(ParameterData{entiall}.nurbs.coefs(4,:),3,1).*ParameterData{entiall}.nurbs.coefs(1:3,:);

        ParameterData{entiall}.nurbs.order=3;

        ParameterData{entiall}.nurbs.knots=[0 0 0 1 1 2 2 3 3 3];

        nup=500;
        p = nrbevalIGES(ParameterData{entiall}.nurbs,linspace(ParameterData{entiall}.v(1),ParameterData{entiall}.v(2),nup));
        len=sum(sqrt(sum((p(:,1:(nup-1))-p(:,2:nup)).^2,1)));
        if norm(p(:,1)-p(:,nup))<1e-3
            ParameterData{entiall}.length=3*len;
        else
            ParameterData{entiall}.length=min((len/norm(p(:,1)-p(:,nup))-1)*10+1,3)*len;
        end
        
        clear PP nup p len

    elseif type==110

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='LINE';

        if showlines
            ParameterData{entiall}.superior=0;
        else
            ParameterData{entiall}.superior=1;
        end

        ParameterData{entiall}.form=str2num(char(c((i*(80+nwro)+65):(i*(80+nwro)+72))));
        
        p_1=Pvec(2:4)';
        p_2=Pvec(5:7)';
        
        if entiall>1
           if ParameterData{entiall-1}.type==124
               p_1=(ParameterData{entiall-1}.R)*p_1+ParameterData{entiall-1}.T;
               p_2=(ParameterData{entiall-1}.R)*p_2+ParameterData{entiall-1}.T;
           end
        end        

        ParameterData{entiall}.p1=p_1;
        ParameterData{entiall}.x1=p_1(1);
        ParameterData{entiall}.y1=p_1(2);
        ParameterData{entiall}.z1=p_1(3);

        ParameterData{entiall}.p2=p_2;
        ParameterData{entiall}.x2=p_2(1);
        ParameterData{entiall}.y2=p_2(2);
        ParameterData{entiall}.z2=p_2(3);

        ParameterData{entiall}.length=norm(p_1-p_2);
        clear p_1 p_2

    elseif type==102

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='COMPOSITE CRV';

        ParameterData{entiall}.n=Pvec(2);
        ParameterData{entiall}.de=round((Pvec(3:(2+Pvec(2)))+1)/2);

        ParameterData{entiall}.lengthcnt=zeros(1,Pvec(2));
        ParameterData{entiall}.length=0;

    elseif type==142

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='CRV ON A PARAMETRIC SURFACE';

        ParameterData{entiall}.crtn=Pvec(2);
        ParameterData{entiall}.sptr=round((Pvec(3)+1)/2);
        ParameterData{entiall}.bptr=round((Pvec(4)+1)/2);
        ParameterData{entiall}.cptr=round((Pvec(5)+1)/2);
        ParameterData{entiall}.pref=Pvec(6);
        ParameterData{entiall}.length=0;

        % POINT

    elseif type==116

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='POINT';

        ParameterData{entiall}.p=Pvec(2:4)';

        ParameterData{entiall}.x=Pvec(2);
        ParameterData{entiall}.y=Pvec(3);
        ParameterData{entiall}.z=Pvec(4);
        
        ParameterData{entiall}.ptr=round((Pvec(5)+1)/2);
        
        % OTHER
        
    elseif type==124

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='TRANSFORMATION MATRIX';

        ParameterData{entiall}.R=zeros(3);
        ParameterData{entiall}.T=zeros(3,1);

        ParameterData{entiall}.R(1,1)=Pvec(2);
        ParameterData{entiall}.R(1,2)=Pvec(3);
        ParameterData{entiall}.R(1,3)=Pvec(4);

        ParameterData{entiall}.T(1)=Pvec(5);

        ParameterData{entiall}.R(2,1)=Pvec(6);
        ParameterData{entiall}.R(2,2)=Pvec(7);
        ParameterData{entiall}.R(2,3)=Pvec(8);

        ParameterData{entiall}.T(2)=Pvec(9);

        ParameterData{entiall}.R(3,1)=Pvec(10);
        ParameterData{entiall}.R(3,2)=Pvec(11);
        ParameterData{entiall}.R(3,3)=Pvec(12);

        ParameterData{entiall}.T(3)=Pvec(13);

    elseif type==314

        entty(type)=entty(type)+1;

        ParameterData{entiall}.name='COLOR';

        inn=find(or(Pstr==44,Pstr==59));

        ParameterData{entiall}.cc1=str2num(char(Pstr((inn(1)+1):(inn(2)-1))));
        ParameterData{entiall}.cc2=str2num(char(Pstr((inn(2)+1):(inn(3)-1))));
        ParameterData{entiall}.cc3=str2num(char(Pstr((inn(3)+1):(inn(4)-1))));

        if length(inn)>4
            inn2=find(Pstr(1:(inn(5)-1))==72);
            if isempty(inn2)
                ParameterData{entiall}.cname='';
            else
                ParameterData{entiall}.cname=char(Pstr((inn2(1)+1):(inn(5)-1)));
            end
        else
            ParameterData{entiall}.cname='';
        end

    else

        ParameterData{entiall}.name='Unknown type!';
        entunk(type)=entunk(type)+1;
        
        ParameterData{entiall}.original=1;

        ParameterData{entiall}.length=0.00000000001;
    end
end

ent_ind=1:520;

EntityType=ent_ind(entty>0);

numEntityType=entty(entty>0);

unknownEntityType=ent_ind(entunk>0);

numunknownEntityType=entunk(entunk>0);

if not(isempty(unknownEntityType))
    disp(' ');
    disp(['Warning: There are unknown entity types for iges2matlab in ',igsfile,'.']);
    disp(' ');
    disp('Use "I-DEAS 3D IGES Translator" with NURBS as surface representation instead.');
    disp('If you dont have that posibility you can add IGES entities into iges2matlab().');
    disp('The IGES manual is found at');
    disp('http://www.iges5x.org/archives/version5x/version5x.pdf');
    disp('where all IGES entities are documented.');
    disp('Please, send me your upgrade version of iges2matlab()');
    disp(' ');    
    disp('perbergstrom / AT / hotmail.com');
end

cp1min=Inf;
cp1max=-Inf;
cp2min=Inf;
cp2max=-Inf;
cp3min=Inf;
cp3max=-Inf;

for i=1:noent

    if ParameterData{i}.type==144
        
        ParameterData{ParameterData{i}.pts}.superior=1;
        
        if ParameterData{i}.n1
            ParameterData=undosuperior(ParameterData,ParameterData{i}.pto);
            if not(ParameterData{ParameterData{i}.pts}.original)
                if length(ParameterData{ParameterData{i}.pts}.previous_name)==length('SURFACE OF REVOLUTION')
                    if all(ParameterData{ParameterData{i}.pts}.previous_name=='SURFACE OF REVOLUTION');
                        ParameterData=mkreverse(ParameterData,ParameterData{i}.pto);
                    end
                end
            end
        end

        for j=1:ParameterData{i}.n2
            ParameterData=undosuperior(ParameterData,ParameterData{i}.pti(j));
            if not(ParameterData{ParameterData{i}.pts}.original)
                if length(ParameterData{ParameterData{i}.pts}.previous_name)==length('SURFACE OF REVOLUTION')
                    if all(ParameterData{ParameterData{i}.pts}.previous_name=='SURFACE OF REVOLUTION');
                        ParameterData=mkreverse(ParameterData,ParameterData{i}.pti(j));
                    end
                end
            end
        end
    elseif ParameterData{i}.type==102
        
        for j=1:ParameterData{i}.n
            ParameterData{i}.lengthcnt(j)=ParameterData{ParameterData{i}.de(j)}.length;
        end
        
        ParameterData{i}.length=sum(ParameterData{i}.lengthcnt);
        
    elseif ParameterData{i}.type==128
        
        cp1min=min(cp1min,min(reshape(ParameterData{i}.p(1,:,:),1,[])));
        cp1max=max(cp1max,max(reshape(ParameterData{i}.p(1,:,:),1,[])));
        cp2min=min(cp2min,min(reshape(ParameterData{i}.p(2,:,:),1,[])));
        cp2max=max(cp2max,max(reshape(ParameterData{i}.p(2,:,:),1,[])));
        cp3min=min(cp3min,min(reshape(ParameterData{i}.p(3,:,:),1,[])));
        cp3max=max(cp3max,max(reshape(ParameterData{i}.p(3,:,:),1,[])));
        
        [dnurbs,d2nurbs]=nrbDerivativesIGES(ParameterData{i}.nurbs);
        ParameterData{i}.dnurbs=dnurbs;
        ParameterData{i}.d2nurbs=d2nurbs;
        
    elseif ParameterData{i}.type==126
        
        [dnurbs,d2nurbs]=nrbDerivativesIGES(ParameterData{i}.nurbs);
        ParameterData{i}.dnurbs=dnurbs;
        ParameterData{i}.d2nurbs=d2nurbs;        
        
    end
end

gdiag=norm([cp1max-cp1min,cp2max-cp2min,cp3max-cp3min]);

for i=1:noent
    if ParameterData{i}.type==142
        ParameterData{i}.length=ParameterData{ParameterData{i}.cptr}.length;
        ParameterData{i}.gdiagonal=gdiag;
    elseif ParameterData{i}.type==144
        ParameterData{i}.gdiagonal=gdiag;
    end
end

% Recursive define function

function ParameterData=undosuperior(ParameterData,ii)

ty=ParameterData{ii}.type;

if ty==126
    ParameterData{ii}.superior=0;
elseif ty==110
    ParameterData{ii}.superior=0;
elseif ty==102
    for k=1:ParameterData{ii}.n
        ParameterData=undosuperior(ParameterData,ParameterData{ii}.de(k));
    end
elseif ty==142
    % only cptr, not bptr
    ParameterData=undosuperior(ParameterData,ParameterData{ii}.cptr);
end

function ParameterData=mkreverse(ParameterData,ii)

ty=ParameterData{ii}.type;

if ty==126
    
    t=sum(ParameterData{ii}.v)-ParameterData{ii}.t;
    ParameterData{ii}.t=t(end:(-1):1);
    ParameterData{ii}.w=ParameterData{ii}.w(end:(-1):1);
    ParameterData{ii}.p=ParameterData{ii}.p(:,end:(-1):1);
    
    ParameterData{ii}.nurbs.coefs=ParameterData{ii}.nurbs.coefs(:,end:(-1):1);
    
    ParameterData{ii}.nurbs.knots=ParameterData{ii}.t;
    
elseif ty==110
    
    p1=ParameterData{ii}.p1;
    p2=ParameterData{ii}.p2;
    
    ParameterData{ii}.p1=p2;
    ParameterData{ii}.p2=p1;
    
    ParameterData{ii}.x1=p2(1);
    ParameterData{ii}.y1=p2(2);
    ParameterData{ii}.z1=p2(3);
    
    ParameterData{ii}.x2=p1(1);
    ParameterData{ii}.y2=p1(2);
    ParameterData{ii}.z2=p1(3); 
    
elseif ty==102
    
    de=ParameterData{ii}.de;
    
    for k=1:ParameterData{ii}.n
        ParameterData{ii}.de(k)=de(ParameterData{ii}.n+1-k);
        ParameterData=mkreverse(ParameterData,ParameterData{ii}.de(k));
    end
elseif ty==142
    % only bptr, not cptr
    ParameterData=mkreverse(ParameterData,ParameterData{ii}.bptr);
end

