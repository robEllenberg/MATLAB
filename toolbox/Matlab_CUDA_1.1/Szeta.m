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
  del2max = norm(del2(:),inf);
  diff4 = real(ifft2(del2.^2.*zetahat));
  S = -(-dpsidy.*dzetadx + dpsidx.*dzetady) - nu4*diff4; 
  



