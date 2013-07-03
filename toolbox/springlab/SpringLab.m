function SpringLab(modelname)
    

%% init model

    if ~ischar(modelname)
	  error('Input arg must be a string (enclosed in single quotes).');
    end

    if length(modelname)<4 || ~strcmpi(modelname( (end-3):end),'.vol')
	  modelname=[modelname,'.vol'];
    end

    if ~exist(modelname,'file')
	  error('Non-existent VOL model.')
    end

    [X0,Tes,Srf]=VolLoader(modelname);
    dat.fk=2000;  lambda=100; mu= 100; fdamp = 5;

    X=X0;

    global N dt Minv  U ForceCoeffMat WMinvDt2;
    N=size(X,1);  % # of Vertices
    NumFaces=size(Srf,1);

    Edg=BuildEdgFromTes(Tes);
    NumEdges=size(Edg,1);

    FaccumarrayInd = [   Edg(:,1) , ones(NumEdges,1) ;      	% used for vectorizing the computation of spring forces
						    Edg(:,1) , 2*ones(NumEdges,1) ;
						    Edg(:,1) , 3*ones(NumEdges,1) ;
						    Edg(:,2) , ones(NumEdges,1) ;
						    Edg(:,2) , 2*ones(NumEdges,1) ;
						    Edg(:,2) , 3*ones(NumEdges,1) ];

%% init fig and axis
    fig=gcf; clf;
    s = trisurf(Srf,X(:,1),X(:,2),X(:,3));
    axis equal off  auto;
    camproj('perspective');
    view(3);
    camlookat(s);
    alpha(0.3);
    dat.AlphaDat=0.3*ones(NumFaces,1);
    set(s,'FaceVertexAlphaData',dat.AlphaDat,'AlphaDataMapping','none',...
	  'FaceAlpha','flat');

    colormap(autumn);
%     cameratoolbar;
%     cameratoolbarnokeys;
%     cameratoolbarnokeys('setmode','nomode'); % un-press buttons


%% init GUI , physical props and userdata
    vRestLengths = realsqrt( sum( (X(Edg(:,1),:)-X(Edg(:,2),:)) .^2,2 )) ;  % col vec, rest lengths of springs
    vk=dat.fk(ones(NumEdges,1)); % ./ vRestLengths;

    dt=1/60;
    
    dat.dtTxtHandle=uicontrol('Style','text', 'Position',[0 20 80 20],   'String',sprintf('%g',dt));
    uicontrol('Style','text', 'Position',[0 0 80 20],   'String','dt (</>)');

    dat.kTxtHandle=uicontrol('Style','text', 'Position',[80 20 80 20],   'String',sprintf('%g',dat.fk));
    uicontrol('Style','text', 'Position',[80 0 80 20],   'String','k (n/m)');
    
    dat.dTxtHandle=uicontrol('Style','text', 'Position',[160 20 80 20],   'String',sprintf('%g',fdamp));
    uicontrol('Style','text', 'Position',[160 0 80 20],   'String','d (v/b)');
    
    nl = sprintf('\n');
    helpstr = [	'Select a point on a face with a left click, and drag it with',nl,...
				'the mouse. Free a constraint by right-clicking on its face.',nl,...
				'Make sure no toolbar buttons are pressed during mouse ',nl,...
				'clicks.  Additional key operations: f - free all constraints,',nl,...
				'p - toggle pause, k - keyboard (for debugging),  q - quit.'];

    uicontrol('Style','text', 'Position',[0 40 300 80],  'String',helpstr);

    dat.pause =0;

    m=1;
