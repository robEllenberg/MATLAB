
/* nrbD1D2eval2 evaluates a surface point and derivatives for one parameter value */
    
/* nrbD1D2eval2( nrbStruct - nurbs pointer, nrbDerStruct - nurbs derivative pointer, nrbDer2Struct - nurbs second derivative pointer, paramValuePtr - pointer parameter values, evalPnt - pointer point on surface, evalDeru - pointer derivative u, evalDerv - pointer derivative v, evalDeruu - pointer second derivative uu, evalDeruv - pointer second derivative uv, evalDervv - pointer second derivative vv, bspPnts - pointer bspline point, leftU - pointer to array for function BasisFuns, rightU - pointer to array for function BasisFuns, NU - pointer to array for function BasisFuns, leftV - pointer to array for function BasisFuns, rightV - pointer to array for function BasisFuns, NV - pointer to array for function BasisFuns) */

/* oldBsEval2 will be inside the nrbD1D2eval2 in the future */

static void oldBsEval2(int degU, int degV, double *cp, int mcp, int ncp, int kcp, double *knotU, double *knotV, double *us, int nus, double *ep, double *leftU, double *rightU, double *NU, double *leftV, double *rightV, double *NV){
    /* Modification of ALGORITHM A3.5, The NURBS Book, L.Piegl and W. Tiller */
    
    /* oldBsEval2( degU - degree of B-spline in u, degV - degree of B-spline in v, cp - pointer to control points, mcp - number of elements in a control point, ncp - number of control points in u, kcp - number of control points in v, knotU - pointer to knot sequence in u, knotV - pointer to knot sequence in v, us - pointer to parameter values,  nus - number of parameter values, ep - pointer to evaluated points, leftU - pointer to array for function BasisFuns, rightU - pointer to array for function BasisFuns, NU - pointer to array for function BasisFuns, leftV - pointer to array for function BasisFuns, rightV - pointer to array for function BasisFuns, NV - pointer to array for function BasisFuns) */
    
    int i, j, ii, jj, spanU, spanV, ind, ind2;
    
    for (jj = 0; jj < nus; jj++){
        
        if(us[2*jj]<=knotU[degU] || degU==0){
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii] = cp[ii];
                }
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii] = cp[mcp*ncp*(kcp-1)+ii];
                }
            }
            else{
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii]=0.0;
                }
                spanV = FindSpan(kcp, degV, us[2*jj+1], knotV);
                BasisFuns(spanV, us[2*jj+1], degV, knotV, NV, leftV, rightV);
                
                ind = spanV - degV;
                
                for (i = 0; i <= degV; i++){
                    for (ii = 0; ii < mcp; ii++){
                        ep[jj*mcp+ii] += NV[i] * cp[(ind+i)*mcp*ncp+ii];
                    }
                }
            }
        }
        else if(us[2*jj]>=knotU[ncp]){
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii] = cp[ii+mcp*ncp-mcp];
                }
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii] = cp[mcp*ncp*kcp+ii-mcp];
                }
            }
            else{
                for (ii = 0; ii < mcp; ii++){
                    ep[jj*mcp+ii]=0.0;
                }
                spanV = FindSpan(kcp, degV, us[2*jj+1], knotV);
                BasisFuns(spanV, us[2*jj+1], degV, knotV, NV, leftV, rightV);
                
                ind = spanV - degV;
                
                for (i = 0; i <= degV; i++){
                    for (ii = 0; ii < mcp; ii++){
                        ep[jj*mcp+ii] += NV[i] * cp[(ind+i+1)*mcp*ncp+ii-mcp];
                    }
                }
            }
        }
        else{
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii]=0.0;
            }
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                spanU = FindSpan(ncp, degU, us[2*jj], knotU);
                BasisFuns(spanU, us[2*jj], degU, knotU, NU, leftU, rightU);
                
                ind = spanU - degU;
                
                for (i = 0; i <= degU; i++){
                    for (ii = 0; ii < mcp; ii++){
                        ep[jj*mcp+ii] += NU[i] * cp[(ind+i)*mcp+ii];
                    }
                }
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                spanU = FindSpan(ncp, degU, us[2*jj], knotU);
                BasisFuns(spanU, us[2*jj], degU, knotU, NU, leftU, rightU);
                
                ind = spanU - degU;
                
                for (i = 0; i <= degU; i++){
                    for (ii = 0; ii < mcp; ii++){
                        ep[jj*mcp+ii] += NU[i] * cp[(ind+i)*mcp+ii+(kcp-1)*mcp*ncp];
                    }
                }
            }
            else{
                spanU = FindSpan(ncp, degU, us[2*jj], knotU);
                BasisFuns(spanU, us[2*jj], degU, knotU, NU, leftU, rightU);
                
                spanV = FindSpan(kcp, degV, us[2*jj+1], knotV);
                BasisFuns(spanV, us[2*jj+1], degV, knotV, NV, leftV, rightV);
                
                ind = spanU - degU;
                ind2 = spanV - degV;
                
                for (i = 0; i <= degV; i++){
                    for (j = 0; j <= degU; j++){
                        for (ii = 0; ii < mcp; ii++){
                            ep[jj*mcp+ii] += NV[i] * NU[j] * cp[(i+ind2)*mcp*ncp+(j+ind)*mcp+ii];
                        }
                    }
                }
            }
        }
        
    }
    
}


