function [dat4] = Zmatrix2vols(dat2,mask)

% ASL_DEBLUR: Zmatrix2vols
% deblur volume in the z-direction using the supplied kernel
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

%mask is 2D need to rep by number of t points
if size(mask,3)==1
    mask = repmat(mask,[1 1 size(dat2,1)/(sum(sum((mask>0))))]);
end

% do matrix2vols as normal
dat4 = matrix2vols(dat2,mask);

% need to swap t and z dimensions to get it back in right form
dat4 = permute(dat4,[1 2 4 3]);

