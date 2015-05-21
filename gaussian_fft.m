function x=gaussian_fft(sig,len,demean)

% ASL_DEBLUR: gaussian_fft
% returns the fourier transform function for Gaussian smoothed white
% noise with len data points, where the Gaussian std dev is sigma 
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

if nargin<3
    demean=1;
end

tres=1;
fres=1/(tres*len);
maxk=1/tres;
k=fres:fres:maxk;
%sqrt(2*pi)*
x=sig.*exp(-(0.5*sig^2*(2*pi*k).^2))+sqrt(2*pi)*sig.*exp(-(0.5*sig^2*(2*pi*((maxk+fres)-k)).^2));
if demean, x(1)=0; end
x=x';