%     global Minv;
%         vm=m(ones(1,N)); % initialized uniform, for now.
%         M=sparse(diag(vm));
%     Minv=sparse(inv(M));
    Minv = 1/m ;  % scalar optimization, for the uniform mass case

    vRestLengths = sqrt( sum( (X(Edg(:,1),:)-X(Edg(:,2),:)) .^2,2 )) ;  % row vec, rest lengths of springs
    K=accumarray(Edg,vk,[N,N]);
    K=K+K.';
    K=K- diag(sum(K));

    FEMkronK=sparse(FEMBuildKtemp(X0,Tes,lambda,mu));
    global W WMinvDt2;
    ComputeW;

    dat.Constraints.FaceInd=[]; % index of the constrained face
    dat.Constraints.VrtxInds=[]; % row vec of face-vertices indices
    dat.Constraints.Barys=[]; % row vec of corresponding barys
    dat.Constraints.URowInd=[]; % the ind of the constraint in U
    dat.Constraints.FixedPos=[]; % a 3x1 vec of the constrained pos
    dat.Constraints.MarkerHandle=[]; % a handle to the line obj that draws the marker

    dat.CurrConstraint=0;

    global U ForceCoeffMat;
    U=sparse(zeros(0,N));

    dat.MousePressed=false;

    set(fig,'userdata',dat,...
		'KeyPressFcn',@KeyHandling,'WindowButtonDownFcn', @MouseDown,...
	  'WindowButtonUpFcn',@MouseUp,'WindowButtonMotionFcn',@MouseMotion);

    cameratoolbarnokeys;
    cameratoolbarnokeys('setmode','nomode'); % un-press buttons

    
%% FPS measurment init

FPSTxtHandle=uicontrol('Style','text', 'Position',[240 0 80 20]);
tmr = timer('TimerFcn', @TmrFcn,'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',2);

    function TmrFcn(src,evnt)
	  set(FPSTxtHandle,'String',sprintf('FPS: %g',0.5*ctr));
	  ctr=0;
    end

    set(fig,'CloseRequestFcn',@CloseTimersAndExit)

    function CloseTimersAndExit(src,evnt) %nested, to have approach to tmr
	  stop(tmr); delete(tmr);
	  clear('tmr');
	  delete(fig);
	  return
    end
    
%% init simulation vars
    v=zeros(N,3);
    ctr=0;    % measures FPS
    start(tmr);
    
%% Main Loop
while ishandle(s)
    
    dat=get(fig,'userdata');
    
    if ~dat.pause
	  F=BuildSpringF(X) + BuildVolF(X,X0,FEMkronK);
	  [X,v]=PropagateImplicit(F,X,v);
	  if ~isempty(U)   % constraints present
		[X,v]=ApplyConstraints(X,v,dat.Constraints); % U is global
		% 2nd pass modification via constraing forces, NOT hard coded X-overwrite.
	  end
    end

    ctr=ctr+1;
    set(s,'vertices',X);
    
    if isempty(get(0,'CurrentFigure'))  % figure closed
	  return
    else
	  drawnow
    end
    
end   %while

%% Compute / Recompute W  in caller workspace

    function ComputeW
	  W= inv(  (1+(dt*fdamp*Minv)) *eye(N) - (dt*dt*Minv)*K  );
	  WMinvDt2 = W*(Minv*dt*dt);
    end

%% Compute Spring Forces

    function F=BuildSpringF(X)
	  % uses X, Edg & Faccumind,    overwrites F
	  mDeltas=   X(Edg(:,2),:)-X(Edg(:,1),:)   ; % directions of forces on _1_   !
	  vCurLengths= realsqrt(sum(mDeltas .^2,  2 )  );
	  vScaledMagnitudes=(1-(vRestLengths./vCurLengths) ) .* vk;  %bugged one. looks better?

	  mForces=mDeltas .*  vScaledMagnitudes(:,[1 1 1]); % NumEdges  x 3 matrix of forces on 1
	  % it remains to spread the spring forces to the particles
	  F=accumarray(FaccumarrayInd,cat(1,mForces(:), -mForces(:)),[N,3]) ;

    end
	  
%% Compute  'Vol' FEM Force
    function F=BuildVolF(X,X0,FEMkronK)
	  colDeltaX=(X-X0).';
	  F = FEMkronK * colDeltaX(:) ;
	  F=reshape(F,3,N).';
    end
    
