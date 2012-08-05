
static void NURBSsurfaceEval(int degU, int degV, double *cp, int ncp, int kcp, double *knotU, double *knotV, double *us, int nus, double *ep, double *leftU, double *rightU, double *NU, double *leftV, double *rightV, double *NV){
    /* Modification of  ALGORITHM A4.3, The NURBS Book, L.Piegl and W. Tiller */
    
    /* Evaluates a NURBS surface at given parameter values */
    
    /* NURBSsurfaceEval( degU - degree of NURBS in u, degV - degree of NURBS in v, cp - pointer to control points, ncp - number of control points in u, kcp - number of control points in v, knotU - pointer to knot sequence in u, knotV - pointer to knot sequence in v, us - pointer to parameter values,  nus - number of parameter values, ep - pointer to evaluated points, leftU - pointer to array for function BasisFuns, rightU - pointer to array for function BasisFuns, NU - pointer to array for function BasisFuns, leftV - pointer to array for function BasisFuns, rightV - pointer to array for function BasisFuns, NV - pointer to array for function BasisFuns) */
    
    int i, j, jj, spanU, spanV, ind, ind2;
    double wgh;
    
    for (jj = 0; jj < nus; jj++){
        
        if(us[2*jj]<=knotU[degU] || degU==0){
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                ep[jj*3] = cp[0]/cp[3];
                ep[jj*3+1] = cp[1]/cp[3];
                ep[jj*3+2] = cp[2]/cp[3];
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                ep[jj*3] = cp[4*ncp*(kcp-1)]/cp[4*ncp*(kcp-1)+3];
                ep[jj*3+1] = cp[4*ncp*(kcp-1)+1]/cp[4*ncp*(kcp-1)+3];
                ep[jj*3+2] = cp[4*ncp*(kcp-1)+2]/cp[4*ncp*(kcp-1)+3];
            }
            else{
                ep[jj*3]=0.0;
                ep[jj*3+1]=0.0;
                ep[jj*3+2]=0.0;
                wgh=0.0;
                
                spanV = FindSpan(kcp, degV, us[2*jj+1], knotV);
                BasisFuns(spanV, us[2*jj+1], degV, knotV, NV, leftV, rightV);
                
                ind = spanV - degV;
                
                for (i = 0; i <= degV; i++){
                    ep[jj*3] += NV[i] * cp[(ind+i)*4*ncp];
                    ep[jj*3+1] += NV[i] * cp[(ind+i)*4*ncp+1];
                    ep[jj*3+2] += NV[i] * cp[(ind+i)*4*ncp+2];
                    wgh += NV[i] * cp[(ind+i)*4*ncp+3];
                }
                ep[jj*3]=ep[jj*3]/wgh;
                ep[jj*3+1]=ep[jj*3+1]/wgh;
                ep[jj*3+2]=ep[jj*3+2]/wgh;
            }
        }
        else if(us[2*jj]>=knotU[ncp]){
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                ep[jj*3] = cp[4*ncp-4]/cp[4*ncp-1];
                ep[jj*3+1] = cp[4*ncp-3]/cp[4*ncp-1];
                ep[jj*3+2] = cp[4*ncp-2]/cp[4*ncp-1];
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                ep[jj*3] = cp[4*ncp*kcp-4]/cp[4*ncp*kcp-1];
                ep[jj*3+1] = cp[4*ncp*kcp-3]/cp[4*ncp*kcp-1];
                ep[jj*3+2] = cp[4*ncp*kcp-2]/cp[4*ncp*kcp-1];
            }
            else{
                ep[jj*3]=0.0;
                ep[jj*3+1]=0.0;
                ep[jj*3+2]=0.0;
                wgh=0.0;
                
                spanV = FindSpan(kcp, degV, us[2*jj+1], knotV);
                BasisFuns(spanV, us[2*jj+1], degV, knotV, NV, leftV, rightV);
                
                ind = spanV - degV;
                
                for (i = 0; i <= degV; i++){
                    ep[jj*3] += NV[i] * cp[(ind+i+1)*4*ncp-4];
                    ep[jj*3+1] += NV[i] * cp[(ind+i+1)*4*ncp-3];
                    ep[jj*3+2] += NV[i] * cp[(ind+i+1)*4*ncp-2];
                    wgh += NV[i] * cp[(ind+i+1)*4*ncp-1];
                }
                ep[jj*3]=ep[jj*3]/wgh;
                ep[jj*3+1]=ep[jj*3+1]/wgh;
                ep[jj*3+2]=ep[jj*3+2]/wgh;
            }
        }
        else{
            
            ep[jj*3]=0.0;
            ep[jj*3+1]=0.0;
            ep[jj*3+2]=0.0;
            wgh=0.0;
            
            if(us[2*jj+1]<=knotV[degV] || degV==0){
                spanU = FindSpan(ncp, degU, us[2*jj], knotU);
                BasisFuns(spanU, us[2*jj], degU, knotU, NU, leftU, rightU);
                
                ind = spanU - degU;
                
                for (i = 0; i <= degU; i++){
                    ep[jj*3] += NU[i] * cp[(ind+i)*4];
                    ep[jj*3+1] += NU[i] * cp[(ind+i)*4+1];
                    ep[jj*3+2] += NU[i] * cp[(ind+i)*4+2];
                    wgh += NU[i] * cp[(ind+i)*4+3];
                }
                ep[jj*3]=ep[jj*3]/wgh;
                ep[jj*3+1]=ep[jj*3+1]/wgh;
                ep[jj*3+2]=ep[jj*3+2]/wgh;
            }
            else if(us[2*jj+1]>=knotV[kcp]){
                spanU = FindSpan(ncp, degU, us[2*jj], knotU);
                BasisFuns(spanU, us[2*jj], degU, knotU, NU, leftU, rightU);
                
                ind = spanU - degU;
                
                for (i = 0; i <= degU; i++){
                    ep[jj*3] += NU[i] * cp[(ind+i)*4+(kcp-1)*4*ncp];
                    ep[jj*3+1] += NU[i] * cp[(ind+i)*4+1+(kcp-1)*4*ncp];
                    ep[jj*3+2] += NU[i] * cp[(ind+i)*4+2+(kcp-1)*4*ncp];
                    wgh += NU[i] * cp[(ind+i)*4+3+(kcp-1)*4*ncp];
                }
                ep[jj*3]=ep[jj*3]/wgh;
                ep[jj*3+1]=ep[jj*3+1]/wgh;
                ep[jj*3+2]=ep[jj*3+2]/wgh;
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
                        ep[jj*3] += NV[i] * NU[j] * cp[(i+ind2)*4*ncp+(j+ind)*4];
                        ep[jj*3+1] += NV[i] * NU[j] * cp[(i+ind2)*4*ncp+(j+ind)*4+1];
                        ep[jj*3+2] += NV[i] * NU[j] * cp[(i+ind2)*4*ncp+(j+ind)*4+2];
                        wgh += NV[i] * NU[j] * cp[(i+ind2)*4*ncp+(j+ind)*4+3];
                    }
                }
                ep[jj*3]=ep[jj*3]/wgh;
                ep[jj*3+1]=ep[jj*3+1]/wgh;
                ep[jj*3+2]=ep[jj*3+2]/wgh;
            }
        }
        
    }
    
}
