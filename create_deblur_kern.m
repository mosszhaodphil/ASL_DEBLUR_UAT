function kern = create_deblur_kern(thespecd,method,kernlen,sig)

% ASL_DEBLUR: Create the deblurring kernel
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

if nargin < 3
    kernlen = length(series);
end
if nargin < 4
    sig=[];
end

switch method
    case 'direct'
        thefft = thespecd';
        slope = thefft(2)-thefft(3);
        thefft(1) = thefft(2)+slope; %put the mean in for tapering of the AC
        thefft = thefft/(thefft(2)+slope); %normalise, we want DC=1, but we will have to extrapolate as we dont ahve DC
        if isempty(sig)
            sig=1;
        end
        % multiply AC by tukey window
        thefft = sqrt(abs(fft(real(ifft(thefft.^2)).*(1-tukeywin(length(thefft),sig)))));
        thefft(1)=0; %back to zero mean
    case 'lorentz'
        thefft = thespecd;
        ac = real(ifft(thefft.^2)); % autocorrelation
        ac = ac/max(ac);
        params = nlinfit(length(ac),ac,@lorentzian_autocorr,2);
        gamma = params(1);
        disp(gamma)
        lozac = lorentzian_autocorr(gamma,kernlen);
        lozac = lozac/max(lozac);
        thefft = abs(fft(lorentzian_kern(gamma,kernlen,1)))'; %when getting final spec. den. include mean
    case 'lorwien'
        thefft = thespecd;
        ac = real(ifft(thefft.^2)); % autocorrelation
        ac = ac/max(ac);
        params = nlinfit(length(ac),ac,@lorentzian_wiener,[2 0.01]);
        gamma = params(1);
        tunef = params(2);
        disp(gamma)
        lozac = lorentzian_wiener(params,kernlen);
        thefft = abs(fft(lorentzian_kern(gamma,kernlen,1)))'; %when getting final spec. den. include mean
        thepsd = thefft.^2;
        tune = params(2)*mean(thepsd);
        wien = thepsd./(thepsd+tune);
        wien(1)=1;
        thefft = thefft./wien;
    case 'gauss'
        thefft = thespecd;
        sigfit = fit_gaussian_autocorr(thefft');
            disp(sigfit);
        thefft = gaussian_fft(sigfit,kernlen,1); %when getting final spec. den. include mean
    case 'manual'
        thefft = gaussian_fft(sig,kernlen,1);
end

% note that currently all the ffts have zero DC term!
invkern = 1./max(thefft(2:end),1e-50);
kern = real(ifft([0; invkern]));

% Weiner filter
% thepsd = thefft.^2;
% tune = 0.01*mean(thepsd);
% invkern = 1./thefft.*(thepsd./(thepsd+tune));

% The ffts should be already correctly normalized (unity DC)

% normalise
%if sum(kern)>0.01
%   kern = kern/(sum(kern));
%else
%    warning('normalization of kernel skipped');
%end

if length(kern)<kernlen
   % if the kernel is shorter than required pad in the middle by zeros
   kern = [kern(1:floor(length(kern)/2)); zeros(1,kernlen-length(kern))'; kern(floor(length(kern)/2)+1:end)];
end
   