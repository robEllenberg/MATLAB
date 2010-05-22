/* 
        This is a mex file to offload  the IFFT2 function in Matlab to CUDA:

	Y = ifft2(X)
	or Y = ifft2(X,M,N)

	Y = ifft2(X) returns the two-dimensional IFFT of X. The result Y is the same size as X.

	Y = ifft2(X,M,N) truncates X, or pads X with zeros to create an M-by-N array before doing the transform. 
		The result is M-by-N.
 
        mex -IC:\CUDA\include ifft2_cuda_win.c -LC:\CUDA\lib -lcufft -lcudart
 */


#include <stdlib.h>

#include "mex.h"

#include "cuda.h"
#include "cuda_runtime_api.h"
#include "cufft.h"
#include "driver_types.h"


/**************************************************************************/


/* MATLAB stores complex numbers in separate arrays for the real and
   imaginary parts.  The following functions take the data in
   this format and pack it into a complex work array, or
   unpack it, respectively.  */


void pack_c2c(cufftComplex  *output_float,
              double *input_re, 
              double *input_im,
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
             {
               output_float[i].x = input_re[i];
               output_float[i].y = input_im[i];
             }
}


void pack_c2c_expand(cufftComplex  *output_float,
                     double *input_re,
                     double *input_im,
                     int originalM,
                     int originalN,
                     int M,
                     int N)
{
     int i, j;

    for (i = 0; i < originalM; i++)
     for (j = 0; j < originalN; j++)
     {
               output_float[i+M*j].x = input_re[i+originalM*j];
               output_float[i+M*j].y = input_im[i+originalM*j];
     }
}


void unpack_c2c_scale(cufftComplex *input_float, 
                double *output_re, 
                double *output_im,  
                int Ntot)
{
    int i;
    double scale=1./(Ntot);
    for (i = 0; i < Ntot; i++) 
    {
               output_re[i] = scale*input_float[i].x;
               output_im[i] = scale*input_float[i].y;
    }

}

void pack_r2c(cufftComplex  *output_float,
              double *input_re, 
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
              { 
               output_float[i].x = input_re[i];
               output_float[i].y = 0.0f;
              }
}

void pack_r2c_expand(cufftComplex  *output_float,
                     double *input_re,
                     int originalM,
                     int originalN,
                     int M,
                     int N)
{
     int i, j;
    for (i = 0; i < originalM; i++)
     for (j = 0; j < originalN; j++)
     {
               output_float[i+M*j].x = input_re[i+originalM*j];
               output_float[i+M*j].y = 0.0f;
     }
}


/**************************************************************************/

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  int originalM, originalN, M, N;
  int i;
  double *ar,*ai;
  cufftComplex *input_single, *output_single ;
  cufftComplex *rhs_complex_d;
  cufftHandle    plan;

  /* 
     Find out the  dimension of the array we want to transform:

     prhs(originalM,originalN) 
     originalM = Number of rows    in the mxArray prhs 
     originalN = Number of columns in the mxArray prhs 

  */

    originalM = mxGetM(prhs[0]);
    originalN = mxGetN(prhs[0]);

    M = originalM;
    N = originalN;


  /*
    Find out if the result is of the same size of the input.

    plhs(M,N)
    M = The number of rows in the mxArray plhs
    N = The number of columns in the mxArray plhs

  */
   if (nrhs == 3) 
   {
    M = mxGetScalar(prhs[1]);
    N = mxGetScalar(prhs[2]);
   }


  /* 
    Matlab is passing two separate pointers for the real and imaginary part.
    The current version of  CUDAFFT is expecting interleaved data.
    We will need to pack and unpack the data.
    The current version of CUDA supports only single precision, 
    so the original double precision data need to be converted.
    Matlab is expecting a  complex array.
  */

  /* Allocating working array on host */
    input_single  = (cufftComplex*) mxMalloc(sizeof(cufftComplex)*N*M);


  /* Pointer for the real part of the input */
  ar =  (double *) mxGetData(prhs[0]);

  if(mxIsComplex(prhs[0])) 
  {
   /* The input array was complex */
   ai =  (double *) mxGetImagData(prhs[0]); 
   
   /* Inpute and output have same dimensions */
   if(nrhs ==1) pack_c2c(input_single, ar, ai, N*M); 

   /* Inpute and output have different dimensions */
   if(nrhs ==3) pack_c2c_expand(input_single, ar, ai, originalM, originalN, M, N); 

  }
  else
  {

   /* Input and output have same dimensions */
   if(nrhs ==1) pack_r2c(input_single, ar, N*M); 

   /* Input and output have different dimensions */
   if(nrhs ==3) pack_r2c_expand(input_single, ar, originalM, originalN, M, N); 
    
  }
 
  /* Allocate array on device */
  cudaMalloc( (void **) &rhs_complex_d,sizeof(cufftComplex)*N*M);

  /* Copy input array in interleaved format to the device */
  cudaMemcpy( rhs_complex_d, input_single, sizeof(cufftComplex)*N*M, cudaMemcpyHostToDevice);


  /* 
     Create plan for CUDA FFT
     The dimensions are flipped, MATLAB is column-major, CUDA is row-major.
  */
  cufftPlan2d(&plan, N, M, CUFFT_C2C) ;

  /* Execute inverse FFT on device */
  cufftExecC2C(plan, rhs_complex_d, rhs_complex_d, CUFFT_INVERSE) ;


  /* Destroy plan */
  cufftDestroy(plan);

  /* Copy result back to host */
  cudaMemcpy( input_single, rhs_complex_d, sizeof(cufftComplex)*N*M, cudaMemcpyDeviceToHost);


  plhs[0]=mxCreateDoubleMatrix(M,N,mxCOMPLEX);

  ar = mxGetPr(plhs[0]); 
  ai = mxGetPi(plhs[0]);
  /* Scale back the result (by N*M) */
  unpack_c2c_scale(input_single, ar, ai, N*M); 

  mxFree(input_single);
  cudaFree(rhs_complex_d);

  return;
}

