function vecplot(X)
%Plot vectors stored in X as a quiver radiating from 0,0,0
% X is 3 x n or 2 x n
[m,n]=size(X);

C=hsv(n);
clf
if m==2
    for k=1:n
        line([0 X(1,k)],[0 X(2,k)],'Color',C(k,:));
    end
elseif m==3
    for k=1:n
        line([0 X(1,k)],[0 X(2,k)],[0 X(3,k)],'Color',C(k,:));
    end
end