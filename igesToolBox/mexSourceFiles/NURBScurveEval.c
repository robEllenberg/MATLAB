
static void NURBScurveEval(int deg, double *cp, int ncp, double *knot, double *us, int nus, double *ep, double *left, double *right, double *N){
    /* Modification of  ALGORITHM A4.1, The NURBS Book, L.Piegl and W. Tiller */
    
    /* Evaluates a NURBS curve at given parameter values */
    
    /* NURBScurveEval( deg - degree of NURBS, cp - pointer to control points, ncp - number of control points, knot - pointer to knot sequence, us - pointer to parameter values, nus - number of parameter values, ep - pointer to evaluated points, left - pointer to array for function BasisFuns, right - pointer to array for function BasisFuns, N - pointer to array for function BasisFuns) */
    
    int i, jj, span, ind;
    double wgh;
    
    for (jj = 0; jj < nus; jj++){
        
        if(us[jj]<=knot[deg] || deg==0){
            ep[jj*3] = cp[0]/cp[3];
            ep[jj*3+1] = cp[1]/cp[3];
            ep[jj*3+2] = cp[2]/cp[3];
        }
        else if(us[jj]>=knot[ncp]){
            ep[jj*3] = cp[4*ncp-4]/cp[4*ncp-1];
            ep[jj*3+1] = cp[4*ncp-3]/cp[4*ncp-1];
            ep[jj*3+2] = cp[4*ncp-2]/cp[4*ncp-1];
        }
        else{
            ep[jj*3]=0.0;
            ep[jj*3+1]=0.0;
            ep[jj*3+2]=0.0;
            wgh=0.0;
            
            span = FindSpan(ncp, deg, us[jj], knot);
            BasisFuns(span, us[jj], deg, knot, N, left, right);
            
            ind = span - deg;

            for (i = 0; i <= deg; i++){
                ep[jj*3] += N[i] * cp[(i+ind)*4];
                ep[jj*3+1] += N[i] * cp[(i+ind)*4+1];
                ep[jj*3+2] += N[i] * cp[(i+ind)*4+2];
                wgh += N[i] * cp[(i+ind)*4+3];
            }
            ep[jj*3]=ep[jj*3]/wgh;
            ep[jj*3+1]=ep[jj*3+1]/wgh;
            ep[jj*3+2]=ep[jj*3+2]/wgh;
            
        }
        
    }
    
}
