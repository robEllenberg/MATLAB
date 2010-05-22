/* 

 Mex file for the following MATLAB function 

  function S = Szeta(zeta,k,nu4)

% Pseudospectral calculation of vorticity source term
%  S = -(- psi_y*zeta_x + psi_x*zeta_y) + nu4*del^4 zeta
% on a square periodic domain, where zeta = psi_xx + psi_yy is an NxN matrix
% of vorticity and k is vector of Fourier wavenumbers in each direction.
% Output is an NxN matrix of S at all pseudospectral gridpoints

  zetahat = fft2(zeta);
  [KX KY]  = meshgrid(k,k); % Matrix of (x,y) wavenumbers corresponding
                            % to Fourier mode (m,n)
  del2 = -(KX.^2 + KY.^2);
  del2(1,1) = 1;  % Set to nonzero to avoid division by zero when inverting
                  % Laplacian to get psi
  psihat = zetahat./del2;
  dpsidx = real(ifft2(1i*KX.*psihat));
  dpsidy = real(ifft2(1i*KY.*psihat));
  dzetadx = real(ifft2(1i*KX.*zetahat));
  dzetady = real(ifft2(1i*KY.*zetahat));
  diff4 = real(ifft2(del2.^2.*zetahat));
  S = -(-dpsidy.*dzetadx + dpsidx.*dzetady) - nu4*diff4;

  Original MATLAB code from  University of Washington
  http://www.amath.washington.edu/courses/571-winter-2006/matlab/Szeta.m

 This CUDA implementation is designed to reduce memory usage. 
 It performs the following steps:
	1) From zeta, it computes zetahat (in place)
	2) From zetahat, it computes dpsidx and dzetady (two extra arrays)
	3) It accumulates dpsidx*dzetady in S (extra array)
	4) From zetahat, it computes dpsidy and dzetadz (reuse arrays from 2)
	5) From zetahat, it computes hperviscosity (in place)
	6) It accumulates dpsidy*dzetadz and hyperviscosity in S
 

*/

#include <stdlib.h>

#include "mex.h"

#include "cuda.h"
#include "cuda_runtime.h"
#include "cufft.h"
#include "driver_types.h"


/* Pack real array in interleaved format  */
static __global__ void  real2complex(float *a, cufftComplex *c, int N)
{
  unsigned int idx   = __umul24(blockIdx.x,blockDim.x)+threadIdx.x;
  unsigned int idy   = __umul24(blockIdx.y,blockDim.y)+threadIdx.y;
  if( idx<N && idy <N )
  {
  unsigned int index = idx +__umul24(idy ,N);
  c[index].x = a[index];
  c[index].y = 0.f;
  }
}


/* Compute dpsix and dzetay */
static __global__ void  der_psi_x_omega_y(cufftComplex *c_in, 
                                          cufftComplex *psi_x,
                                          cufftComplex *omega_y,
                                          float *k, 
                                          int N)
{
  int idx   = __mul24(blockIdx.x,blockDim.x)+threadIdx.x;
  int idy   = __mul24(blockIdx.y,blockDim.y)+threadIdx.y;
  float scale,scale_fft;
  float2 term;
  __shared__ float kx_s[16],ky_s[16];
  if (threadIdx.y <1) kx_s[threadIdx.x] =k[idx];
  if (threadIdx.x <1) ky_s[threadIdx.y] =k[idy];
  __syncthreads();

  if( idx<N && idy <N )
  {

  int index = idx +idy *N;
  scale_fft=1.f/(N*N);
  float lkx=kx_s[threadIdx.x];
  float lky=ky_s[threadIdx.y];
  //scale=-(k[idx]*k[idx]+k[idy]*k[idy]);
  scale=-(lkx*lkx+lky*lky);
  if (idx == 0 && idy == 0) scale=1.f;

  scale =lkx/scale*scale_fft;
  term.x = c_in[index].x;
  term.y = c_in[index].y;
  psi_x[index].x =  scale*term.y;
  psi_x[index].y = -scale*term.x;
  omega_y[index].x = -lky*scale_fft*term.y;
  omega_y[index].y =  lky*scale_fft*term.x;

  }
}

