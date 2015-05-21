function x=gaussian_autocorr(sig,len)

% ASL_DEBLUR: Gaussian Autocorrelation
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

% returns the autocorrelation function for Gaussian smoothed white
% noise with len data points, where the Gaussian std dev is sigma 

% for now we go via the gaussian fourier transform
% (autocorr is ifft of the power spectral density)
% ideally , we should just analytically calc the autocorr
gfft=gaussian_fft(sig,len);

%figure;plot(gfft);ho;plot(resfft);

x=real(ifft(gfft.^2)); 

if max(x)>0
x=x/max(x);
end