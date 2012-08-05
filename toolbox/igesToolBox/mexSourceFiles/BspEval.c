
static void BspEval(int deg, double *cp, int mcp, int ncp, double *knot, double *us, int nus, double *ep, double *left, double *right, double *N){
    /* Modification of  ALGORITHM A3.1, The NURBS Book, L.Piegl and W. Tiller */
    
    /* BspEval evaluates a B-spline at given parameter values */
    
    /* BspEval( deg - degree of B-spline, cp - pointer to control points, mcp - number of elements in a control point, ncp - number of control points, knot - pointer to knot sequence, us - pointer to parameter values, nus - number of parameter values, ep - pointer to evaluated points, left - pointer to array for function BasisFuns, right - pointer to array for function BasisFuns, N - pointer to array for function BasisFuns) */
    
    int i, ii, jj, span, ind;
    
    for (jj = 0; jj < nus; jj++){
        
        if(us[jj]<=knot[deg] || deg==0){
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii] = cp[ii];
            }
        }
        else if(us[jj]>=knot[ncp]){
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii] = cp[mcp*ncp+ii-mcp];
            }
        }
        else{
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii]=0.0;
            }
            span = FindSpan(ncp, deg, us[jj], knot);
            BasisFuns(span, us[jj], deg, knot, N, left, right);
            
            ind = span - deg;
            
            for (i = 0; i <= deg; i++){
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii] += N[i] * cp[(i+ind)*mcp+ii];
                }
            }
        }
        
    }
    
}
