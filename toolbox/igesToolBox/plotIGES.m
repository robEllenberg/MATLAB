function plotIGES(ParameterData,srf,fignr,subd,holdoff_flag,fine_flag)
% PLOTIGES plots surfaces, curves and points from IGES-file.
% 
% Simple usage:
% 
% plotIGES(ParameterData)
% 
% or
% 
% plotIGES(ParameterData,1)
%
% Ordinary usage:
% 
% plotIGES(ParameterData,srf,fignr,subd,holdoff_flag)
% 
% Input:
% 
% ParameterData - Parameter data from IGES file. ParameterData
%                 is the output from IGES2MATLAB.
% srf - Flag for surface plotting. (0,1,2).
%        0 (default), no surfaces are plotted,
%        1 the surface is plotted as triangular patches,
%        2 the surface is plotted as triangular mesh.
% fignr - Figure number of the plot. 1 default.
% subd - Nuber of subdivisions when plotting curves. 
%        subd is nubmer of subdivisions for each parameter when 
%        plotting surfaces. 100 default.
% holdoff_flag - Bolean value (1/0). If 1 then hold off the plot
%                when the plot is done. 1 default.
% fine_flag - Bolean value (1/0). If 0 the surface will be rough
%             and if 1 the surface will be finer. 0 default.
%                
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
% 
% written by Per Bergström 2009-12-04
%               

if nargin<6
    fine_flag=0;
    if nargin<5
        holdoff_flag=1;
        if nargin<4
            subd=100;
            if nargin<3
                fignr=1;
                if nargin<2
                    srf=0;
                    if nargin<1
                        error('plotIGES must have an input');
                    end
                end
            end
        end
    end
end

if isempty(ParameterData)
    error('Empty ParameterData');
elseif not(iscell(ParameterData))
    error('Invalid ParameterData. Must be a cell array!');
end

if isempty(srf)
    srf=0;
elseif not(srf==0 | srf==1 | srf==2)
    srf=0;
end

srf0not=not(srf==0);
srf1=srf==1;

if isempty(fignr)
    fignr=1;
else
    fignr=round(fignr);
end

if fignr<1
    fignr=1;
end

if isempty(subd)
    subd=100;
else
    subd=round(subd);
end

if subd<5
    subd=5;
end

if isempty(holdoff_flag)
    holdoff_flag=1;
elseif not(holdoff_flag==0 | holdoff_flag==1)
    holdoff_flag=1;
end

if isempty(fine_flag)
    fine_flag=0;
elseif not(fine_flag==0 | fine_flag==1)
    fine_flag=0;
end

subd=subd+1;  % subd now number of points, not number of subintervals

siz=length(ParameterData);

if srf1
    clr=[0.53 0.24 0.24];
    lclrf=0.3;
    for i=siz:-1:1
        if ParameterData{i}.type==314
            clr=[ParameterData{i}.cc1 ParameterData{i}.cc2 ParameterData{i}.cc3]/100;
            break
        end
    end
else
    clr=[0 0 1];
    lclrf=0.5;
end

figure(fignr),hold on;

for i=1:siz
    
    [P,isSCP,isSup]=retSrfCrvPnt(2,ParameterData,1,i,subd,3);
    
    if and(isSCP,not(isSup))
        
        plot3(P(1,:),P(2,:),P(3,:),'Color',lclrf*clr,'LineWidth',1);
        
    elseif not(isSCP)
        
        [P,isSCP]=retSrfCrvPnt(3,ParameterData,1,i);
        
        if isSCP
            
            plot3(ParameterData{i}.x,ParameterData{i}.y,ParameterData{i}.z,'r.');
            
        elseif srf0not
            
            if fine_flag
                [P,isSCP,isSup,TRI]=retSrfCrvPnt(1,ParameterData,1,i,subd,1);
            else
                [P,isSCP,isSup,TRI]=retSrfCrvPnt(1,ParameterData,1,i,subd);
            end
            
            if and(isSCP,not(isSup))
                if srf1
                    patch('faces',TRI,'vertices',P','FaceColor',clr,'EdgeColor','none');
                else
                    patch('faces',TRI,'vertices',P','FaceColor','none','EdgeColor','b');
                end
            end
            
        end
    end
    
end

axis equal;

if holdoff_flag
    hold off;
end