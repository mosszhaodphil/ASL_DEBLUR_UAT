function sigfit=fit_gaussian_autocorr(thefft)

% ASL_DEBLUR
% fit a Gaussian autocorrelation model to the data and return the
% std dev sigma
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

% (autocorr is ifft of the power spectral density)
data_raw_autocorr=real(ifft(abs(thefft).^2));
data_raw_autocorr=data_raw_autocorr/max(data_raw_autocorr);

[sigfit]=nlinfit(length(data_raw_autocorr),data_raw_autocorr,@gaussian_autocorr,1);