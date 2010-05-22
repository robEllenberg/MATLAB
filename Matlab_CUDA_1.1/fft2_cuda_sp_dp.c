/* 
        This is a mex file to offload  the FFT2 function in Matlab to CUDA:

	Y = fft2(X)
	or 
        Y = fft2(X,M,N)

	Y = fft2(X) returns the two-dimensional FFT of X. The result Y is the same size as X.

	Y = fft2(X,M,N) truncates X, or pads X with zeros to create an M-by-N array before doing the transform. 
		The result is M-by-N.

        On Windows:

	Setup the mex build from a Matlab shell:
	mex -setup

        Compile the mex file:
	mex -IC:\CUDA\include fft2_cuda.c -LC:\cuda\lib -lcufft -lcudart

        On Linux:
        Use the makefile
 */




#include "cuda_runtime.h"

#include "cufft.h"

#include "mex.h"
#include "matrix.h"
/**************************************************************************/

/* MATLAB stores complex numbers in separate arrays for the real and
   imaginary parts.  The following functions take the data in
   this format and pack it into a complex work array, or
   unpack it, respectively.  
   We are using cufftComplex defined in cufft.h to  handle complex on Windows and Linux

*/

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

void pack_r2c_sp(cufftComplex  *output_float,
              float *input_re,
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
              {
               output_float[i].x = input_re[i];
               output_float[i].y = 0.0f;
              }
}

void pack_c2c(cufftComplex  *output_float, 
              double *input_re, 
              double *input_im, 
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++) 
	     {
               output_float[i].x= input_re[i];
               output_float[i].y = input_im[i];
	     }
}

void pack_c2c_sp(cufftComplex  *output_float,
              float *input_re,
              float *input_im,
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
             {
               output_float[i].x = input_re[i];
               output_float[i].y = input_im[i];
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

void pack_r2c_expand_sp(cufftComplex  *output_float,
                     float *input_re,
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

void pack_c2c_expand_sp(cufftComplex  *output_float,
                     float *input_re,
                     float *input_im,
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

void unpack_c2c(cufftComplex  *input_float, 
                double *output_re, 
                double *output_im,  
                int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++) 
    {
               output_re[i] = input_float[i].x;
               output_im[i] = input_float[i].y;
    }

}

void unpack_c2c_sp(cufftComplex  *input_float,
                float *output_re,
                float *output_im,
                int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
    {
               output_re[i] = input_float[i].x;
               output_im[i] = input_float[i].y;
    }

}


/**************************************************************************/

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  int originalM, originalN, M, N;
  cufftComplex *input_single ;
  cufftHandle            plan;
  cufftComplex *rhs_complex_d;

  mxClassID category;
  int single;

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
    Find out if the input array was real or complex.
    Matlab is passing two separate pointers for the real and imaginary part.
    The current version of  CUDAFFT is expecting interleaved data.
    We will need to pack and unpack the data.

    The current version of CUDA supports only single precision, 
    so the original double precision data need to be converted.
  */

   /* Find out if the input is single or double precision */
   category = mxGetClassID(prhs[0]);
   
  //if( category == mxSINGLE_CLASS)  mexPrintf("float\n");
  //if( category == mxDOUBLE_CLASS)  mexPrintf("double\n");


  /* Allocating working array on host */
    if(nrhs == 1) input_single  = (cufftComplex*) mxMalloc(sizeof(cufftComplex)*N*M);
    if(nrhs == 3) input_single  = (cufftComplex*) mxCalloc(N*M,sizeof(cufftComplex));


/* Input was double precision */
  if( category == mxDOUBLE_CLASS)  
  {
  /* Pointer for the real part of the input */
    double *ar,*ai;
    ar =  (double *) mxGetData(prhs[0]);

  if(mxIsComplex(prhs[0])) 
  {
   /* The input array is complex */
   ai =  (double *) mxGetImagData(prhs[0]); 
   
   /* Input and output have same dimensions */
   if(nrhs ==1) pack_c2c(input_single, ar, ai, N*M); 

   /* Input and output have different dimensions */
   if(nrhs ==3) pack_c2c_expand(input_single, ar, ai, originalM, originalN, M, N); 

  }
  else
  {
   /* The input array is real */

   /* Input and output have same dimensions */
   if(nrhs ==1) pack_r2c(input_single, ar, N*M); 

   /* Input and output have different dimensions */
   if(nrhs ==3) pack_r2c_expand(input_single, ar, originalM, originalN, M, N); 
  }
 
  }
 
/* Input was single precision */
if( category == mxSINGLE_CLASS)  
  {
    float *ar,*ai;
  /* Pointer for the real part of the input */
    ar =  (float *) mxGetData(prhs[0]);

  if(mxIsComplex(prhs[0]))
  {
   /* The input array is complex */
   ai =  (float *) mxGetImagData(prhs[0]);

   /* Input and output have same dimensions */
   if(nrhs ==1) pack_c2c_sp(input_single, ar, ai, N*M);

   /* Input and output have different dimensions */
   if(nrhs ==3) pack_c2c_expand_sp(input_single, ar, ai, originalM, originalN, M, N);

  }
  else
  {
   /* The input array is real */

   /* Input and output have same dimensions */
   if(nrhs ==1) pack_r2c_sp(input_single, ar, N*M);

   /* Input and output have different dimensions */
   if(nrhs ==3) pack_r2c_expand_sp(input_single, ar, originalM, originalN, M, N);
  }

  }

  /* Allocate array on device */
  cudaMalloc( (void **) &rhs_complex_d,sizeof(cufftComplex)*N*M);

  /* Copy input array in interleaved format to the device */
  cudaMemcpy( rhs_complex_d, input_single, sizeof(cufftComplex)*N*M, cudaMemcpyHostToDevice);


  /* Create plan for CUDA FFT */
  cufftPlan2d(&plan, N, M, CUFFT_C2C) ;

  /* Execute FFT on device */
    cufftExecC2C(plan, rhs_complex_d, rhs_complex_d, CUFFT_FORWARD) ;

  /* Destroy plan */
    cufftDestroy(plan);

  /* Copy result back to host */
  cudaMemcpy( input_single, rhs_complex_d, sizeof(cufftComplex)*N*M, cudaMemcpyDeviceToHost);



  if( category == mxDOUBLE_CLASS)  
  {
      double *ar,*ai;
  plhs[0]=mxCreateNumericMatrix(M,N,category,mxCOMPLEX);

  
  ar = mxGetPr(plhs[0]); 
  ai = mxGetPi(plhs[0]);
  unpack_c2c(input_single, ar, ai, N*M); 
  }

if( category == mxSINGLE_CLASS)  
  {
    float *ar,*ai;
  plhs[0]=mxCreateNumericMatrix(M,N,category,mxCOMPLEX);
  
  ar = (float *) mxGetPr(plhs[0]); 
  ai = (float *) mxGetPi(plhs[0]);
  unpack_c2c_sp(input_single, ar, ai, N*M); 
  }
  mxFree(input_single);
  cudaFree(rhs_complex_d);

  return;
}