%% Key events

    function KeyHandling(src,evnt)

	  dat=get(src,'userdata');

	  switch evnt.Character

		case '.'
		    dt=1.1*dt;
		    ComputeW;
		    set(dat.dtTxtHandle,'string',sprintf('%g',dt) );
     		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
		case ','
		    dt=0.9*dt;
		    ComputeW;
		    set(dat.dtTxtHandle,'string',sprintf('%g',dt) );
    		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
		case 'm'
		    vk=1.1*vk;
		    K=1.1*K;
		    set(dat.kTxtHandle,'string',sprintf('%g',vk(1)) );
		    ComputeW;
    		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
		case 'n'
		    vk=0.9*vk;
		    K=0.9*K;
		    set(dat.kTxtHandle,'string',sprintf('%g',vk(1)) );
		    ComputeW;
		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
		case 'b'
		    fdamp = 1.1*fdamp;
		    set(dat.dTxtHandle,'string',sprintf('%g',fdamp ));
		    ComputeW;
		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
		case 'v' 
		    fdamp = 0.9*fdamp;
		    set(dat.dTxtHandle,'string',sprintf('%g',fdamp ));
		    ComputeW;
		    ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
 		case 'f'
			dat=RemoveAllConstraints(dat);
		case 'p'
		    dat.pause=~dat.pause;
		case 'k'
		    keyboard;
		case 'q'
		    close(gcf);
		    return;
	  end %switch
	  
	  set(src,'userdata',dat);
    end

%% Mouse Events

    function MouseDown(src,evnt)
	  [P Vdump VIdump Face FaceInd] =select3d(gco);
	  if isempty(P)
		return
	  end
	  dat=get(src,'userdata');

	  dat.CurrConstraint=FaceInd;

	  if strcmp(get(src,'SelectionType'),'normal')
		dat.MousePressed=true;
		% current design is to move the point in the plane perp to Point-CamPos.
		% a reasonable alternative is to move it perp to CamTarget-CamPos
		CamPos=get(gca,'CameraPosition')';
		dat.PlaneNormal=P-CamPos;  %Unnormalized

		b=ComputeBarys_3(P(:), Face);
		[dat.Constraints,dat.CurrConstraint]=...
		    AddConstraint(dat.Constraints,b,P,FaceInd,Srf(FaceInd,:)');

		dat.AlphaDat(FaceInd)=0.9;
	  else
		dat.Constraints=RemoveConstraint(dat.Constraints,FaceInd);
		dat.AlphaDat(FaceInd)=0.3;
	  end % if get(src,'SelectionType')==Normal

	  set(s,'FaceVertexAlphaData',dat.AlphaDat);
	  set(src,'userdata',dat);
    end

    function MouseMotion(src,evnt)
	  dat=get(src,'userdata');
	  if ~dat.MousePressed
		return;
	  end
	  BF=diff(get(gca,'CurrentPoint'))';   % first line BACK, minus 2nd line FRONT
	  CamPos=get(gca,'CameraPosition')';
	  NewPos=CamPos + (dat.PlaneNormal'*dat.PlaneNormal)/(dat.PlaneNormal'*BF)*BF;
 	  dat.Constraints(dat.CurrConstraint).FixedPos=NewPos;
 	  set(dat.Constraints(dat.CurrConstraint).MarkerHandle,'xdata',NewPos(1),...
				'ydata',NewPos(2),'zdata',NewPos(3));
	  set(src,'userdata',dat);

    end

    function MouseUp(src,evnt)
	  dat=get(src,'userdata');
	  dat.MousePressed=false;
	  set(src,'userdata',dat);
    end
    
%%  Constraint Management

function  dat=RemoveAllConstraints(dat)

    if numel(dat.Constraints)==0
	  return
    end
    delete(dat.Constraints.MarkerHandle);  % should be an array of handles
    % init empty Constraints struct
    Constraints.FaceInd=[]; % index of the constrained face
    Constraints.cVrtxInds=[]; % col vec of face-vertices indices
    Constraints.cBarys=[]; % col vec of corresponding barys
    Constraints.cDestPos=[]; % a 3x1 vec of the constrained pos
    Constraints.MarkerHandle=[]; % a handle to the line obj that draws the marker
    Constraints.ArrowHandle=[];   % for future use
    Constraints.id=[];
    dat.Constraints=Constraints;    
    dat.NumConstraints=0;
    %     	if USE_ALPHA
    dat.AlphaDat=0.3*ones(NumFaces,1);
    set(s,'FaceVertexAlphaData',dat.AlphaDat);
    % 	end

   U=sparse(zeros(0,N));
end

end    % RemoveAllConstraints


function [newCstrStruct,i]=AddConstraint(CstrStruct,Barys,P,FaceInd,VrtInds)
        global U N ForceCoeffMat dt W Minv;
        newCstrStruct=CstrStruct;
	  if ~isempty(CstrStruct)
		i=find([CstrStruct.FaceInd]==FaceInd); % might be empty
	  end
	  if (~exist('i','var') || isempty(i) )
		% new constraint

		if (isempty(CstrStruct)  || isempty([CstrStruct.FaceInd]))
		    % empty field implies empty struct in our case only.
		    i=1;
		else
		    i=numel(CstrStruct)+1;
		end

		newCstrStruct(i).FaceInd=FaceInd;
		newCstrStruct(i).VrtxInds=VrtInds;
		newCstrStruct(i).URowInd=size(U,1)+1;
		newCstrStruct(i).MarkerHandle=...
		    line('marker','o','markerfacecolor','k','visible','on','erasemode','xor');

	  end %    if (~exist('i','var') || isempty(i) )
	  
	  newCstrStruct(i).Barys=Barys;
	  newCstrStruct(i).FixedPos=P; % a 3x1 vec of the constrained pos
	  set(  newCstrStruct(i).MarkerHandle, 'xdata',P(1),'ydata',P(2),'zdata',P(3));

	  Uvec=zeros(1,N);
	  Uvec(VrtInds)=Barys;
	  U(i,:)=Uvec;
	  ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);

