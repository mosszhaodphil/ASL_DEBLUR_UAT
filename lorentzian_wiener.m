function out = lorentzian_wiener(params,len)

% ASL_DEBLUR: lorentzian_wiener
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014


thefft = abs(fft(lorentzian_kern(params(1),len,1)));
thepsd = thefft.^2;
tune = params(2)*mean(thepsd);
wien = thepsd./(thepsd+tune);
wien(1)=1; % we are about to dealing with a demeaned kernel
out = real(ifft(thepsd./wien.^2));
out = out/max(out);