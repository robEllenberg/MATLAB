
static void BspEval2(int degU, int degV, double *cp, int mcp, int ncp, int kcp, double *knotU, double *knotV, double *us, int nus, double *ep, double *leftU, double *rightU, double *NU, double *leftV, double *rightV, double *NV){
    /* Modification of ALGORITHM A3.5, The NURBS Book, L.Piegl and W. Tiller */
    
    /* BspEval2 evaluates a B-spline at given parameter values (u,v) */
    
    /* BspEval2( degU - degree of B-spline in u, degV - degree of B-spline in v, cp - pointer to control points, mcp - number of elements in a control point, ncp - number of control points in u, kcp - number of control points in v, knotU - pointer to knot sequence in u, knotV - pointer to knot sequence in v, us - pointer to parameter values,  nus - number of parameter values, ep - pointer to evaluated points, leftU - pointer to array for function BasisFuns, rightU - pointer to array for function BasisFuns, NU - pointer to array for function BasisFuns, leftV - pointer to array for function BasisFuns, rightV - pointer to array for function BasisFuns, NV - pointer to array for function BasisFuns) */
    
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
