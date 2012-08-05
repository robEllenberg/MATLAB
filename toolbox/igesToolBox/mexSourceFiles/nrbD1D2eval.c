
/* nrbD1D2eval evaluates a curve point and derivatives for one parameter value */

/* nrbD1D2eval( nrbStruct - nurbs pointer, nrbDerStruct - nurbs derivative pointer, nrbDer2Struct - nurbs second derivative pointer, paramValuePtr - pointer parameter values, evalPnt - pointer point on curve, evalDer - pointer derivative, evalDer2 - pointer second derivative, bspPnts - pointer bspline point, left - pointer to array for function BasisFuns, right - pointer to array for function BasisFuns, N - pointer to array for function BasisFuns) */

/* oldBsEval will be inside the nrbD1D2eval in the future */

static void oldBsEval(int deg, double *cp, int mcp, int ncp, double *knot, double *us, int nus, double *ep, double *left, double *right, double *N){
    /* Modification of  ALGORITHM A3.1, The NURBS Book, L.Piegl and W. Tiller */
    
    /* oldBsEval( deg - degree of B-spline, cp - pointer to control points, mcp - number of elements in a control point, ncp - number of control points, knot - pointer to knot sequence, us - pointer to parameter values, nus - number of parameter values, ep - pointer to evaluated points, left - pointer to array for function BasisFuns, right - pointer to array for function BasisFuns, N - pointer to array for function BasisFuns) */
    
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


static void nrbD1D2eval(mxArray *nrbStruct, mxArray *nrbDerStruct, mxArray *nrbDer2Struct, double *paramValuePtr, double *evalPnt, double *evalDer, double *evalDer2, double *bspPnts, double *left, double *right, double *N) {
    /* nrbD1D2eval evaluates a curve point and derivatives for one parameter value */
    
    /* nrbD1D2eval( nrbStruct - nurbs pointer, nrbDerStruct - nurbs derivative pointer, nrbDer2Struct - nurbs second derivative pointer, paramValuePtr - pointer parameter values, evalPnt - pointer point on curve, evalDer - pointer derivative, evalDer2 - pointer second derivative, bspPnts - pointer bspline point, left - pointer to array for function BasisFuns, right - pointer to array for function BasisFuns, N - pointer to array for function BasisFuns) */
    
    double weightsPnts, weights;
    
    oldBsEval(((int)mxGetScalar(mxGetField(nrbStruct, 0, "order")))-1, mxGetPr(mxGetField(nrbStruct, 0, "coefs")), 4, (int)mxGetN(mxGetField(nrbStruct, 0, "coefs")), mxGetPr(mxGetField(nrbStruct, 0, "knots")), paramValuePtr, 1, bspPnts, left, right, N);
    
    evalPnt[0]=(bspPnts[0])/(bspPnts[3]);
    evalPnt[1]=(bspPnts[1])/(bspPnts[3]);
    evalPnt[2]=(bspPnts[2])/(bspPnts[3]);
    
    weightsPnts=bspPnts[3];
    
    oldBsEval(((int)mxGetScalar(mxGetField(nrbDerStruct, 0, "order")))-1, mxGetPr(mxGetField(nrbDerStruct, 0, "coefs")), 4, (int)mxGetN(mxGetField(nrbDerStruct, 0, "coefs")), mxGetPr(mxGetField(nrbDerStruct, 0, "knots")), paramValuePtr, 1, bspPnts, left, right, N);
    
    weights=bspPnts[3];
    
    evalDer[0]=(bspPnts[0]-weights*(evalPnt[0]))/weightsPnts;
    evalDer[1]=(bspPnts[1]-weights*(evalPnt[1]))/weightsPnts;
    evalDer[2]=(bspPnts[2]-weights*(evalPnt[2]))/weightsPnts;
    
    if(mxGetScalar(mxGetField(nrbDer2Struct, 0, "order"))>0){
        oldBsEval(((int)mxGetScalar(mxGetField(nrbDer2Struct, 0, "order")))-1, mxGetPr(mxGetField(nrbDer2Struct, 0, "coefs")), 4, (int)mxGetN(mxGetField(nrbDer2Struct, 0, "coefs")), mxGetPr(mxGetField(nrbDer2Struct, 0, "knots")), paramValuePtr, 1, bspPnts, left, right, N);
        
        evalDer2[0]=(bspPnts[0]-2*weights*(evalDer[0])-(bspPnts[3])*(evalPnt[0]))/weightsPnts;
        evalDer2[1]=(bspPnts[1]-2*weights*(evalDer[1])-(bspPnts[3])*(evalPnt[1]))/weightsPnts;
        evalDer2[2]=(bspPnts[2]-2*weights*(evalDer[2])-(bspPnts[3])*(evalPnt[2]))/weightsPnts;
    }
    else{
        evalDer2[0]=0.0;
        evalDer2[1]=0.0;
        evalDer2[2]=0.0;
    }
    
}
