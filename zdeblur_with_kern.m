function volout = zdeblur_with_kern(volume,kern,deblur_method)


% ASL_DEBLUR: zdeblur_with_kern
% deblur volume in the z-direction using the supplied kernel
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

% MAC 31-10-2008

% Based on Mark's myfftconv.m

if nargin < 3
    delbur_method='fft';
end

if strcmp(deblur_method,'fft')
    
    fftkern=fft(kern);
    if size(fftkern,2)==1
        fftkern = fftkern';
    end

    % demean volume (in z) - 'cos kern is zero mean
    zmean = repmat(mean(volume,3),[1 1 size(volume,3) 1]);
    volume = volume  - zmean;


    fftkern = shiftdim(fftkern,-1);
    fftkern = repmat(fftkern,[size(volume,1),size(volume,2),1,size(volume,4)]);
    fftvol = fft(volume,[],3);
    volout = ifft(fftkern.*fftvol,[],3);

    volout = volout+zmean;
    
elseif strcmp(deblur_method,'lucy')
    
    volout = Filter_matrix(volume,kern);
end