function b=ComputeBarys_3(MidPoint,EdgePoints)
    %receives a column 3-vector MidPoint and a matrix EdgePoints whos columns
    % are the 3 triangle points. Returns a column 3-vector b of the barycentric 
    % coordinates.
    
    if ~(size(EdgePoints)==[3 3] & numel(MidPoint)==3)
	  error('improper input sizes to ObtainBarys_3')
    elseif  all(IsNear( cross( EdgePoints(:,3)- EdgePoints(:,1), ...
						EdgePoints(:,2)- EdgePoints(:,1)), [0;0;0], 100*eps))
		error('thou have just sent an almost linear face to compute for barys.')
    end
    
    
   FarFromZero= ~IsNear(zeros(3),EdgePoints);
   if all(all(FarFromZero))    % no column is near the zero vector
	    b=EdgePoints\MidPoint;
   else
	 D= 2*min(min(EdgePoints))-1;
	 b= (EdgePoints - D(ones(3)) ) \ (MidPoint - D(ones(3,1)) ) ;
   end
   