end % AddConstraint

function newCstrStruct=RemoveConstraint(CstrStruct,FaceInd)
        global U ForceCoeffMat dt W Minv;
        newCstrStruct=CstrStruct;
        if ~isempty(CstrStruct)
            i=find([CstrStruct.FaceInd]==FaceInd); % might be empty
        end
    if (exist('i','var') &&  ~isempty(i) )
        delete(CstrStruct(i).MarkerHandle);
	  newCstrStruct(i)=[];
	  j=CstrStruct(i).URowInd;

      U(j,:)=[];
      for jj=i:numel(newCstrStruct)
      newCstrStruct(jj).URowInd= newCstrStruct(jj).URowInd - 1;
      end
  	  ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt);
    end
    
end % RemoveConstraint

%% Propagation

	% along the way, form constraint forces applied AT BARY points (non-mesh pts)
    function [newX,newV]=ApplyConstraints(X,v,CnstrStruct)
	 global U dt  ForceCoeffMat WMinvDt2;
	 Xnat=U * X;   % 'natural' (constraint free) dt-propagation of constrained points
	 Xdest=([CnstrStruct.FixedPos]) .';    % desired positions, N x 3
	 cDelta=Xdest-Xnat;

	 % 	  ForceCoeffMat is updated only when U updates.
	  AppliedBaryForces= ForceCoeffMat * cDelta ; %  N x 3
	  % forces operating at constrained bary pts, 
	  % needed to enforce the held positions.

	  incX = WMinvDt2*U'* AppliedBaryForces;
	  newX = X + incX;
	  newV = v + (1/dt) * incX;
	  
    end % ApplyConstraints
    

    function [Xnew,Vnew]=PropagateImplicit(F,X,V)
	  global W Minv dt
	  Vnew = W* (V + (dt*Minv)*F)  ;
	  Xnew = X + dt * Vnew;
    end

    
    function ForceCoeffMat=UpdateForceCoeffMat(U,W,Minv,dt)
	  ForceCoeffMat=1/(dt*dt) * inv((U*W)*(Minv*U'));
    end