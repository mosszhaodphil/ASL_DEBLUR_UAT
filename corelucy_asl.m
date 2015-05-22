function f = corelucy_asl(Y,H,DAMPAR22,wI,READOUT,SUBSMPL,idx,vec,num)

Hflip = H(end:-1:1,end:-1:1);
ReBlurred1 =H*(Y);
ReBlurred = Hflip * ReBlurred1;


% % 1. Resampling if needed
% if SUBSMPL ~= 1,% Bin ReBlurred back to the sizeI for non-singleton dims
%   
%   %1.Reshape so that the-to-binned dimension separates into two
%   %dimensions, with one of them consisting of elements of a single bin.
%   ReBlurred = reshape(ReBlurred,vec);
% 
%   %2. Bin (==calculate mean) along the first of the-to-binned dimension,
%   %that dimension consists of the bin elements. Reshape to get rid off
%   for k = num,% new appeared singleton.
%     vec(k) = [];
%     ReBlurred = reshape(mean(ReBlurred,k),vec);
%   end
%   
% end;

% 2. An Estimate for the next step
ReBlurred = ReBlurred;
ReBlurred(ReBlurred == 0) = eps;
AnEstim = wI./ReBlurred + eps;
%  AnEstim = (wI - ReBlurred);

% 3. Damping if needed
if DAMPAR22 == 0,% No Damping
  ImRatio = AnEstim(idx{:});
else % Damping of the image relative to DAMPAR22 = (N*sigma)^2
  gm = 10;
  g = (wI.*log(AnEstim)+ ReBlurred - wI)./DAMPAR22;
  g = min(g,1);
  G = (g.^(gm-1)).*(gm-(gm-1)*g);
  ImRatio = 1 + G(idx{:}).*(AnEstim(idx{:}) - 1);
end;

f = ImRatio;