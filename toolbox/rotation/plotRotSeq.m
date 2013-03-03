function h=plotRotSeq(Rseq,Qseq,h)
if ~exist('h','var') || isempty(h)
    h=figure();
end

set(h,'KeyPressFcn',@KeyPressFcn)
R0=eye(3);
xlabel('X')
ylabel('Y')
zlabel('Z')
axis equal
runFlag=0;
C=eye(3);
K=min(length(Qseq),length(Rseq));
plotInstance(R0,C/(K+1));
for k=1:K
    h=plotInstance(R0,C*k/K);
    for w=1:30
        updateInstance(h,Rseq{k}(Qseq(k)*w/30)*R0);
        
        while(~runFlag)
            pause(.05)
        end
        pause(.03)
    end
    R0=R0*Rseq{k}(Qseq(k));
    pause(.4)
end


    function h=plotInstance(R,C)
        
        h(1)=plotLine(R,1,C(1,:));
        h(2)=plotLine(R,2,C(2,:));
        h(3)=plotLine(R,3,C(3,:));
        
    end
    function updateInstance(h,R)
        if nargin<3
            C=eye(3);
        else
            C=mapfcn(3);
        end
        
        updateLine(h(1),R,1,C(1,:))
        updateLine(h(2),R,2,C(2,:))
        updateLine(h(3),R,3,C(3,:))
        
    end
    function KeyPressFcn(obj,event)
        
        disp(uint8(event.Character));
        switch(event.Character)
            case 32
                runFlag=1-runFlag;
        end
    end
end

function h=plotLine(R,k,C)

XData=[0 R(1,k)];
YData=[0 R(2,k)];
ZData=[0 R(3,k)];

h=line('XData',XData,'YData',YData,'ZData',ZData,'Color',C,'LineWidth',2);
end

function updateLine(h,R,k,~)

XData=[0 R(1,k)];
YData=[0 R(2,k)];
ZData=[0 R(3,k)];

set(h,'XData',XData);
set(h,'YData',YData);
set(h,'ZData',ZData);
end

