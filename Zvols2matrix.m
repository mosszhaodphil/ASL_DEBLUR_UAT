function [dat2]=Zvols2matrix(dat4,mask)

% ASL_DEBLUR: Zvols2matrix
% deblur volume in the z-direction using the supplied kernel
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

% [dat2]=Zvols2matrix(dat4,mask)
% takes 4D volume and 2D (xy) or 3D (xyt) mask and return 2D matrix
% (space-time x z-dimension)
% 
% Just vols2matrix but choosing the Z-dimension
%
% MAC 29-07-2009

%mask is 2D need to rep by number of t points
if size(mask,3)==1
    mask = repmat(mask,[1 1 size(dat4,4)]);
end
mask=reshape(mask,numel(mask),1)'>0;

% need to swap t and z dimensions
dat4 = permute(dat4,[1 2 4 3]);
% proceed as normal
dat2=reshape(dat4,numel(mask),size(dat4,4))';
dat2=dat2(:,mask)';