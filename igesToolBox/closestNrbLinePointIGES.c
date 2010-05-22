/**************************************************************************
 *
 * function [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0,v)
 *
 * Closest points of NURBS patch and line/point using Newton's Method.
 *
 * Line (3D):  r=r0+t*v
 * Point (3D): r0
 *
 * Usage in Matlab:
 *
 * § Closest NURBS-point to line
 * [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0,v)
 *
 * § Closest NURBS-point to point
 * [P,UV]=closestNrbLinePointIGES(nurbs,dnurbs,d2nurbs,UV0,r0)
 *
 * Input:
 * nurbs - NURBS structure
 * dnurbs,d2nurbs - NURBS derivatives (output from nrbDerivativesIGES).
 * UV0 - Initial start Parameter values
 * r0,(v) - See Line/Point (3D) above. r0 (and v) must have the dimension (3x{1 or N})
 *          If size (3x1) - same point/line is used, if size (3xN) - different point/lines are used.
 *
 * Curve
 * UV0 - 1xN matrix, N number of u-parameters
 *
 * Surface
 * UV0 - 2xN matrix, N number of (u,v)-parameters
 *
 * Output:
 * P - Closest points on NURBS patch.
 * UV - NURBS Parameter values at closest point. (same dimension as UV0)
 *
 * c-file can be downloaded for free at
 *
 * http://www.mathworks.com/matlabcentral/fileexchange/13253-iges-toolbox
 *
 * compile in Matlab by using the command  "mex closestNrbLinePointIGES.c"
 *
 * See "help mex" for more information
 *
 * written by Per Bergström 2009-12-04
 * per.bergstrom at ltu.se
 *
 **************************************************************************/

#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	nurbsstructure	prhs[0]
#define	dnrbsstructure	prhs[1]
#define d2nrbsstructure	prhs[2]
#define initparamvalues	prhs[3]
#define point0	prhs[4]
#define linedirection	prhs[5]

/* Output Arguments */

#define	evaluated_points	plhs[0]
#define	parametervalues	plhs[1]

/* Misc */

#define MAXITER 50

/* Sub functions (in folder "mexSourceFiles") */

#include "mexSourceFiles/FindSpan.c"
#include "mexSourceFiles/BasisFuns.c"
#include "mexSourceFiles/BspEval.c"
#include "mexSourceFiles/BspEval2.c"
#include "mexSourceFiles/nrbD1D2eval.c"
#include "mexSourceFiles/nrbD1D2eval2.c"

