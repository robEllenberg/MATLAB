function h=easyscatter(A,varargin)
%% Accepts 2 x n or 3 x n arrays and sorts them into the appropriate scatter
% command based on the data format. Passes varargin on to scatter for color, size etc.
[m,n]=size(A);
if n==2
    scatter(A(:,1),A(:,2),varargin{:})
elseif n==3
    scatter3(A(:,1),A(:,2),A(:,3),varargin{:})
else
    error(sprintf('Invalid Data Format, m=%s,n=%d',m,n));
end
