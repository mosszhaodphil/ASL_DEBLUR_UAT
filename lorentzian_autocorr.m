function out = lorentzian_autocorr(gamma,len)

% ASL_DEBLUR: lorentzian_autocorr
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

out = real(ifft(abs(fft(lorentzian_kern(gamma,len,1))).^2));
%out = out/max(out);