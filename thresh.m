function x = thresh(x, t, useabs, binarise)

% x = thresh(x, t, useabs, binarise)
% set all x<t to 0 is useabs = 0
% set all abs(x)<t to 0 is useabs = 1
% set all x>=t to 1 if binarise is not 0
   
if(nargin<3),
	useabs = 0;
end;
if(nargin<4),
	binarise = 0;
end;

x2 = squash(x);

if(~useabs),
   x2(find(x<t)) = 0;
   if(binarise),
      x2(find(x>=t)) = 1;
   end;
else,
   x2(find(abs(x)<t)) = 0;
   if(binarise),
      x2(find((abs(x)>=t))) = 1;
   end;
end;

x = reshape(x2,size(x));