%check speed

%warm up the card (load library)
 fft2_cuda_sp_dp(rand(4));
 
%Compare native FFT2 with cuda implementation
 index=0;
 for N=256:256:2048
     index=index+1;
     size(index)=N;
     a=rand(N)+i*rand(N);
     as= single(a);
     
%      tic;b=fft2(a);
%      time_fft2_dp(index)=toc;
     
     tic;b=fft2(as);
     time_fft2_sp(index)=toc;
     
%      tic;b=fft2_cuda_sp_dp(a);
%      time_fft2_cuda_dp(index)=toc;
     
     tic;b=fft2_cuda_sp_dp(as);
     time_fft2_cuda_sp(index)=toc;
     
     disp(N)
 end

 figure(1)
 
%  fig = semilogy(size,time_fft2_dp,size,time_fft2_sp,....
%      size,time_fft2_cuda_dp,size,time_fft2_cuda_sp);
%  fig = plot(size,time_fft2_dp,size,time_fft2_sp,....
%      size,time_fft2_cuda_dp,size,time_fft2_cuda_sp); 
   subplot(2,1,1),  plot(size,time_fft2_sp,....
              size,time_fft2_cuda_sp);
 
 

 title('2D FFT on complex data')
 xlabel('Size N')
 ylabel('Time (sec.)')
 legend('Native MATLAB SP',...
            'CUDA with SP source')
 set(legend,'Position',[0.1906 0.8119 0.2503 0.05638]);
        
        
        
%Relative performance
  subplot(2,1,2)

  speed_up=time_fft2_sp./time_fft2_cuda_sp;
  bar(size,speed_up);
  title('2D FFT on complex data')
 xlabel('Size N')
 ylabel('Speed-up')
  

 