function thespec = zdeblur_make_spec(resids,flatmask)

% ASL_DEBLUR: zdeblur_make_spec
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

zdata = Zvols2matrix(resids,flatmask); 
for i = 1:length(zdata)
    ztemp(i,:) = zdata(i,:)-mean(zdata(i,:));
end
%ztemp = demean(zdata,2); does the same as above but using command in FMT

thepsd = (abs(fft(ztemp,[],2)));
thespec = mean(thepsd,1);