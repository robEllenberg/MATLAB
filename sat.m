function out=sat(x,a,b)
    out=x;
    if nargin==3
        if x<a  
            out=a;
        end
        if x>b 
            out=b;
        end
    elseif nargin==2 
        if x<-a  
            out=-a;
        end
        if x>a
            out=a;
        end
    else
        warning('Supplied no bounds to input x, ouput unchanged');
    end

end
