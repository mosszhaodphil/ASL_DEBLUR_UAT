function asl_deblur_core(data_name,residual_name,mask_name,out_name,method,sig,deblur_method)

% ASL DEBLUR: asl_deblur(dir,data_name,residual_name,mask_name,output_name,method,sigma)
% Perform z-deblurring of ASL data
%
% method options are:
%   direct - estimate kernel directly from data
%   gauss  - use gauss kernel, but estimate size from data
%   manual - gauss kernel with size given by sigma
%   lorentz - lorentzain kernel, estimate size from data
%   lorwein - lorentzian kernel with weiner type filter
%
% deblur methods are:
%   fft - do division in FFT domain
%   lucy - Lucy-Richardson (ML solution) for Gaussian noise
%
% (c) Michael A. Chappell, University of Oxford, 2009-2014

% MAC 27-2-2009

disp('asl_deblur_core');

if nargin < 5
    method='direct';
    sig=[];
end
if nargin < 6
    sig=[];
    if strcmp(method,'manual');
        sigma=0.8;
        disp(['Using manual gauss kernel with sigma=' num2str(sig)]);
    end
end

if nargin < 7
     deblur_method='fft';
end

disp(['Deblurring kernel:' method]);


%load the data
disp(['Input data is: ' data_name]);
[dataorig,dim,scales] = read_avw(data_name);
resids = read_avw(residual_name);
mask = read_avw(mask_name);

%pad the data - 2 slices top and bottom
 padl = repmat(dataorig(:,:,1,:),[1 1 2 1]);
 padu = repmat(dataorig(:,:,end,:),[1 1 2 1]);
 data = cat(3,padl,dataorig,padu);
%data = dataorig; %use this to turn padding off

%nslices = size(mask,3);
maskser = sum(sum(mask,1),2);
nslices = sum(maskser>0); % number of slices that are non zero in mask
flatmask = flattenmask(mask,nslices-2);
%residser = zdeblur_make_series(resids,flatmask);
thespecd = zdeblur_make_spec(resids,flatmask);
kern = create_deblur_kern(thespecd,method,size(data,3),sig); %NB data has more slices than residuals

%figure(101); plot(kern); hold all;

%deblur
dataout = zdeblur_with_kern(data,kern,deblur_method);

%dataout = zdeblur_with_kern(data,kern,deblur_method);

%discard padding
dataout(:,:,1:2,:) = [];
dataout(:,:,end-1:end,:) = [];

%save
save_avw(dataout,out_name,'f',scales);

disp('asl_deblur_core complete');
