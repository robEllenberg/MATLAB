% Pseudospectral Fourier code for inviscid incompressible 2D vorticity eqn
% in a doubly periodic domain 0 < x,y < 1, starting at t = 0 with an 
% elliptical vortex. RK4 time-differencing is used. An option to use 4th order
% hyperviscosity is included.
%  http://www.amath.washington.edu/courses/571-winter-2006/matlab.html
%--------------------------------------------------------------------------
  % User-specified parameters
  N = 256;  % Number of Fourier modes in each direction
  dtoverdx = 0.25;  % Timestep specifier. For stability, maintain spectral CFL:
                    % Umax*dt/dx < 0.63 where Umax = max flow velocity.
  tp = 1/2; % Time between contour plots of zeta and psi
  tf = 1/2; % Final integration time
  L = 1; % Domain width in each direction
  damp4 = 2; % Damping coefficient for 4th order hyperviscosity
             %  nu4*del^4*zeta, where nu4 = damp4*dt/kmax^4
	     %  kmax^2 = (pi/dx)^2 + (pi/dy)^2 = max(kx^2+ky^2)
	     %  over wavenumbers resolvable on grid. Keep damp <
             %  2.82 to keep RK4 timestepping stable.
	     

  % Define grid and wavenumbers
  dx = L/N;
  dy = L/N;
  x = (0:(N-1))*dx;
  y = (0:(N-1))*dy;
  [X Y] = meshgrid(x,y);
  k = (2*pi/L)*[0:(N/2-1) (-N/2):-1]; % Wavenumber vector in either x or y
  [KX KY]  = meshgrid(k,k); % Matrix of (x,y) wavenumbers corresponding
                            % to Fourier modes

  dt = dtoverdx*dx;
  kmax4 = ((pi/dx)^2+(pi/dy)^2)^2;
  nu4 = damp4/(kmax4*dt);
			    
  % Specify IC for psi, and calculate corresponding vorticity zeta

  sigma = 0.15;
  psi = -0.25*exp(-(4*(X-0.5).^2 + (Y-0.5).^2)/(2*sigma^2));
  psihat = fft2(psi);
  zeta = real(ifft2(-(KX.^2 + KY.^2).*psihat));

  % Plot IC

  figure(1)

  subplot(2,2,1)
  contour(x,y,psi,-0.26:0.04:-0.02,'--')
  hold on
  contour(x,y,psi, 0.02:0.04:0.26)
  hold off
  xlabel('x')
  ylabel('y')
  axis square

  subplot(2,2,2)
  contour(x,y,zeta, 5:10:95)
  hold on
  contour(x,y,zeta,-95:10:-5,'--')
  hold off
  xlabel('x')
  ylabel('y')
  axis square
  
  % Time march

  np = round(tf/tp); % Number of times to plot
  nt = round(tp/dt); % Number of timesteps between plots

  np*nt

  for ip = 1:np
    for it = 1:nt

      % March forward dzeta/dt = Szeta using RK4
      % Szeta(zeta) = -psi_y*zeta_x + psi_x*zeta_y - nu4*del^4 psi
      %  is found pseudospectrally in a separate Matlab function.

      d1 = dt*Szeta(zeta,k,nu4); 
      d2 = dt*Szeta(zeta + 0.5*d1,k,nu4);
      d3 = dt*Szeta(zeta + 0.5*d2,k,nu4);
      d4 = dt*Szeta(zeta + d3,k,nu4);
      zeta = zeta + (d1 + 2*d2 + 2*d3 + d4)/6; % zeta marched forward dt
    end
    figure(ip+1)
    subplot(2,2,1)

    % Back out and plot psi

    zetahat = fft2(zeta);
    del2 = -(KX.^2 + KY.^2);
    del2(1,1) = 1;  % Set to nonzero to avoid division by zero when inverting
                  % Laplacian to get psi
    psihat = zetahat./del2;
    psi = real(ifft2(psihat));
    contour(x,y,psi,-0.26:0.04:-0.02,'--')
    hold on
    contour(x,y,psi, 0.02:0.04:0.26)
    hold off
    xlabel('x')
    ylabel('y')
    axis square

    % Plot zeta

    subplot(2,2,2)
    contour(x,y,zeta, 5:10:95)
    hold on
    contour(x,y,zeta, -95:10:-5,'--')
    hold off
    xlabel('x')
    ylabel('y')
    axis square
  end
