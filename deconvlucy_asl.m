function J = deconvlucy_asl(varargin)

% ASL_DEBLUR: deconv_lucy
%
%  deconvlucy_asl is partially based on the deconvlucy function in Matlab.
%  NOTE = the matlab function implements this type of deconvolution using
%  the specific formula for Poisson noise.
%  deconvlucy_asl implements the deconvolution with the modified equation
%  that considers Gaussian noise.
%
%  This function deconvolves image I using Lucy-Richardson algorithm, 
%  returning deblurred image J. The assumption is
%  that the image I was created by convolving a true image with a
%  point-spread function PSF and possibly by adding noise.
%   
%  Based on Matlab function deconvlucy.m
%  27-03-2013 IBG

% Parse inputs to verify valid function calling syntaxes and arguments
[J,PSF,NUMIT,DAMPAR,READOUT,WEIGHT,SUBSMPL,sizeI,classI,numNSdim]=...
  parse_inputs(varargin{:});
initial_estimate = DAMPAR;
DAMPAR = 0;

% 1. Prepare PSF --> Our estimated Kernel
sizeOTF = sizeI;
sizeOTF(numNSdim) = SUBSMPL*sizeI(numNSdim);
H = PSF;
ns = length(H);
H = H./sum(H);

% Matrix K
matrix_kernel(:,1) = H;
for i = 2:ns
    matrix_kernel(:,i) = [zeros(i-1,1);H(1:(ns-i+1))];
end
H = matrix_kernel;

% 2. Prepare parameters for iterations
%
% Create indexes for image according to the sampling rate
idx = repmat({':'},[1 length(sizeI)]);
for k = numNSdim,% index replicates for non-singleton PSF sizes only
  idx{k} = reshape(repmat(1:sizeI(k),[SUBSMPL 1]),[SUBSMPL*sizeI(k) 1]);
end

J{2} = (abs(sqrt(initial_estimate)));
wI = max(WEIGHT.*(READOUT + J{1}),0);% at this point  - positivity constraint
J{2} = J{2}(idx{:});
scale = 1;%;real(ifftn((conj(H).*(fftn(WEIGHT(idx{:})))))) + sqrt(eps);
clear WEIGHT;
DAMPAR22 = (DAMPAR.^2)/2;

if SUBSMPL~=1,% prepare vector of dimensions to facilitate the reshaping
  % when the matrix is binned within the iterations.
  vec(2:2:2*length(sizeI)) = sizeI;
  vec(2*numNSdim-1) = -1;
  vec(vec==0) = [];
  num = fliplr(find(vec==-1));
  vec(num) = SUBSMPL;
else
  vec = [];    
  num = [];
end

% 3. L_R Iterations
%
lambda = 2*any(J{4}(:)~=0);
for k = lambda + (1:NUMIT)
    
    % 3.a Make an image predictions for the next iteration
    if k > 2,
        lambda = (J{4}(:,1).'*J{4}(:,2))/(J{4}(:,2).'*J{4}(:,2) +eps);
        lambda = max(min(lambda,1),0);% stability enforcement
    end
    %         Y = max(J{2} + lambda*(J{2} - J{3}),0);% plus positivity constraint
    Y = max(J{2},0);
    % 3.b  Make core for the LR estimation
    
    CC = corelucy_asl(Y,H,DAMPAR22,wI,READOUT,SUBSMPL,idx,vec,num);
    
    % 3.c Determine next iteration image & apply positivity constraint
    J{3} = J{2};
    
    matrix_kernel_flip = (matrix_kernel(end:-1:1,end:-1:1));
    prodotto = matrix_kernel_flip*CC;
    J{2} = max(Y.*(prodotto)./1.2,0); %
    
    clear CC;
    J{4} = [J{2}(:)-Y(:) J{4}(:,1)];
    
end
clear wI H scale Y;

% 4. Convert the right array (for cell it is first array, for notcell it is
% second array) to the original image class & output whole thing
num = 1 + strcmp(classI{1},'notcell');
if ~strcmp(classI{2},'double'),
  J{num} = changeclass(classI{2},J{num});
end

if num==2,% the input & output is NOT a cell
  J = J{2};
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs 
function [J,PSF,NUMIT,DAMPAR,READOUT,WEIGHT,SUBSMPL,sizeI,classI,numNSdim] = ...
    parse_inputs(varargin)
%
% Outputs:
% I=J{1}   the input array (could be any numeric class, 2D, 3D)
% PSF      operator that distorts the ideal image
% numNSdim non-singleton dimensions of PSF
%
% Defaults:
%
NUMIT = [];NUMIT_d = 10;% Number of  iterations, usually produces good
                        % result by 10.
DAMPAR =[];DAMPAR_d = 0;% No damping is default
WEIGHT =[];             % All pixels are of equal quality, flat-field is one
READOUT=[];READOUT_d= 0;% Zero readout noise or any other
           % back/fore/ground noise associated with CCD camera.
           % Or the Image is corrected already for this noise by user.
SUBSMPL= [];SUBSMPL_d= 1;% Image and PSF are given at equal resolution,
           % no over/under sampling at all.

narginchk(2,7);