/* Compute dpsiy and dzetax */
static __global__ void  der_psi_y_omega_x(cufftComplex *c_in,
                                          cufftComplex *psi_y,
                                          cufftComplex *omega_x,
                                          float *k,
                                          int N)
{
  int idx   = __mul24(blockIdx.x,blockDim.x)+threadIdx.x;
  int idy   = __mul24(blockIdx.y,blockDim.y)+threadIdx.y;
  float scale, scale_fft;
  float2 term;

  __shared__ float kx_s[16],ky_s[16];
  if (threadIdx.y <1) kx_s[threadIdx.x] =k[idx];
  if (threadIdx.x <1) ky_s[threadIdx.y] =k[idy];
  __syncthreads();

  if( idx<N && idy <N )
  {
  int index = idx +idy *N;
  scale_fft=1.f/(N*N);
  float lkx=kx_s[threadIdx.x];
  float lky=ky_s[threadIdx.y];
  //scale=-(k[idx]*k[idx]+k[idy]*k[idy]);
  scale=-(lkx*lkx+lky*lky);
  if (idx == 0 && idy == 0) scale=1.f;

  //psi_y[index][0] =  scale*c_in[index][1];
  //psi_y[index][1] = -scale*c_in[index][0];
  scale =lky/scale*scale_fft;
  term.x = c_in[index].x;
  term.y = c_in[index].y;
  psi_y[index].x =  scale*term.y;
  psi_y[index].y = -scale*term.x;
  omega_x[index].x= -lkx*scale_fft*term.y;
  omega_x[index].y = lkx*scale_fft*term.x;

  }
}

/* Compute hyperviscosity term */
static __global__ void  hyperviscosity(cufftComplex *c_in,
                                       cufftComplex *c_out,
                                       float *k,
                                       int N)
{
  int idx   = __mul24(blockIdx.x,blockDim.x)+threadIdx.x;
  int idy   = __mul24(blockIdx.y,blockDim.y)+threadIdx.y;
  float scale,scale_fft;

  __shared__ float kx_s[16],ky_s[16];
  if (threadIdx.y <1) kx_s[threadIdx.x] =k[idx];
  if (threadIdx.x <1) ky_s[threadIdx.y] =k[idy];
  __syncthreads();

  if( idx<N && idy <N )
  {

  int index = idx +idy *N;
  scale_fft=1.f/(N*N);
  float lkx=kx_s[threadIdx.x];
  float lky=ky_s[threadIdx.y];
  scale=-(lkx*lkx+lky*lky);
  if (idx == 0 && idy == 0) scale=1.f;

  scale =scale*scale*scale_fft;
  c_out[index].x = scale *c_in[index].x;
  c_out[index].y = scale *c_in[index].y;


  }
}

/* Compute -dpsix*dzetay */
static __global__ void  non_linear_1(float *nl,
                                     cufftComplex *a,
                                     cufftComplex *b,
                                     int N)
{
  int idx   = __mul24(blockIdx.x,blockDim.x)+threadIdx.x;
  int idy   = __mul24(blockIdx.y,blockDim.y)+threadIdx.y;
  volatile float2 av, bv;
  if( idx<N && idy <N )
  {
  int index = idx +idy *N;
  av.x=a[index].x;
  av.y=a[index].y;
  bv.x=b[index].x;
  bv.y=b[index].y;
  nl[index] =  -av.x*bv.x;
  }
}


/* Add +dpsiy*dzetax minus hyperviscosity */
static __global__ void  non_linear_2(float *nl,
                                     cufftComplex *a,
                                     cufftComplex *b,
                                     cufftComplex *c,
                                     float nu,
                                     int N)
{
  int idx   = __mul24(blockIdx.x,blockDim.x)+threadIdx.x;
  int idy   = __mul24(blockIdx.y,blockDim.y)+threadIdx.y;
  volatile float2 av, bv,cv;
  if( idx<N && idy <N )
  {
  int index = idx +idy *N;
  av.x=a[index].x;
  av.y=a[index].y;
  bv.x=b[index].x;
  bv.y=b[index].y;
  cv.x=c[index].x;
  cv.y=c[index].y;
  nl[index] +=  av.x*bv.x-nu*cv.x;
  }
}



/**************************************************************************/

/* MATLAB stores complex numbers in separate arrays for the real and
   imaginary parts.  The following functions take the data in
   this format and pack it into a complex work array, or
   unpack it, respectively.  */

void pack_r2c(cufftComplex *input_float, 
              double *input_re, 
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++) 
    {
               input_float[i].x = (float) input_re[i];
               input_float[i].y = 0.0f;
    }
}

void pack_c2c(cufftComplex *input_float, 
              double *input_re, 
              double *input_im, 
              int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++) 
    {
               input_float[i].x = (float) input_re[i];
               input_float[i].y = (float) input_im[i];
    }
}


void unpack_c2c(cufftComplex *input_float, 
                double *output_re, 
                double *output_im,  
                int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++) 
    {
               output_re[i] = (double) input_float[i].x;
               output_im[i] = (double) input_float[i].y;
    }

}

void convert_double2float( double *input_double, float *output_float,int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
    {
                output_float[i] = (float) input_double[i];
    }
}

void convert_float2double( float *input_float, double *output_double,int Ntot)
{
    int i;
    for (i = 0; i < Ntot; i++)
    {
                output_double[i] = (double) input_float[i];
    }
}

