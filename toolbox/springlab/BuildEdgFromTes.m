function Edg=BuildEdgFromTes(Tes)
    % given a t-by-4 matrix of indices (such as returnd by delaunay3), the function
    % produces a list of all edges in the tesselation, than removes duplicities.
    % (not optimal - if used for real time, a better scheme is in order).
    
	Edg = [	Tes(:,[1 2]) ;
				Tes(:,[1 3]) ;
				Tes(:,[1 4]) ;
				Tes(:,[2 3]) ;
				Tes(:,[2 4]) ;
				Tes(:,[3 4]) ] ;
			  
	Edg=unique(sort(Edg,2),'rows');
	
end
	