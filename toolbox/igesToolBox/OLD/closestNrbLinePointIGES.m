function [P,UV,t]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV,r0,v)
% Closest points of NURBS patch and line/point using Newton's Method.
%
% Line (3D): r=r0+t*v
% Point (3D): r0
%
% Usage:
%
% %Line
% [P,UV,t]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV,r0,v)
%
% %Point
% [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV,r0)
%
% Input:
% nurbs - NURBS object
% dnurbs,d2nurbs - NURBS derivatives (output from nrbDerivativesIGES).
% UV - Initial start parametric values
% r0,(v) - See Line/Point (3D). (size 3x1) (Initial t=0.)
%
% Output:
% P - Closest points on NURBS patch.
% UV - NURBS parameters at closest point.
% (t - Line parameter at closest point.)
%
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 13253&objectType=file
%
% written by Per Bergström 2009-04-23
%

if size(UV,1)==2

    if nargin==6

        numIter=20;

        t=zeros(1,size(UV,2));

        H=zeros(3,3);
        neggrad=zeros(3,1);
        x=zeros(3,1);

        for i=1:size(UV,2)

            x(1:2)=UV(:,i);
            x(3)=t(i);

            if x(1)<nurbs.knots{1}(1)
                x(1)=nurbs.knots{1}(1);
            elseif x(1)>nurbs.knots{1}(end)
                x(1)=nurbs.knots{1}(end);
            end

            if x(2)<nurbs.knots{2}(1)
                x(2)=nurbs.knots{2}(1);
            elseif x(2)>nurbs.knots{2}(end)
                x(2)=nurbs.knots{2}(end);
            end

            for j=1:numIter

                [S,Sw,Su,Sv,Suu,Suv,Svv]=nrbevalIGES(nurbs,x(1:2),dnurbs,d2nurbs);

                res=r0+x(3)*v-S;

                H(1,1)=dot(Su,Su)-dot(Suu,res);
                H(1,2)=dot(Su,Sv)-dot(Suv,res);
                H(1,3)=-dot(Su,v);
                H(2,1)=H(1,2);
                H(2,2)=dot(Sv,Sv)-dot(Svv,res);
                H(2,3)=-dot(Sv,v);
                H(3,1)=H(1,3);
                H(3,2)=H(2,3);
                H(3,3)=dot(v,v);

                neggrad(1)=dot(Su,res);
                neggrad(2)=dot(Sv,res);
                neggrad(3)=-dot(v,res);
                
                s=H\neggrad;
                if all(isfinite(s))
                    x=x+s;
                else
                    break
                end
                
                if x(1)<nurbs.knots{1}(1)
                    x(1)=nurbs.knots{1}(1);
                elseif x(1)>nurbs.knots{1}(end)
                    x(1)=nurbs.knots{1}(end);
                end

                if x(2)<nurbs.knots{2}(1)
                    x(2)=nurbs.knots{2}(1);
                elseif x(2)>nurbs.knots{2}(end)
                    x(2)=nurbs.knots{2}(end);
                end

                if norm(s)<1e-10
                    break
                end

            end

            UV(:,i)=x(1:2);
            t(i)=x(3);

        end

        P=nrbevalIGES(nurbs,UV);

    elseif nargin==5

        numIter=20;

        t=[];

        H=zeros(2,2);
        neggrad=zeros(2,1);
        x=zeros(2,1);

        for i=1:size(UV,2)

            x(1:2)=UV(:,i);

            if x(1)<nurbs.knots{1}(1)
                x(1)=nurbs.knots{1}(1);
            elseif x(1)>nurbs.knots{1}(end)
                x(1)=nurbs.knots{1}(end);
            end

            if x(2)<nurbs.knots{2}(1)
                x(2)=nurbs.knots{2}(1);
            elseif x(2)>nurbs.knots{2}(end)
                x(2)=nurbs.knots{2}(end);
            end

            for j=1:numIter

                [S,Sw,Su,Sv,Suu,Suv,Svv]=nrbevalIGES(nurbs,x(1:2),dnurbs,d2nurbs);

                res=r0-S;

                H(1,1)=dot(Su,Su)-dot(Suu,res);
                H(1,2)=dot(Su,Sv)-dot(Suv,res);
                H(2,1)=H(1,2);
                H(2,2)=dot(Sv,Sv)-dot(Svv,res);

                neggrad(1)=dot(Su,res);
                neggrad(2)=dot(Sv,res);

                s=H\neggrad;
                if all(isfinite(s))
                    x=x+s;
                else
                    break
                end

                if x(1)<nurbs.knots{1}(1)
                    x(1)=nurbs.knots{1}(1);
                elseif x(1)>nurbs.knots{1}(end)
                    x(1)=nurbs.knots{1}(end);
                end

                if x(2)<nurbs.knots{2}(1)
                    x(2)=nurbs.knots{2}(1);
                elseif x(2)>nurbs.knots{2}(end)
                    x(2)=nurbs.knots{2}(end);
                end

                if norm(s)<1e-10
                    break
                end

            end

            UV(:,i)=x(1:2);

        end

        P=nrbevalIGES(nurbs,UV);

    end

elseif size(UV,1)==1

    if nargin==6

        numIter=20;

        t=zeros(1,size(UV,2));

        H=zeros(2,2);
        neggrad=zeros(2,1);
        x=zeros(2,1);

        for i=1:size(UV,2)

            x(1)=UV(:,i);
            x(2)=t(i);

            if x(1)<nurbs.knots(1)
                x(1)=nurbs.knots(1);
            elseif x(1)>nurbs.knots(end)
                x(1)=nurbs.knots(end);
            end

            for j=1:numIter

                [C,Cw,Cu,Cuu]=nrbevalIGES(nurbs,x(1),dnurbs,d2nurbs);

                res=r0+x(2)*v-C;

                H(1,1)=dot(Cu,Cu)-dot(Cuu,res);
                H(1,2)=-dot(Cu,v);
                H(2,1)=H(1,2);
                H(2,2)=dot(v,v);

                neggrad(1)=dot(Cu,res);
                neggrad(2)=-dot(v,res);

                s=H\neggrad;
                if all(isfinite(s))
                    x=x+s;
                else
                    break
                end

                if x(1)<nurbs.knots(1)
                    x(1)=nurbs.knots(1);
                elseif x(1)>nurbs.knots(end)
                    x(1)=nurbs.knots(end);
                end

                if norm(s)<1e-10
                    break
                end

            end

            UV(:,i)=x(1);
            t(i)=x(2);

        end

        P=nrbevalIGES(nurbs,UV);

    elseif nargin==5

        numIter=20;

        t=[];

        for i=1:size(UV,2)

            x=UV(:,i);

            if x<nurbs.knots(1)
                x=nurbs.knots(1);
            elseif x>nurbs.knots(end)
                x=nurbs.knots(end);
            end

            for j=1:numIter

                [C,Cw,Cu,Cuu]=nrbevalIGES(nurbs,x,dnurbs,d2nurbs);

                res=r0-C;

                s=dot(Cu,res)/(dot(Cu,Cu)-dot(Cuu,res));
                if all(isfinite(s))
                    x=x+s;
                else
                    break
                end

                if x<nurbs.knots(1)
                    x=nurbs.knots(1);
                elseif x>nurbs.knots(end)
                    x=nurbs.knots(end);
                end

                if abs(s)<1e-10
                    break
                end

            end

            UV(:,i)=x;

        end

        P=nrbevalIGES(nurbs,UV);

    end

end

