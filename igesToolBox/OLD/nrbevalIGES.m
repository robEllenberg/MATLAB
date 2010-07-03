function [P,Pw,Pu,Pv,Puu,Puv,Pvv]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
% Evaluates NURBS (and its derivatives) at given parametric values.
%
% Usage 1 (NURBS curve):
%
% P=nrbevalIGES(nurbs,UV)
% [P,Pw]=nrbevalIGES(nurbs,UV)
% [P,Pw,Pu]=nrbevalIGES(nurbs,UV,dnurbs)
% [P,Pw,Pu,Puu]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
% 
% Usage 2 (NURBS surface):
%
% P=nrbevalIGES(nurbs,UV)
% [P,Pw]=nrbevalIGES(nurbs,UV)
% [P,Pw,Pu,Pv]=nrbevalIGES(nurbs,UV,dnurbs)
% [P,Pw,Pu,Pv,Puu,Puv,Pvv]=nrbevalIGES(nurbs,UV,dnurbs,d2nurbs)
% 
% Input:
% nurbs - NURBS object
% UV - Parameters
% dnurbs,d2nurbs - NURBS derivatives (output from nrbDerivativesIGES).
% 
% Output:
% P - Points (evaluated NURBS). In case [P,Pw], P is unweighted (obtain weighted by P=P.*Pw).
% Pw - weights as a matrix.
% Pu,Pv - First derivatives.
% Puu,Puv,Pvv - Second derivatives.
%
% m-file can be downloaded for free at
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 13253&objectType=file
%
% written by Per Bergström 2008-04-25
%

if size(UV,1)==2

    nUV = size(UV,2);

    degree = nurbs.order-1;

    val = reshape(nurbs.coefs,4*nurbs.number(1),nurbs.number(2));
    val = bspeval(degree(2),val,nurbs.knots{2},UV(2,:));
    val = reshape(val,[4 nurbs.number(1) nUV]);

    for i = 1:nUV
        coefs = squeeze(val(:,:,i));
        pw(:,i) = bspeval(degree(1),coefs,nurbs.knots{1},UV(1,i));
    end

    if nargout==1
        P = pw(1:3,:)./repmat(pw(4,:),3,1);
    elseif nargout==2
        P=pw(1:3,:);
        Pw=repmat(pw(4,:),3,1);
    elseif and(nargout>2,nargin>2)
        Pw=repmat(pw(4,:),3,1);
        P = pw(1:3,:)./Pw;

        % diffNURBS evaluation

        % u
        [cup,cuw] = nrbevalIGES(dnurbs{1},UV);
        Pu = (cup-cuw.*P)./Pw;

        % v
        [cvp,cvw] = nrbevalIGES(dnurbs{2},UV);
        Pv = (cvp-cvw.*P)./Pw;

        if and(nargout>4,nargin==4)

            % diff2NURBS evaluation

            % uu
            if min(d2nurbs{1}.order)>0
                [cuup,cuuw] = nrbevalIGES(d2nurbs{1},UV);
                Puu = (cuup-2*cuw.*Pu-cuuw.*P)./Pw;
            else
                Puu = zeros(3,size(UV,2));
            end

            % uv
            if min(d2nurbs{2}.order)>0
                [cuvp,cuvw] = nrbevalIGES(d2nurbs{2},UV);
                Puv = (cuvp-cuw.*Pu-cvw.*Pv-cuvw.*P)./Pw;
            else
                Puv = zeros(3,size(UV,2));
            end

            % vv
            if min(d2nurbs{3}.order)>0
                [cvvp,cvvw] = nrbevalIGES(d2nurbs{3},UV);
                Pvv = (cvvp-2*cvw.*Pv-cvvw.*P)./Pw;
            else
                Pvv = zeros(3,size(UV,2));
            end

        end

    end

elseif size(UV,1)==1

    val = bspeval(nurbs.order-1,nurbs.coefs,nurbs.knots,UV);

    if nargout==1
        P = val(1:3,:)./repmat(val(4,:),3,1);
    elseif nargout==2
        P=val(1:3,:);
        Pw=repmat(val(4,:),3,1);
    elseif and(nargout>2,nargin>2)
        Pw=repmat(val(4,:),3,1);
        P = val(1:3,:)./Pw;

        % diffNURBS evaluation

        % u
        [cup,cuw] = nrbevalIGES(dnurbs,UV);
        Pu = (cup-cuw.*P)./Pw;

        if and(nargout>3,nargin==4)

            % diff2NURBS evaluation

            % uu
            if min(d2nurbs.order)>0
                [cuup,cuuw] = nrbevalIGES(d2nurbs,UV);
                Pv = (cuup-2*cuw.*Pu-cuuw.*P)./Pw;
            else
                Pv = zeros(3,size(UV,2));
            end
            
            Puu=Pv;

        end

    end

end