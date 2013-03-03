function h=plotRotationMatrix(Rstack,h,mapfcn)
if ~exist('h','var') || isempty(h)
    h=figure();
end

R=reshape(Rstack,3,3,[]);

hold on
R0=eye(3);
for k=1:size(R,3)
    R0=R(:,:,k)*R0;
    plotInstance(R0);
    pause(.5)
end
xlabel('X')
ylabel('Y')
zlabel('Z')
axis([-1 1 -1 1 -1 1])
view(-90,90)
axis square



    function plotInstance(R)
        if nargin<3
            C=eye(3);
        else
            C=mapfcn(3);
        end
        plotLine(R,1,C(1,:))
        plotLine(R,2,C(2,:))
        plotLine(R,3,C(3,:))
        
        
    end
end

function plotLine(R,k,C)

XData=[0 R(1,k)];
YData=[0 R(2,k)];
ZData=[0 R(3,k)];

line(XData,YData,ZData,'Color',C,'LineWidth',2)
end