% First, assign the inputs starting with the image
%
if iscell(varargin{1}),% input cell is used to resume interrupted iterations
  classI{1} = 'cell';% or interrupt the iteration to resume it later
  J = varargin{1};
else % no-cell array is used to do a single set of iterations
  classI{1} = 'notcell';  
  J{1} = varargin{1};% create a cell array in order to do the iterations
end;

% check the Image, which is the first array of the cell
classI{2} = class(J{1});

validateattributes(J{1},{'uint8' 'uint16' 'double' 'int16','single'},...
              {'real' 'nonempty' 'finite'},mfilename,'I',1);

if length(J{1})<2,
    error(message('images:deconvlucy:inputImagesMustHaveAtLeast2Elements'))
elseif ~isa(J{1},'double'),
    J{1} = im2double(J{1});
end

% now since the image is OK&double, we assign the rest of the J cell
len = length(J);
if len == 1,% J = {I} will be reassigned to J = {I,I,0,0}
  J{2} = J{1};
  J{3} = 0;
elseif len ~= 4,% J = {I,J,Jm1,gk} has to have 4 or 1 arrays
    error(message('images:deconvlucy:inputCellMustHave1or4Elements'));
else % check if J,Jm1,gk are double in the input cell
  if ~all([isa(J{2},'double'),isa(J{3},'double'),isa(J{4},'double')]),
    error(message('images:deconvlucy:inputImageCellElementsMustBeDouble'))
  end
end;

% Second, Assign the rest of the inputs:
%
PSF = varargin{2};%      deconvlucy(I,PSF)
switch nargin
case 3,%                 deconvlucy(I,PSF,NUMIT)
  NUMIT = varargin{3};
case 4,%                 deconvlucy(I,PSF,NUMIT,DAMPAR)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
case 5,%                 deconvlucy(I,PSF,NUMIT,DAMPAR,WEIGHT)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
case 6,%                 deconvlucy(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
  READOUT = varargin{6};
case 7,%                 deconvlucy(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT,SUBSMPL)
  NUMIT = varargin{3};
  DAMPAR = varargin{4};
  WEIGHT = varargin{5};
  READOUT = varargin{6};
  SUBSMPL = varargin{7};
end

% Third, Check validity of the input parameters: 
%
% NUMIT check number of iterations
if isempty(NUMIT),
  NUMIT = NUMIT_d;
else  
  validateattributes(NUMIT,{'double'},{'scalar' 'positive' 'finite'},...
                mfilename,'NUMIT',3);
end

% SUBSMPL check sub-sampling rate
if isempty(SUBSMPL),
  SUBSMPL = SUBSMPL_d;
else
  validateattributes(SUBSMPL,{'double'},{'scalar' 'positive' 'finite'},...
                mfilename,'SUBSMPL',7);
end

% PSF array
[sizeI, sizePSF] = padlength(size(J{1}), size(PSF));
numNSdim = find(sizePSF~=1);
if prod(sizePSF)<2,
  error(message('images:deconvlucy:psfMustHaveAtLeast2Elements'))
elseif all(PSF(:)==0),
  error(message('images:deconvlucy:psfMustNotBeZeroEverywhere'))
elseif any(sizePSF(numNSdim)/SUBSMPL > sizeI(numNSdim)),
  error(message('images:deconvlucy:psfMustBeSmallerThanImage'))
end
if length(J)==3,% assign the 4-th element of input cell now
  J{4}(prod(sizeI)*SUBSMPL^length(numNSdim),2) = 0;
end;

% DAMPAR check damping parameter
if isempty(DAMPAR),
  DAMPAR = DAMPAR_d;
elseif (numel(DAMPAR)~=1) && ~isequal(size(DAMPAR),sizeI),
  error(message('images:deconvlucy:damparMustBeSameSizeAsImage'))
elseif ~isa(DAMPAR,classI{2}),
  error(message('images:deconvlucy:damparMustBeSameClassAsInputImage'))
elseif ~strcmp(classI{2},'double'),
  DAMPAR = im2double(DAMPAR);
end

validateattributes(DAMPAR,{'double'},{'finite'},mfilename,'DAMPAR',4);

% READOUT check read-out noise
if isempty(READOUT),
  READOUT = READOUT_d;
elseif (numel(READOUT)~=1) && ~isequal(size(READOUT),sizeI),
  error(message('images:deconvlucy:readoutMustBeSameSizeAsImage'))
elseif ~isa(READOUT,classI{2}),
  error(message('images:deconvlucy:readoutMustBeSameClassAsInputImage'))
elseif ~strcmp(classI{2},'double'),
  READOUT = im2double(READOUT);
end

validateattributes(READOUT,{'double'},{'finite'},mfilename,'READOUT',6);

% WEIGHT check weighting
if isempty(WEIGHT),
  WEIGHT = ones(sizeI);
else
    validateattributes(WEIGHT,{'double'},{'finite'},mfilename,'WEIGHT',5);    
    if (numel(WEIGHT)~=1) && ~isequal(size(WEIGHT),sizeI),
      error(message('images:deconvlucy:weightMustBeSameSizeAsImage'))
    elseif numel(WEIGHT)== 1,
      WEIGHT = repmat(WEIGHT,sizeI);
    end
end
