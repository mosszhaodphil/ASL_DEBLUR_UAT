function flatmask = flattenmask(mask,thr)

% ASL_DEBLUR: Flatten mask
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014


if thr>size(mask,3)
    error('Cannot flatten mask with a threshold larger than the z dimension');
end

binmask = mask; binmask(mask>0)=1;
flatmask = thresh(sum(binmask,3),thr);
flatmask(flatmask>0)=1;