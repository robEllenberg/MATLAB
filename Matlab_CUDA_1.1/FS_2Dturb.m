function [K,zetahatsq,KEav,zetasqav]= FS_2Dturb(N,tp,tf,makeplot)
  
% Pseudospectral Fourier code for inviscid incompressible 2D vorticity eqn
% in a doubly periodic domain 0 < x,y < 1, starting at t = 0 at
% rest, RK4 time-differencing and 4th-order hyperviscosity,
% implemented using function Szeta.m, are used.
%
% A noise forcing is used to create 2D turbulence. The
% forcing is concentrated in a
% narrow wavenumber band Knoise +/- dKnoise and has a finite
% autocorrelation timescale T and amplitude T^-2.
% The noise forcing is treated using Godunov splitting.
%
% Plots include:
% 1. time evolution of domain-averaged energy and enstrophy,
% 2. snapshots of streamfunction and vorticity at the final time
% 3. 2D and 1D power spectra at the final time
%
% Inputs
%  N = 32;  % Number of Fourier modes in each direction
%  tp = 1;   % Time between contour plots of zeta and psi
%  tf = 40;  % Final integration time
%  makeplot = 1;  % Logical flag for making pcolor plots of zeta and
%              psi and |zetahat|^2/N^2  
% Outputs  
%--------------------------------------------------------------------------
% Internal user-specified parameters
  
  L = 2*pi; % Domain width in each direction
  damp4 = 0.5; % Damping coefficient for 4th order hyperviscosity
             %  nu4*del^4*zeta, where nu4 = damp4*dt/kmax^4
	     %  kmax^2 = (pi/dx)^2 + (pi/dy)^2 = max(kx^2+ky^2)
	     %  over wavenumbers resolvable on grid. Keep damp <
             %  2.82 to keep RK4 timestepping stable.
  Knoise = 4*(2*pi/L); % Central wavenumber of band-limited noise
  dKnoise = 1*(2*pi/L); % Half-width in |k| of noise.
  Tnoise = 1; % Forcing amplitude and decorrelation timescale
  CFLtarget = 0.5; % Timestep adaptively chosen to keep CFL near 0.5
  dt = 0.01*(128/N);

  % Define grid and wavenumbers
  dx = L/N;
  dy = L/N;
  x = (0:(N-1))*dx;
  y = (0:(N-1))*dy;
  [X Y] = meshgrid(x,y);
  k = (2*pi/L)*[0:(N/2-1) (-N/2):-1]; % Wavenumber vector in either x or y
  [KX KY]  = meshgrid(k,k); % Matrix of (x,y) Fourier wavenumbers
  ksq = (KX.^2 + KY.^2);
  K = sqrt(ksq); % Matrix of total wavenumbers
  ksq(1,1) = 1;  % Set to nonzero to avoid division by zero when inverting
                  % Laplacian to get psi
  del2 = -ksq;

  kmax4 = ((pi/dx)^2+(pi/dy)^2)^2;
  nu4 = damp4/(kmax4*dt);

  % Specify zero IC for zeta and psi
  randn('state', 100);

  zeta = zeros(N,N);
  psi = zeros(N,N);

  % Initialize spectral noise weights and noise forcing 
  
  w = exp(-((K-Knoise).^2/(2*(dKnoise)^2)));
  w = w/norm(w(:),2);

  c = 1/Tnoise^2;
  F = c*N^2*real(ifft2(w.*(randn(N,N)+1i*randn(N,N))));
    
  % Time march

  t = 0;

  np = round(tf/tp); % Number of times to plot
  nt = round(tp/dt); % Number of timesteps between plots
  tav = zeros(1,np+1);
  KEav = zeros(1,np+1);
  zetasqav =  zeros(1,np+1);

  for ip = 1:np
    for it = 1:nt
      
      % March forward dzeta/dt = Szeta using RK4
      % Szeta(zeta) = -psi_y*zeta_x + psi_x*zeta_y - nu4*del^4 zeta
      % is found pseudospectrally in a separate Matlab function.

      d1 = dt*Szeta(zeta,k,nu4); 
      d2 = dt*Szeta(zeta + 0.5*d1,k,nu4);
      d3 = dt*Szeta(zeta + 0.5*d2,k,nu4);
      d4 = dt*Szeta(zeta + d3,k,nu4);
      zeta = zeta + (d1 + 2*d2 + 2*d3 + d4)/6; % zeta marched forward dt
    
      % Add in noise forcing (using Godunov splitting for simplicity)
    
      zeta = zeta + dt*F;
      t = t + dt;
      
      % Update noise to new time
      
      a = exp( - dt/Tnoise);    
      b = c*sqrt(1-a^2);
      G = N^2*real(ifft2(w.*(randn(N,N)+1i*randn(N,N))));
      F = a*F + b*G;
    end
    tav(ip+1) = t;
    zetahat = fft2(zeta);
    psihat = zetahat./del2;
    dpsidx = real(ifft2(1i*KX.*psihat));
    dpsidy = real(ifft2(1i*KY.*psihat));
    Umax = sqrt(max(dpsidx(:).^2 + dpsidy(:).^2));
    CFL = Umax*dt/dx % Print out CFL for manually tweaking dt
    KEav(ip+1) = sum(abs(zetahat(:)./ksq(:)).^2)/N^4;
    zetasqav(ip+1) = sum(abs(zetahat(:)).^2)/N^4;
    zetahatsq = abs(zetahat).^2/N^4;

    if(makeplot & (ip==np))

    figure(3)
    clf
    subplot(2,2,1)

    % Back out and plot psi

    psi = real(ifft2(psihat));
%    contour(x/L,y/L,psi)
    pcolor(x/L,y/L,psi)
    shading interp
    xlabel('x/L')
    ylabel('y/L')
    axis square
    colorbar
    title(['\psi(x,y,' num2str(tf) ')'])

    % Plot zeta

    subplot(2,2,2)
%    contour(x/L,y/L,zeta)
    pcolor(x/L,y/L,zeta)
    shading interp
    xlabel('x/L')
    ylabel('y/L')
    title(['\zeta(x,y,' num2str(tf) ')'])
    colorbar
    axis square
    
    figure(2)
    clf
    
    % 2D power spectrum of zeta

    subplot(2,2,1)
    [ksort,msort] = sort(k);
    pcolor(ksort,ksort,log10(zetahatsq(msort,msort)))
    xlabel('k_x')
    ylabel('k_y')
    shading interp
    colorbar
    title(['log_{10}(Z_{np}), N=' num2str(N)])
    
    figure(1)
    
    % Plot a realization of the noise

    clf
    subplot(2,2,1)
%    contour(x/L,y/L,G);
    pcolor(x/L,y/L,G)
    shading interp
    colorbar
    Gsqav = mean(G(:).^2)
    xlabel('x/L')
    ylabel('y/L')
    title('Realization of band-limited noise G(x,y,t)')
    end    
  end

  
