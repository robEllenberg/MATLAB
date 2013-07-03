function K=FEMBuildKtemp(X,Tes,lambda,mu)
    % gives the FEM stiffness matrix K. X is an N-by-3 list of vertex coordinates,
    % Tes is an NT-by-4 matrix whose each row is made of indices of a specific
    % tetrahedron, lambda/mu are the lame coefficients (uniform, in this 
    % implementation) .
    % the elastic forces are K*deltaX   (without minus)

N=size(X,1);
NT=size(Tes,1);
K=zeros(3*N);
X=[X,ones(N,1)]; % for optimization in the build of beta's

for i=1:NT;
    IncK=zeros(12);
    
    ind=Tes(i,:)';
    ind3=3*ind(:,[1 1 1]) - [2 1 0;2 1 0;2 1 0;2 1 0];
    ind3=ind3';
    
    matB=X(ind,:);
    vol6 = abs(det(matB));
    matB=inv(matB.');
    
    for j=1:4
	  for k=1:4
	fProduct=matB(j,1:3) * matB(k,1:3).';
	matTemp=zeros(3);
		
		for a=1:3	
			for b=1:3	
			    matTemp(a,b) = matTemp(a,b) +  (lambda* matB(j,a)*matB(k,b) + mu*matB(j,b)*matB(k,a));
			end %b
		end % a
		matTemp = matTemp + mu*fProduct * eye(3);
		matTemp = matTemp * 0.08333333*vol6;
		IncK(3*j-2:3*j,3*k-2:3*k) = IncK(3*j-2:3*j,3*k-2:3*k) + matTemp;
	
	  end %k
    end %j
    
	K(ind3,ind3)=K(ind3,ind3)+IncK;
end  %i

K=-K;
