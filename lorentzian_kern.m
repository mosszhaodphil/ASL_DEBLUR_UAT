function out = lorentzian_kern(gamma,len,demean)

% ASL_DEBLUR: lorentzian_kern
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014


if nargin < 3
    demean=1;
end
 
x = [0, 1:ceil((len-1)/2), floor((len-1)/2):-1:1];
%out = real(ifft(exp(-x/gamma)));
out = lorentzian(x,gamma);
if demean, out = out - mean(out); end %zero mean/DC
%out=out/max(out);
