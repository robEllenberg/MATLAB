/*=================================================================
*
* MATLAB mex-file.
* Evaluation of univariate B-Spline.
*
* Usage:
*
*        ep = bspeval(deg,cp,knot,us)
*
* INPUT:
*
*   deg - degree of the B-Spline
*   cp - control points          
*   knot - knot sequence          
*   us - parametric points      
*
* OUTPUT:
*
*   ep - evaluated points
*
*
*
* To compile bspeval.c in MATLAB. Type 
* 
* mex bspeval.c
*
* in the Command Window.
*
*=================================================================*/


#include <math.h>
#include "mex.h"

/* Input Arguments */

#define	degree_of_the_B_spline	prhs[0]
#define control_points	prhs[1]
#define	knot_sequence	prhs[2]
#define	parametric_points	prhs[3]

/* Output Arguments */

#define	evaluated_points	plhs[0]

#if !defined(MAX)
#define	MAX(A, B)	((A) > (B) ? (A) : (B))
#endif

unsigned int findspan(int n, int p, double u, double *U)
{
    unsigned int low, high, mid;

    if (u >= U[n]){
        return(n);
    }

    low = p;  high = n+1;
    mid =(low+high)/2;
    while (u < U[mid] || u >= U[mid+1])
    {
        if (u < U[mid]){
            high = mid;
        }
        else{
            low = mid;
        }
        mid =(low+high)/2;
    }
    
    return(mid);
}

void basisfun(int i, double u, int p, double *U, double *N, double *left, double *right)
{
    int j;
    double saved, temp;
    int r;
  
    N[0] = 1.0;
    
    for (j = 1; j <= p; j++)
    {
        left[j]  = u - U[i+1-j];
        right[j] = U[i+j] - u;
        saved = 0.0;
        
        for (r = 0; r < j; r++)
        {
            temp = N[r] / (right[r+1] + left[j-r]);
            N[r] = saved + right[r+1] * temp;
            saved = left[j-r] * temp;
        }
        N[j] = saved;
    }
}

static void bspeval(int deg, double *cp, int mcp, int ncp, double *knot, double *us,int nus, double *ep){
    
    int i, ii, jj, span, temp1;
    double temp2;
    
    double *left  = (double*) malloc((deg+1)*sizeof(double));
    double *right = (double*) malloc((deg+1)*sizeof(double));    
    double *N = (double*) malloc((deg+1)*sizeof(double));   
    
    for (jj = 0; jj < nus; jj++){
        
        if(us[jj]<=knot[deg]){
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii] = cp[ii];
            }
        }
        else if(us[jj]>=knot[ncp]){
            for (ii = 0; ii < mcp; ii++){
                ep[jj*mcp+ii] = cp[mcp*(ncp-1)+ii];
            }
        }        
        else{
            span = findspan(ncp-1, deg, us[jj], knot);
            basisfun(span, us[jj], deg, knot, N,left,right);
            
            temp1 = span - deg;
            
            for (ii = 0; ii < mcp; ii++){
                temp2 = 0.0;
                for (i = 0; i <= deg; i++){
                    temp2 += N[i] * cp[(temp1+i)*mcp+ii];
                }
                ep[jj*mcp+ii] = temp2;
            }
        }
    }

    free(left);
    free(right);    
    free(N);    
    
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int deg;
    int mcp, ncp;
    int nus;

    double *cp, *ep, *knot, *us;

    deg = (int) mxGetScalar(degree_of_the_B_spline);

    cp = mxGetPr(control_points);
    mcp = mxGetM(control_points);
    ncp = mxGetN(control_points);

    knot = mxGetPr(knot_sequence);

    us = mxGetPr(parametric_points);
    nus = MAX(mxGetN(parametric_points),mxGetM(parametric_points));

    evaluated_points = mxCreateDoubleMatrix(mcp, nus, mxREAL);
    ep = mxGetPr(evaluated_points);
    
    bspeval(deg, cp, mcp, ncp, knot, us, nus, ep);
}