static void nrbD1D2eval2(mxArray *nrbStruct, mxArray *nrbDerStruct, mxArray *nrbDer2Struct, double *paramValuePtr, double *evalPnt, double *evalDeru, double *evalDerv, double *evalDeruu, double *evalDeruv, double *evalDervv, double *bspPnts, double *leftU, double *rightU, double *NU, double *leftV, double *rightV, double *NV) {
    /* nrbD1D2eval2 evaluates a surface point and derivatives for one parameter value */
    
    /* nrbD1D2eval2( nrbStruct - nurbs pointer, nrbDerStruct - nurbs derivative pointer, nrbDer2Struct - nurbs second derivative pointer, paramValuePtr - pointer parameter values, evalPnt - pointer point on surface, evalDeru - pointer derivative u, evalDerv - pointer derivative v, evalDeruu - pointer second derivative uu, evalDeruv - pointer second derivative uv, evalDervv - pointer second derivative vv, bspPnts - pointer bspline point, leftU - pointer to array for function BasisFuns, rightU - pointer to array for function BasisFuns, NU - pointer to array for function BasisFuns, leftV - pointer to array for function BasisFuns, rightV - pointer to array for function BasisFuns, NV - pointer to array for function BasisFuns) */
    
    double weightsPnts, weights , weights2;
    
    oldBsEval2(((int)mxGetPr(mxGetField(nrbStruct, 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(nrbStruct, 0, "order"))[1])-1, mxGetPr(mxGetField(nrbStruct, 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(nrbStruct, 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(nrbStruct, 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(nrbStruct, 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(nrbStruct, 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
    
    evalPnt[0]=(bspPnts[0])/(bspPnts[3]);
    evalPnt[1]=(bspPnts[1])/(bspPnts[3]);
    evalPnt[2]=(bspPnts[2])/(bspPnts[3]);
    
    weightsPnts=bspPnts[3];
    
    oldBsEval2(((int)mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "order"))[1])-1, mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDerStruct, 0), 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
    
    weights=bspPnts[3];
    
    evalDeru[0]=(bspPnts[0]-weights*(evalPnt[0]))/weightsPnts;
    evalDeru[1]=(bspPnts[1]-weights*(evalPnt[1]))/weightsPnts;
    evalDeru[2]=(bspPnts[2]-weights*(evalPnt[2]))/weightsPnts;
    
    oldBsEval2(((int)mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "order"))[1])-1, mxGetPr(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDerStruct, 1), 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
    
    weights2=(bspPnts[3]);
    
    evalDerv[0]=(bspPnts[0]-weights2*(evalPnt[0]))/weightsPnts;
    evalDerv[1]=(bspPnts[1]-weights2*(evalPnt[1]))/weightsPnts;
    evalDerv[2]=(bspPnts[2]-weights2*(evalPnt[2]))/weightsPnts;
    
    if((mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "order"))[0])>0 && (mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "order"))[1])>0){
        oldBsEval2(((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "order"))[1])-1, mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 0), 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
        
        evalDeruu[0]=(bspPnts[0]-2*weights*(evalDeru[0])-(bspPnts[3])*(evalPnt[0]))/weightsPnts;
        evalDeruu[1]=(bspPnts[1]-2*weights*(evalDeru[1])-(bspPnts[3])*(evalPnt[1]))/weightsPnts;
        evalDeruu[2]=(bspPnts[2]-2*weights*(evalDeru[2])-(bspPnts[3])*(evalPnt[2]))/weightsPnts;
    }
    else{
        evalDeruu[0]=0.0;
        evalDeruu[1]=0.0;
        evalDeruu[2]=0.0;
    }
    
    if((mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "order"))[0])>0 && (mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "order"))[1])>0){
        oldBsEval2(((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "order"))[1])-1, mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 1), 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
        
        evalDeruv[0]=(bspPnts[0]-weights*(evalDeru[0])-weights2*(evalDerv[0])-(bspPnts[3])*(evalPnt[0]))/weightsPnts;
        evalDeruv[1]=(bspPnts[1]-weights*(evalDeru[1])-weights2*(evalDerv[1])-(bspPnts[3])*(evalPnt[1]))/weightsPnts;
        evalDeruv[2]=(bspPnts[2]-weights*(evalDeru[2])-weights2*(evalDerv[2])-(bspPnts[3])*(evalPnt[2]))/weightsPnts;
    }
    else{
        evalDeruv[0]=0.0;
        evalDeruv[1]=0.0;
        evalDeruv[2]=0.0;
    }
    
    if((mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "order"))[0])>0 && (mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "order"))[1])>0){
        oldBsEval2(((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "order"))[0])-1, ((int)mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "order"))[1])-1, mxGetPr(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(mxGetCell(nrbDer2Struct, 2), 0, "knots"), 1)), paramValuePtr, 1, bspPnts, leftU, rightU, NU, leftV, rightV, NV);
        
        evalDervv[0]=(bspPnts[0]-2*weights2*(evalDerv[0])-(bspPnts[3])*(evalPnt[0]))/weightsPnts;
        evalDervv[1]=(bspPnts[1]-2*weights2*(evalDerv[1])-(bspPnts[3])*(evalPnt[1]))/weightsPnts;
        evalDervv[2]=(bspPnts[2]-2*weights2*(evalDerv[2])-(bspPnts[3])*(evalPnt[2]))/weightsPnts;
    }
    else{
        evalDervv[0]=0.0;
        evalDervv[1]=0.0;
        evalDervv[2]=0.0;
    }
    
}
