function matrice_deblur = Filter_matrix(data,kernel)

% ASL_DEBLUR: Filter_matrix
% This is the wrapper for the Lucy-Richardson deconvolution
%
% Filter matrix creates the different matrices before applying the
% deblurring algorithm
% Input --> original deltaM maps; kernel
% Output --> deblurred deltaM maps
%
% (c) Michael A. Chappell & Illaria Boscolo Galazzo, University of Oxford, 2012-2014

% MAC 4/4/14 removed the creation of the lorentz kernel and allow to accept
% any kernel

[nr,nc,ns,nt] = size(data);

% Matrix K 
kernel_max = kernel./sum(kernel);
matrix_kernel(:,1) = kernel_max;
for i = 2:ns
    matrix_kernel(:,i) = [zeros(i-1,1);kernel_max(1:(ns-i+1))];
end
% Invert with SVD
[U,S,V] = svd(matrix_kernel);
W = diag(1./diag(S));
W(S<(0.2*S(1,1))) = 0;
inverse_matrix = V*W*U.';

% Deblurring Algorithm
%h = waitbar(0,'Deblurring Algorithm');
index = 1;
for i = 1:nr
    for j =1:nc
        for k = 1:nt
            index = index+1;
            %waitbar(index/(nt*nc*nc),h)
            data_vettore = (reshape(data(i,j,:,k),ns,1));
            initial_estimate = (inverse_matrix*data_vettore);
            deblur = deconvlucy_asl(data_vettore,kernel,8,initial_estimate);
            deblur_image(i,j,:,k) = deblur;
        end
    end
end
matrice_deblur = deblur_image; 


