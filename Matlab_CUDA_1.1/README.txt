These files demonstrate using the CUDA accelerated FFT libraries and compiling and
accessing user CUDA code from Matlab.

This has been tested using MATLAB 7.3.0 (R2006b) 
using the Microsoft Visual Studio 2005 C/C++ compiler (Microsoft Visual Studio 8)

---- Setup ----

Install Matlab and CUDA.

Copy the contents of the bin directory (nvmex.pl) to the bin directory of your
existing Matlab installation, e.g. C:\Program Files\MATLAB\R2006b\bin



---- Compile and test the CUFFT interface ----

>> dir

.                  FS_vortex.m        bin                nvmex.m            
..                 README.txt         fft2_cuda.c        nvmex_helper.m     
FS_2Dflow.pdf      Szeta.cu           fft2_cuda_sp_dp.c  nvmexopts.bat      
FS_2Dturb.m        Szeta.m            ifft2_cuda.c       speed_fft.m        

>> mex fft2_cuda.c -IC:\CUDA\include -LC:\CUDA\lib -lcudart -lcufft
>> mex fft2_cuda_sp_dp.c -IC:\CUDA\include -LC:\CUDA\lib -lcudart -lcufft
>> mex ifft2_cuda.c -IC:\CUDA\include -LC:\CUDA\lib -lcudart -lcufft
>> dir

.                       README.txt              fft2_cuda.mexw32        nvmex.m                 
..                      Szeta.cu                fft2_cuda_sp_dp.c       nvmex_helper.m          
FS_2Dflow.pdf           Szeta.m                 fft2_cuda_sp_dp.mexw32  nvmexopts.bat           
FS_2Dturb.m             bin                     ifft2_cuda.c            speed_fft.m             
FS_vortex.m             fft2_cuda.c             ifft2_cuda.mexw32       

>> speed_fft



---- Run native Matlab simulations ----

>> which Szeta
C:\Documents and Settings\CUDA\Desktop\CUDA\Szeta.m
>> tic; FS_2Dturb(128,1,1,1); toc;

CFL =

    0.1017


Gsqav =

    1.1995

Elapsed time is 8.506012 seconds.
>> tic; FS_vortex; toc;

ans =

   512

Elapsed time is 216.061310 seconds.



---- Compile the CUDA source and rerun the simulations with acceleration ----

>> nvmex -f nvmexopts.bat Szeta.cu -IC:\cuda\include -LC:\cuda\lib -lcufft -lcudart
>> dir

.                       Szeta.cu                fft2_cuda_sp_dp.c       nvmexopts.bat           
..                      Szeta.m                 fft2_cuda_sp_dp.mexw32  speed_fft.m             
FS_2Dflow.pdf           Szeta.mexw32            ifft2_cuda.c            
FS_2Dturb.m             bin                     ifft2_cuda.mexw32       
FS_vortex.m             fft2_cuda.c             nvmex.m                 
README.txt              fft2_cuda.mexw32        nvmex_helper.m          

>> which Szeta
C:\Documents and Settings\CUDA\Desktop\CUDA\Szeta.mexw32
>> tic; FS_2Dturb(128,1,1,1); toc;

CFL =

    0.1017


Gsqav =

    1.1995

Elapsed time is 2.228646 seconds.
>> tic; FS_vortex; toc;

ans =

   512

Elapsed time is 15.164892 seconds.




Matlab scripts available for download from :
  http://www.amath.washington.edu/courses/571-winter-2006/matlab.html
  Professor Chris Bretherton, Atmospheric Science Department, University of Washington

Last modified: 6/22/2007