/**************************************************************************/

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  int M, N;
  double *ar, *k;
  float        *input_single ;
  float        *output_single ;
  cufftHandle    plan;
  float  *ks, *k_d;
  double nu4;
  float nu4s;

  /* 
     Find out the  dimension of the array we want to transform:

     prhs(M,N) 
     M= Number of rows    in the mxArray prhs 
     N= Number of columns in the mxArray prhs 

  */

    if (nrhs != 3) mexPrintf ("Szeta is expecting 3 arguments\n"); 

    M = mxGetM(prhs[0]);
    N = mxGetN(prhs[0]);

    nu4 = mxGetScalar(prhs[2]);
    nu4s = (float) nu4;


  /* Allocate complex array on the device (needs to be filled 
    in interleaved format )*/
  cufftComplex *rhs_complex_d;
  cudaMalloc( (void **) &rhs_complex_d,sizeof(cufftComplex)*N*M);

  /* Pointer for the real part of the input */
  ar =  (double *) mxGetData(prhs[0]);

 /* Compute the execution configuration */
   int block_size=16;
   dim3 dimBlock(block_size,block_size);
  
   dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1) ,
                  (N/dimBlock.y) + (!(N%dimBlock.y)?0:1) );
 

  /* Allocating working array on host */
   input_single  = (float*) mxMalloc(sizeof(float)*N*M);

    convert_double2float(ar,input_single,  N*M); 
   /* Copy real input array to the device */
 
   float *rhs_real_d;
  cudaMalloc( (void **) &rhs_real_d,sizeof(float)*N*M);

  cudaMemcpy( rhs_real_d, input_single, sizeof(float)*N*M, cudaMemcpyHostToDevice);

  real2complex<<<dimGrid,dimBlock>>>(rhs_real_d,rhs_complex_d,N); 

 
  /* Allocating working array on host */
    output_single  = (float *) mxMalloc(sizeof(float )*N*M);

  /* process the wave number array */
   k  = (double *) mxGetData(prhs[1]);
   ks = (float  *) mxMalloc(sizeof(float)*N);

   convert_double2float(k,ks,N);
   cudaMalloc( (void **) &k_d,sizeof(float)*N);
   cudaMemcpy( k_d, ks, sizeof(float)*N, cudaMemcpyHostToDevice);

 


  /* Create plan for CUDA FFT 
     The current implementation is expecting a square matrix.
     In general, MATLAB is using a column-major order, CUDA a row-major order,
     so we will need to  flip the dimensions.
   */
  cufftPlan2d(&plan, N, M, CUFFT_C2C) ;

  /* Execute FFT on device */
  cufftExecC2C(plan, rhs_complex_d, rhs_complex_d, CUFFT_FORWARD) ;

  cufftComplex *psi_d,*omega_d;
  cudaMalloc( (void **) &psi_d   ,sizeof(cufftComplex)*N*M);
  cudaMalloc( (void **) &omega_d ,sizeof(cufftComplex)*N*M);

  float *nl_d;
  cudaMalloc( (void **) &nl_d   ,sizeof(float)*N*M);
 
  der_psi_x_omega_y<<<dimGrid,dimBlock>>>(rhs_complex_d,psi_d,omega_d,k_d,N);

  cufftExecC2C(plan, psi_d, psi_d, CUFFT_INVERSE) ;
  cufftExecC2C(plan, omega_d, omega_d, CUFFT_INVERSE) ;
  non_linear_1<<<dimGrid,dimBlock>>>(nl_d,psi_d,omega_d,N);

  der_psi_y_omega_x<<<dimGrid,dimBlock>>>(rhs_complex_d,psi_d,omega_d,k_d,N);

  cufftExecC2C(plan, psi_d, psi_d, CUFFT_INVERSE) ;
  cufftExecC2C(plan, omega_d, omega_d, CUFFT_INVERSE) ;

  hyperviscosity<<<dimGrid,dimBlock>>>(rhs_complex_d,rhs_complex_d,k_d,N);
  cufftExecC2C(plan, rhs_complex_d, rhs_complex_d, CUFFT_INVERSE) ;
 
  non_linear_2<<<dimGrid,dimBlock>>>(nl_d,psi_d,omega_d,rhs_complex_d,nu4s,N);

  /* Destroy plan */
  cufftDestroy(plan);

  /* Copy result back to host */
  cudaMemcpy( output_single, nl_d, sizeof(float)*N*M, cudaMemcpyDeviceToHost);
 
  plhs[0]=mxCreateDoubleMatrix(M,N,mxREAL);

  ar = mxGetPr(plhs[0]); 
  convert_float2double(output_single, ar, N*M); 

  /* Free the memory allocated on host and GPU */

  mxFree(input_single); mxFree(output_single); mxFree(ks);

  cudaFree(k_d); cudaFree(rhs_real_d); cudaFree(rhs_complex_d); 
  cudaFree(psi_d); cudaFree(omega_d); cudaFree(nl_d);

  return;
}

