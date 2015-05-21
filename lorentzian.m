function lorz = lorentzian(x,gamma)

% ASL_DEBLUR: lorentzian
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014


lorz = (1/pi * (0.5*gamma)./(x.^2+(0.5*gamma)^2) );