/* Main function */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    int i, j;
    double t, detH, H11, H12, H13, H22, H23, H33, neggrad1, neggrad2, neggrad3, s1, s2, s3, res[3];
    char TrueFalse=0;
    double paramtmp[2], umin, umax, vmin, vmax, bspPnts[4], pnttmp[3], pderu[3], pderv[3], pderuu[3], pderuv[3], pdervv[3];
    
    if(nlhs!=2){
        mexErrMsgTxt("Number of outputs must be 2.");
    }
    if(nrhs>6 || nrhs<5){
        mexErrMsgTxt("Number of inputs must be 5 or 6.");
    }
    if (mxGetM(mxGetField(nurbsstructure, 0, "coefs"))!=4){
        mexPrintf("Number of rows in nurbs.coefs is %d,\n", mxGetM(mxGetField(nurbsstructure, 0, "coefs")));
        mexErrMsgTxt("nurbs.coefs must have 4 rows.");
    }
    if(mxGetM(point0)!=3){
        mexErrMsgTxt("r0 must have 3 rows.");
    }    
    if(mxGetM(initparamvalues)>2 || mxGetM(initparamvalues)==0){
        mexErrMsgTxt("UV0 must be of dim 1xN or 2xN.");
    }
    if(nrhs==6){
        if(mxGetM(linedirection)!=3){
            mexErrMsgTxt("v must have 3 rows.");
        }
        if(mxGetN(linedirection)!=mxGetN(point0)){
            mexErrMsgTxt("r0 and v must be of same size.");
        }
        else if(mxGetN(linedirection)==mxGetN(initparamvalues)){
            if(mxGetN(point0)>1){
                TrueFalse=1;
            }
        }
    }
    else if(nrhs==5){
        if(mxGetN(point0)==mxGetN(initparamvalues)){
            if(mxGetN(point0)>1){
                TrueFalse=1;
            }
        }
    }

    evaluated_points = mxCreateDoubleMatrix(3, mxGetN(initparamvalues), mxREAL);
    parametervalues = mxCreateDoubleMatrix(mxGetM(initparamvalues), mxGetN(initparamvalues), mxREAL);
    
    if (mxGetM(initparamvalues)==2){

        int orderU = (int)mxGetPr(mxGetField(nurbsstructure, 0, "order"))[0];
        int orderV = (int)mxGetPr(mxGetField(nurbsstructure, 0, "order"))[1];
        
        double *leftU  = (double*) malloc(orderU*sizeof(double)+1);
        double *rightU = (double*) malloc(orderU*sizeof(double)+1);
        double *NU = (double*) malloc(orderU*sizeof(double)+1);
        double *leftV  = (double*) malloc(orderV*sizeof(double)+1);
        double *rightV = (double*) malloc(orderV*sizeof(double)+1);
        double *NV = (double*) malloc(orderV*sizeof(double)+1);
        
        umin = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0))[orderU-1];
        umax = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0))[((int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[1])];
        vmin = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 1))[orderV-1];
        vmax = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 1))[((int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[2])];
        
        if(nrhs==6){
            
            for (i = 0; i < mxGetN(initparamvalues); i++){
                
                paramtmp[0] = (double)mxGetPr(initparamvalues)[2*i];
                paramtmp[1] = (double)mxGetPr(initparamvalues)[2*i+1];
                
                t=0.0;
                for (j = 0; j < MAXITER; j++){
                    
                    if(paramtmp[0] <= umin){
                        paramtmp[0] = umin;
                    }
                    else if(paramtmp[0] >= umax){
                        paramtmp[0] = umax;
                    }
                    if(paramtmp[1] <= vmin){
                        paramtmp[1] = vmin;
                    }
                    else if(paramtmp[1] >= vmax){
                        paramtmp[1] = vmax;
                    }
                    
                    nrbD1D2eval2(nurbsstructure, dnrbsstructure, d2nrbsstructure, &paramtmp[0], &pnttmp[0], &pderu[0], &pderv[0], &pderuu[0], &pderuv[0], &pdervv[0], &bspPnts[0], leftU, rightU, NU, leftV, rightV, NV);
                    
                    if(TrueFalse){
                        res[0]=mxGetPr(point0)[3*i]+t*mxGetPr(linedirection)[3*i]-pnttmp[0];
                        res[1]=mxGetPr(point0)[3*i+1]+t*mxGetPr(linedirection)[3*i+1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[3*i+2]+t*mxGetPr(linedirection)[3*i+2]-pnttmp[2];
                        
                        H13=-(pderu[0]*mxGetPr(linedirection)[3*i]+pderu[1]*mxGetPr(linedirection)[3*i+1]+pderu[2]*mxGetPr(linedirection)[3*i+2]);
                        H23=-(pderv[0]*mxGetPr(linedirection)[3*i]+pderv[1]*mxGetPr(linedirection)[3*i+1]+pderv[2]*mxGetPr(linedirection)[3*i+2]);
                        H33=  mxGetPr(linedirection)[3*i]*mxGetPr(linedirection)[3*i]+mxGetPr(linedirection)[3*i+1]*mxGetPr(linedirection)[3*i+1]+mxGetPr(linedirection)[3*i+2]*mxGetPr(linedirection)[3*i+2];
                        
                        neggrad3=res[0]*mxGetPr(linedirection)[3*i]+res[1]*mxGetPr(linedirection)[3*i+1]+res[2]*mxGetPr(linedirection)[3*i+2];
                    }
                    else{
                        res[0]=mxGetPr(point0)[0]+t*mxGetPr(linedirection)[0]-pnttmp[0];
                        res[1]=mxGetPr(point0)[1]+t*mxGetPr(linedirection)[1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[2]+t*mxGetPr(linedirection)[2]-pnttmp[2];
                        
                        H13=-(pderu[0]*mxGetPr(linedirection)[0]+pderu[1]*mxGetPr(linedirection)[1]+pderu[2]*mxGetPr(linedirection)[2]);
                        H23=-(pderv[0]*mxGetPr(linedirection)[0]+pderv[1]*mxGetPr(linedirection)[1]+pderv[2]*mxGetPr(linedirection)[2]);
                        H33=  mxGetPr(linedirection)[0]*mxGetPr(linedirection)[0]+mxGetPr(linedirection)[1]*mxGetPr(linedirection)[1]+mxGetPr(linedirection)[2]*mxGetPr(linedirection)[2];
                        
                        neggrad3=res[0]*mxGetPr(linedirection)[0]+res[1]*mxGetPr(linedirection)[1]+res[2]*mxGetPr(linedirection)[2];
                    }
                    H11=pderu[0]*pderu[0]+pderu[1]*pderu[1]+pderu[2]*pderu[2]-(pderuu[0]*res[0]+pderuu[1]*res[1]+pderuu[2]*res[2]);
                    H12=pderu[0]*pderv[0]+pderu[1]*pderv[1]+pderu[2]*pderv[2]-(pderuv[0]*res[0]+pderuv[1]*res[1]+pderuv[2]*res[2]);
                    H22=pderv[0]*pderv[0]+pderv[1]*pderv[1]+pderv[2]*pderv[2]-(pdervv[0]*res[0]+pdervv[1]*res[1]+pdervv[2]*res[2]);
                    
                    neggrad1=pderu[0]*res[0]+pderu[1]*res[1]+pderu[2]*res[2];
                    neggrad2=pderv[0]*res[0]+pderv[1]*res[1]+pderv[2]*res[2];
                    
                    detH = 2*H13*H12*H23-H13*H13*H22-H12*H12*H33+H11*H22*H33-H11*H23*H23;
                    if(fabs(detH)<1e-10){
                        break;
                    }
                    s1 = ((H22*H33-H23*H23)*neggrad1+(H13*H23-H12*H33)*neggrad2-(H12*H23-H13*H22)*neggrad3)/detH;
                    s2 = ((H13*H23-H12*H33)*neggrad1+(H11*H33-H13*H13)*neggrad2-(H13*H12-H11*H23)*neggrad3)/detH;
                    s3 = ((H12*H23-H13*H22)*neggrad1+(H13*H12-H11*H23)*neggrad2-(H11*H22-H12*H12)*neggrad3)/detH;
                    
                    paramtmp[0] += 0.7*s1;
                    paramtmp[1] += 0.7*s2;
                    t+=0.7*s3;
                    
                    if((s1*s1+s2*s2+s3*s3)<1e-20){
                        break;
                    }
                }
                
                if(paramtmp[0] <= umin){
                    paramtmp[0] = umin;
                }
                else if(paramtmp[0] >= umax){
                    paramtmp[0] = umax;
                }
                if(paramtmp[1] <= vmin){
                    paramtmp[1] = vmin;
                }
                else if(paramtmp[1] >= vmax){
                    paramtmp[1] = vmax;
                }
                BspEval2(orderU-1, orderV-1, mxGetPr(mxGetField(nurbsstructure, 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 1)), &paramtmp[0], 1, &bspPnts[0], leftU, rightU, NU, leftV, rightV, NV);
                
                mxGetPr(evaluated_points)[3*i]=(bspPnts[0])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+1]=(bspPnts[1])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+2]=(bspPnts[2])/(bspPnts[3]);
                
                mxGetPr(parametervalues)[2*i]=paramtmp[0];
                mxGetPr(parametervalues)[2*i+1]=paramtmp[1];               
                
            }
            
        }
        else if(nrhs==5){
            
            for (i = 0; i < mxGetN(initparamvalues); i++){
                
                paramtmp[0] = (double)mxGetPr(initparamvalues)[2*i];
                paramtmp[1] = (double)mxGetPr(initparamvalues)[2*i+1];                
                
                for (j = 0; j < MAXITER; j++){
                    
                    if(paramtmp[0] <= umin){
                        paramtmp[0] = umin;
                    }
                    else if(paramtmp[0] >= umax){
                        paramtmp[0] = umax;
                    }
                    if(paramtmp[1] <= vmin){
                        paramtmp[1] = vmin;
                    }
                    else if(paramtmp[1] >= vmax){
                        paramtmp[1] = vmax;
                    }
                    
                    nrbD1D2eval2(nurbsstructure, dnrbsstructure, d2nrbsstructure, &paramtmp[0], &pnttmp[0], &pderu[0], &pderv[0], &pderuu[0], &pderuv[0], &pdervv[0], &bspPnts[0], leftU, rightU, NU, leftV, rightV, NV);
                    
                    if(TrueFalse){
                        res[0]=mxGetPr(point0)[3*i]-pnttmp[0];
                        res[1]=mxGetPr(point0)[3*i+1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[3*i+2]-pnttmp[2];
                    }
                    else{
                        res[0]=mxGetPr(point0)[0]-pnttmp[0];
                        res[1]=mxGetPr(point0)[1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[2]-pnttmp[2];
                    }
                    H11=pderu[0]*pderu[0]+pderu[1]*pderu[1]+pderu[2]*pderu[2]-(pderuu[0]*res[0]+pderuu[1]*res[1]+pderuu[2]*res[2]);
                    H12=pderu[0]*pderv[0]+pderu[1]*pderv[1]+pderu[2]*pderv[2]-(pderuv[0]*res[0]+pderuv[1]*res[1]+pderuv[2]*res[2]);
                    H22=pderv[0]*pderv[0]+pderv[1]*pderv[1]+pderv[2]*pderv[2]-(pdervv[0]*res[0]+pdervv[1]*res[1]+pdervv[2]*res[2]);
                    
                    neggrad1=pderu[0]*res[0]+pderu[1]*res[1]+pderu[2]*res[2];
                    neggrad2=pderv[0]*res[0]+pderv[1]*res[1]+pderv[2]*res[2];
                    
                    detH = H11*H22-H12*H12;
                    if(fabs(detH)<1e-10){
                        break;
                    }
                    s1 = (H22*neggrad1-H12*neggrad2)/detH;
                    s2 = (H11*neggrad2-H12*neggrad1)/detH;
                    
                    paramtmp[0] += 0.7*s1;
                    paramtmp[1] += 0.7*s2;
                    
                    if((s1*s1+s2*s2)<1e-20){
                        break;
                    }
                }
                
                if(paramtmp[0] <= umin){
                    paramtmp[0] = umin;
                }
                else if(paramtmp[0] >= umax){
                    paramtmp[0] = umax;
                }
                if(paramtmp[1] <= vmin){
                    paramtmp[1] = vmin;
                }
                else if(paramtmp[1] >= vmax){
                    paramtmp[1] = vmax;
                }
                BspEval2(orderU-1, orderV-1, mxGetPr(mxGetField(nurbsstructure, 0, "coefs")), 4, (int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[1], (int)mxGetDimensions(mxGetField(nurbsstructure, 0, "coefs"))[2], mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0)), mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 1)), &paramtmp[0], 1, &bspPnts[0], leftU, rightU, NU, leftV, rightV, NV);
                
                mxGetPr(evaluated_points)[3*i]=(bspPnts[0])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+1]=(bspPnts[1])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+2]=(bspPnts[2])/(bspPnts[3]);
                
                mxGetPr(parametervalues)[2*i]=paramtmp[0];
                mxGetPr(parametervalues)[2*i+1]=paramtmp[1];                 
                
            }
            
        }
        else{
            mexPrintf("Error! Illegeal number of inputs.\n");
        }
        
        free(leftU);
        free(rightU);
        free(NU);
        free(leftV);
        free(rightV);
        free(NV);
        
    }
    
    else if (mxGetM(initparamvalues)==1){
        
        int orderU = (int)mxGetScalar(mxGetField(nurbsstructure, 0, "order"));
        
        double *left  = (double*) malloc(orderU*sizeof(double)+1);
        double *right = (double*) malloc(orderU*sizeof(double)+1);
        double *N = (double*) malloc(orderU*sizeof(double)+1);
        
        umin = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0))[orderU-1];
        umax = (double)mxGetPr(mxGetCell(mxGetField(nurbsstructure, 0, "knots"), 0))[mxGetN(mxGetField(nurbsstructure, 0, "coefs"))];
        
        if(nrhs==6){
            
            for (i = 0; i < mxGetN(initparamvalues); i++){
                
                paramtmp[0] = (double)mxGetPr(initparamvalues)[i];
                
                t=0.0;
                for (j = 0; j < MAXITER; j++){
                    
                    if(paramtmp[0] <= umin){
                        paramtmp[0] = umin;
                    }
                    else if(paramtmp[0] >= umax){
                        paramtmp[0] = umax;
                    }
                    
                    nrbD1D2eval(nurbsstructure, dnrbsstructure, d2nrbsstructure, &paramtmp[0], &pnttmp[0], &pderu[0], &pderuu[0], &bspPnts[0], left, right, N);
                    
                    if(TrueFalse){
                        res[0]=mxGetPr(point0)[3*i]+t*mxGetPr(linedirection)[3*i]-pnttmp[0];
                        res[1]=mxGetPr(point0)[3*i+1]+t*mxGetPr(linedirection)[3*i+1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[3*i+2]+t*mxGetPr(linedirection)[3*i+2]-pnttmp[2];
                        
                        H12=-(pderu[0]*mxGetPr(linedirection)[3*i]+pderu[1]*mxGetPr(linedirection)[3*i+1]+pderu[2]*mxGetPr(linedirection)[3*i+2]);
                        H22=  mxGetPr(linedirection)[3*i]*mxGetPr(linedirection)[3*i]+mxGetPr(linedirection)[3*i+1]*mxGetPr(linedirection)[3*i+1]+mxGetPr(linedirection)[3*i+2]*mxGetPr(linedirection)[3*i+2];
                        
                        neggrad2=res[0]*mxGetPr(linedirection)[3*i]+res[1]*mxGetPr(linedirection)[3*i+1]+res[2]*mxGetPr(linedirection)[3*i+2];
                    }
                    else{
                        res[0]=mxGetPr(point0)[0]+t*mxGetPr(linedirection)[0]-pnttmp[0];
                        res[1]=mxGetPr(point0)[1]+t*mxGetPr(linedirection)[1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[2]+t*mxGetPr(linedirection)[2]-pnttmp[2];
                        
                        H12=-(pderu[0]*mxGetPr(linedirection)[0]+pderu[1]*mxGetPr(linedirection)[1]+pderu[2]*mxGetPr(linedirection)[2]);
                        H22=  mxGetPr(linedirection)[0]*mxGetPr(linedirection)[0]+mxGetPr(linedirection)[1]*mxGetPr(linedirection)[1]+mxGetPr(linedirection)[2]*mxGetPr(linedirection)[2];
                        
                        neggrad2=res[0]*mxGetPr(linedirection)[0]+res[1]*mxGetPr(linedirection)[1]+res[2]*mxGetPr(linedirection)[2];
                    }
                    H11=pderu[0]*pderu[0]+pderu[1]*pderu[1]+pderu[2]*pderu[2]-(pderuu[0]*res[0]+pderuu[1]*res[1]+pderuu[2]*res[2]);
                    
                    neggrad1=pderu[0]*res[0]+pderu[1]*res[1]+pderu[2]*res[2];
                    
                    detH = H11*H22-H12*H12;
                    if(fabs(detH)<1e-10){
                        break;
                    }
                    s1 = (H22*neggrad1+H12*neggrad2)/detH;
                    s2 = -(H11*neggrad2+H12*neggrad1)/detH;
                    
                    paramtmp[0] += 0.7*s1;
                    t+=0.7*s2;
                    
                    if((s1*s1+s2*s2)<1e-20){
                        break;
                    }
                }
                
                if(paramtmp[0] <= umin){
                    paramtmp[0] = umin;
                }
                else if(paramtmp[0] >= umax){
                    paramtmp[0] = umax;
                }
                BspEval(orderU-1, mxGetPr(mxGetField(nurbsstructure, 0, "coefs")), 4, (int)mxGetN(mxGetField(nurbsstructure, 0, "coefs")), mxGetPr(mxGetField(nurbsstructure, 0, "knots")), &paramtmp[0], 1, &bspPnts[0], left, right, N);
                
                mxGetPr(evaluated_points)[3*i]=(bspPnts[0])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+1]=(bspPnts[1])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+2]=(bspPnts[2])/(bspPnts[3]);
                
                mxGetPr(parametervalues)[i]=paramtmp[0];
                
            }
            
        }
        else if(nrhs==5){
            
            for (i = 0; i < mxGetN(initparamvalues); i++){
                
                paramtmp[0] = (double)mxGetPr(initparamvalues)[i];
                
                for (j = 0; j < MAXITER; j++){
                    
                    if(paramtmp[0] <= umin){
                        paramtmp[0] = umin;
                    }
                    else if(paramtmp[0] >= umax){
                        paramtmp[0] = umax;
                    }
                    
                    nrbD1D2eval(nurbsstructure, dnrbsstructure, d2nrbsstructure, &paramtmp[0], &pnttmp[0], &pderu[0], &pderuu[0], &bspPnts[0], left, right, N);
                    
                    if(TrueFalse){
                        res[0]=mxGetPr(point0)[3*i]-pnttmp[0];
                        res[1]=mxGetPr(point0)[3*i+1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[3*i+2]-pnttmp[2];
                    }
                    else{
                        res[0]=mxGetPr(point0)[0]-pnttmp[0];
                        res[1]=mxGetPr(point0)[1]-pnttmp[1];
                        res[2]=mxGetPr(point0)[2]-pnttmp[2];
                    }
                    H11=pderu[0]*pderu[0]+pderu[1]*pderu[1]+pderu[2]*pderu[2]-(pderuu[0]*res[0]+pderuu[1]*res[1]+pderuu[2]*res[2]);
                    
                    neggrad1=pderu[0]*res[0]+pderu[1]*res[1]+pderu[2]*res[2];
                    
                    if(fabs(H11)<1e-10){
                        break;
                    }
                    s1 = neggrad1/H11;
                    
                    paramtmp[0] += 0.7*s1;
                    
                    if((s1*s1)<1e-20){
                        break;
                    }
                }
                
                if(paramtmp[0] <= umin){
                    paramtmp[0] = umin;
                }
                else if(paramtmp[0] >= umax){
                    paramtmp[0] = umax;
                }
                BspEval(orderU-1, mxGetPr(mxGetField(nurbsstructure, 0, "coefs")), 4, (int)mxGetN(mxGetField(nurbsstructure, 0, "coefs")), mxGetPr(mxGetField(nurbsstructure, 0, "knots")), &paramtmp[0], 1, &bspPnts[0], left, right, N);
                
                mxGetPr(evaluated_points)[3*i]=(bspPnts[0])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+1]=(bspPnts[1])/(bspPnts[3]);
                mxGetPr(evaluated_points)[3*i+2]=(bspPnts[2])/(bspPnts[3]);
                
                mxGetPr(parametervalues)[i]=paramtmp[0];
                
            }
            
        }
        else{
            mexPrintf("Error! Illegeal number of inputs.\n");
        }
        
        free(left);
        free(right);
        free(N);
        
    }
    
    else{
        mexErrMsgTxt("Wrong dimension of UV");
    }
    
}
